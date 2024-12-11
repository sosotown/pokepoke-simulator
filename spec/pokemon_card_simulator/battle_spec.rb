# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Battle do
  pikachu_ex_options = { name: "ピカチュウ EX", hp: 120, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキサークル', damage: 0, energy_requirement: { 'electric' => 2 }, effects: [ { type: 'electric_circle' } ]}] }
  biriri_options = { name: "ビリリダマ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'たいあたり', damage: 20, energy_requirement: { 'electric' => 1 } }] }
  marumain_options = { name: "マルマイン", hp: 80, type: 'electric', stage: 'evolution', evolution_from: "ビリリダマ", attacks: [{ name: 'エレキボール', damage: 70, energy_requirement: { 'electric' => 2 } }] }
  shimama_options = { name: "シママ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキック', damage: 20, energy_requirement: { 'electric' => 2 } }] }
  zeburaika_options = { name: "ゼブライカ", hp: 90, type: 'electric', stage: 'evolution', evolution_from: "シママ", attacks: [{ name: 'サンダーアロー', damage: 0, energy_requirement: { 'electric' => 3 }, effects: [ { type: 'damage', target: 'opponent_anyone', value: 30 } ] }] }
  elekiteru_options = { name: "エレキテル", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'しっぽではたく', damage: 20, energy_requirement: { 'electric' => 1 } }] }
  elezerd_options = { name: "エレザード", hp: 90, type: 'electric', stage: 'evolution', evolution_from: "エレキテル", attacks: [{ name: 'でんこうせっか', damage: 40, energy_requirement: { 'normal' => 3 }, effects: [ { type: 'damage', target: 'opponent_active', flip_coin: true } ] }] }
  shibishirasu_options = { name: "シビシラス", hp: 30, type: 'electric', stage: 'basic', attacks: [{ name: 'プチでんき', damage: 30, energy_requirement: { 'electric' => 1 } }] }
  shibibiru_options = { name: "シビビール", hp: 80, type: 'electric', stage: 'evolution', evolution_from: "シビシラス", attacks: [{ name: 'ヘッドボルト', damage: 40, energy_requirement: { 'electric' => 1 } }] }
  shibirudon_options = { name: "シビルドン", hp: 140, type: 'electric', stage: 'evolution', evolution_from: "シビビール", attacks: [{ name: 'かみなりのキバ', damage: 80, energy_requirement: { 'electric' => 2, 'normal' => 1 }, effects: [ { type: 'paralyze', target: 'opponent_active', flip_coin: true } ] }] }
  monster_ball_options = { name: "モンスターボール", effects: [{ type: 'search', target: 'basic_pokemon_in_deck', value: 1 }] }
  okd_options = { name: "オーキド博士", effects: [{ type: 'draw', value: 2 }] }

  let(:deck) {
    [
      [
        pikachu_ex_options,
        pikachu_ex_options,
        biriri_options,
        biriri_options,
        marumain_options,
        shimama_options,
        shimama_options,
        zeburaika_options,
        elekiteru_options,
        elekiteru_options,
        elezerd_options,
        shibishirasu_options,
        shibishirasu_options,
        shibibiru_options,
        shibibiru_options,
        shibirudon_options
      ].map do |options|
        PokemonCardSimulator::Cards::PokemonCard.new(**options)
      end,
      [okd_options, okd_options].map do |options|
        PokemonCardSimulator::Cards::SupportCard.new(**options)
      end,
      [monster_ball_options, monster_ball_options].map do |options|
        PokemonCardSimulator::Cards::GoodsCard.new(**options)
      end
    ].flatten
  }

  let(:player1) { PokemonCardSimulator::Player.new(deck: deck, energy_elements: [PokemonCardSimulator::Cards::EnergyCard.new(energy_type: 'electric')]) }
  let(:player2) { PokemonCardSimulator::Player.new(deck: deck, energy_elements: [PokemonCardSimulator::Cards::EnergyCard.new(energy_type: 'electric')]) }
  let(:battle) { described_class.new(player1: player1, player2: player2) }

  before do
    allow(player1.deck).to receive(:shuffle!)
    allow(player2.deck).to receive(:shuffle!)
  end

  describe '#simulate' do
    it 'ゲームが正常にシミュレートされる' do
      expect { battle.simulate }.not_to raise_error
    end

    it '50ターン以内に決着がつく' do
      expect(battle.simulate).not_to eq(:draw)
    end
  end

  describe '#setup_game' do
    it '両プレイヤーが初期ドローを行う' do
      expect(player1).to receive(:initial_draw)
      expect(player2).to receive(:initial_draw)
      battle.send(:setup_game)
    end
  end

  describe '#play_turn' do
    before do
      battle.send(:setup_game)
    end

    it 'プレイヤーのターンが正常にプレイされる' do
      expect(battle.send(:play_turn, player1, player2)).to be true
    end

    it 'プレイヤーのバトルゾーンが存在しない場合、falseを返す' do
      allow(player1).to receive(:battle_zone).and_return(nil)
      expect(battle.send(:play_turn, player1, player2)).to be false
    end
  end

  describe '#execute_battle' do
    it 'バトルが正常に実行される' do
      player1.battle_zone = PokemonCardSimulator::Cards::PokemonCard.new(**biriri_options)
      player2.battle_zone = PokemonCardSimulator::Cards::PokemonCard.new(**shibishirasu_options)
      expect { battle.send(:execute_battle, player1, player2) }.not_to raise_error
    end
  end

  describe '#check_winner' do
    it 'デッキが空の場合、相手プレイヤーが勝利する' do
      player1.deck.clear
      expect(battle.send(:check_winner)).to eq(:player2_wins)
    end

    it 'バトルゾーンとベンチが空の場合、相手プレイヤーが勝利する' do
      player1.battle_zone = nil
      player1.bench.clear
      expect(battle.send(:check_winner)).to eq(:player2_wins)
    end
  end
end
