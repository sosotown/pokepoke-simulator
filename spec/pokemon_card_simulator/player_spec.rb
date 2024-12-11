# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Player do
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

  let(:player) { described_class.new(deck: deck, energy_elements: [PokemonCardSimulator::Cards::EnergyCard.new(energy_type: 'electric')]) }

  describe '#draw_card' do
    it 'デッキからカードが手札に移動する' do
      expect { player.draw_card }.to change { player.hand.size }.by(1)
                                .and change { player.deck.size }.by(-1)
    end

    it 'デッキの残り枚数が少ない時は引けない' do
      player.deck.clear
      expect(player.draw_card).to be false
    end
  end

  describe '#initial_draw' do
    it '最初に5枚引く' do
      expect { player.initial_draw }.to change { player.hand.size }.by(5).and change { player.deck.size }.by(-5)
    end
  end

  describe '#can_evolve?' do
    before do
      player.battle_zone = PokemonCardSimulator::Cards::PokemonCard.new(**biriri_options)
    end

    it '進化できる' do
      expect(player.can_evolve?(PokemonCardSimulator::Cards::PokemonCard.new(**marumain_options))).to be true
    end

    it 'たねポケモンは進化できない' do
      expect(player.can_evolve?(PokemonCardSimulator::Cards::PokemonCard.new(**biriri_options))).to be false
    end

    it '場にたねポケモンが居ないときは進化できない' do
      player.battle_zone = nil
      expect(player.can_evolve?(PokemonCardSimulator::Cards::PokemonCard.new(**marumain_options))).to be false
    end

    it 'そのターンに場に出したポケモンは進化できない' do
      player.battle_zone = nil
      card = PokemonCardSimulator::Cards::PokemonCard.new(**biriri_options)
      player.pokemon_played_this_turn << card

      expect(player.can_evolve?(PokemonCardSimulator::Cards::PokemonCard.new(**marumain_options))).to be false
    end
  end

  describe '#play_turn' do
    let(:game_state) { {} }
    let(:opponent) { described_class.new(deck: deck, energy_elements: [PokemonCardSimulator::Cards::EnergyCard.new(energy_type: 'electric')]) }

    let(:deck) {
      [
        [
          pikachu_ex_options,
          biriri_options,
          shimama_options,
          zeburaika_options,
          elekiteru_options,
          elezerd_options,
          shibishirasu_options,
          shibishirasu_options,
          shibibiru_options,
          shibibiru_options,
          shibirudon_options
        ].map do |options|
          PokemonCardSimulator::Cards::PokemonCard.new(**options)
        end
      ].flatten
    }

    before do
      allow(player.deck).to receive(:shuffle!)
      player.battle_zone = PokemonCardSimulator::Cards::PokemonCard.new(**biriri_options)
      player.bench = [PokemonCardSimulator::Cards::PokemonCard.new(**shimama_options)]
      player.hand.concat([
        PokemonCardSimulator::Cards::PokemonCard.new(**marumain_options),
        PokemonCardSimulator::Cards::PokemonCard.new(**elekiteru_options),
        PokemonCardSimulator::Cards::PokemonCard.new(**pikachu_ex_options),
        PokemonCardSimulator::Cards::SupportCard.new(**okd_options),
        PokemonCardSimulator::Cards::SupportCard.new(**okd_options),
        PokemonCardSimulator::Cards::GoodsCard.new(**monster_ball_options),
        PokemonCardSimulator::Cards::GoodsCard.new(**monster_ball_options)
      ])

      opponent.battle_zone = PokemonCardSimulator::Cards::PokemonCard.new(**shibishirasu_options)
    end

    it 'ターンプレイが成功する' do
      # モンスターボールを使う X 2 (±0)
      #   ピカチュウEX, ビリリダマ 手札IN 手札:（マルマイン, エレキテル, ピカチュウEX, オーキド, オーキド, ピカチュウEX, ビリリダマ）
      # オーキド博士を使う (+1)
      #   シママ, ゼブライカ 手札IN 手札:（マルマイン, エレキテル, ピカチュウEX, オーキド. ピカチュウEX, ビリリダマ, シママ, ゼブライカ）
      # マルマインを出す (-1)、エレキテルを出す (-1)、ピカチュウEXを出す(-1)、ゼブライカを出す(-1)
      #   手札:（オーキド. ピカチュウEX, ビリリダマ, シママ）
      expect { player.play_turn(opponent, game_state) }.to change { player.hand.size }.by(-3)

      # 出したポケモンの数が増える
      expect(player.pokemon_played_this_turn.size).to eq 4

      # グッツは全部使われる
      expect(player.hand.select { |card| card.is_a?(PokemonCardSimulator::Cards::GoodsCard) }.size).to eq 0

      # サポートカードは1枚残る
      expect(player.hand.select { |card| card.is_a?(PokemonCardSimulator::Cards::SupportCard) }.size).to eq 1
    end
  end
end
