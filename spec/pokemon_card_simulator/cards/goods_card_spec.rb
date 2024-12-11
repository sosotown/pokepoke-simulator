# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Cards::GoodsCard do
  let(:potion) do
    described_class.new(
      name: "キズぐすり",
      effects: [{ type: 'heal', target: 'heal_anyone', value: 20 }]
    )
  end

  let(:monster_ball) do
    described_class.new(
      name: "モンスターボール",
      effects: [{ type: 'search', target: 'basic_pokemon_in_deck', value: 1 }]
    )
  end

  let(:pikachu) do
    PokemonCardSimulator::Cards::PokemonCard.new(
      name: "ピカチュウ",
      hp: 60,
      type: 'electric',
      stage: 'basic',
      attacks: [
        {
          name: 'かじる',
          damage: 20,
          energy_requirement: { 'electric' => 1 },
        },
      ]
    )
  end

  let(:damaged_pikachu) do
    PokemonCardSimulator::Cards::PokemonCard.new(
      name: "ピカチュウ",
      hp: 60,
      type: 'electric',
      stage: 'basic',
      attacks: [
        {
          name: 'かじる',
          damage: 20,
          energy_requirement: { 'electric' => 1 },
        },
      ]
    ).tap { |p| p.current_hp = 30 }
  end

  let(:most_damaged_pikachu) do
    PokemonCardSimulator::Cards::PokemonCard.new(
      name: "ピカチュウ",
      hp: 60,
      type: 'electric',
      stage: 'basic',
      attacks: [
        {
          name: 'かじる',
          damage: 20,
          energy_requirement: { 'electric' => 1 },
        },
      ]
    ).tap { |p| p.current_hp = 10 }
  end

  let(:player) do
    PokemonCardSimulator::Player.new(
      deck: [potion, monster_ball] * 8 + [pikachu, pikachu, pikachu, pikachu],
      energy_elements: [PokemonCardSimulator::Cards::EnergyCard.new(energy_type: 'electric')]
    )
  end

  before do
    player.battle_zone = damaged_pikachu
    player.bench = [pikachu, most_damaged_pikachu]
  end

  describe '#play' do
    it 'きずぐすり使用したら一番ダメージを受けているピカチュウが回復する' do
      potion.play(player)

      expect(player.battle_zone.current_hp).to eq 30
      expect(most_damaged_pikachu.current_hp).to eq 30
    end

    it 'モンスターボール使用したらデッキから基本ポケモンを1枚引く' do
      expect { monster_ball.play(player) }.to change { player.deck.size }.by(-1)

      expect(player.hand.map(&:name)).to include("ピカチュウ")
    end
  end
end
