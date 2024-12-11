# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Cards::PokemonCard do
  let(:pikachu_ex) do
    described_class.new(
      name: "ピカチュウ EX",
      hp: 120,
      type: 'electric',
      stage: 'basic',
      attacks: [
        {
          name: 'エレキサークル',
          damage: 0,
          energy_requirement: { 'electric' => 2 },
          effects: [
            {
              type: 'electric_circle'
            }
          ]
        }
      ]
    )
  end

  let(:pikachu) do
    described_class.new(
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

  let(:raichu) do
    described_class.new(
      name: "ライチュウ",
      hp: 100,
      type: 'electric',
      stage: 'evolution',
      evolution_from: "ピカチュウ",
      attacks: [
        {
          name: '10まんボルト',
          damage: 140,
          energy_requirement: { 'electric' => 3 },
          effects: [
            {
              type: 'energy_trash',
              value: 'all'
            }
          ]
        },
      ]
    )
  end

  describe '#basic?' do
    it 'たねポケモンはtrueを返す' do
      expect(pikachu.basic?).to be true
      expect(pikachu_ex.basic?).to be true
    end

    it '進化ポケモンはfalseを返す' do
      expect(raichu.basic?).to be false
    end
  end

  describe '#take_damage' do
    it '与えられたダメージ分current_hpが減る' do
      pikachu.take_damage(20)
      expect(pikachu.current_hp).to eq 40
    end

    it 'current_hpは0以下にならない' do
      pikachu.take_damage(100)
      expect(pikachu.current_hp).to eq 0
    end
  end

  describe '#heal' do
    before { pikachu.take_damage(30) }

    it '回復する' do
      pikachu.heal(20)
      expect(pikachu.current_hp).to eq 50
    end

    it 'maxHPより増えない' do
      pikachu.heal(40)
      expect(pikachu.current_hp).to eq pikachu.hp
    end
  end

  describe '#alive?' do
    it 'HPが残ってる時はtrueを返す' do
      expect(pikachu.alive?).to be true
    end

    it 'HPが0になるとfalseを返す' do
      pikachu.take_damage(60)
      expect(pikachu.alive?).to be false
    end
  end

  describe '#playable?' do
    let(:player) { double('Player') }

    it 'たねポケモンはいつでも出せる' do
      expect(pikachu.playable?(player)).to be true
    end

    it '進化ポケモンは進化元がいる時に出せる' do
      allow(player).to receive(:can_evolve?).with(raichu).and_return(true)
      expect(raichu.playable?(player)).to be true
    end

    it '進化ポケモンは進化元がいない時に出せない' do
      allow(player).to receive(:can_evolve?).with(raichu).and_return(false)
      expect(raichu.playable?(player)).to be false
    end
  end

  describe '#energy_count' do
    let(:fire_energy) { double('Energy', energy_type: 'fire') }
    let(:water_energy) { double('Energy', energy_type: 'water') }

    before do
      [fire_energy, water_energy, fire_energy].each do |energy|
        pikachu.add_energy(energy)
      end
    end

    it '指定したエネルギーの枚数を返す' do
      expect(pikachu.energy_count('fire')).to eq 2
    end
  end

  describe '#can_use_attack?' do
    before do
      allow(pikachu).to receive(:energy_count).with('electric').and_return(2)
    end

    it 'エネルギーが足りている時はtrueを返す' do
      expect(pikachu.can_use_attack?(0)).to be true
    end

    it 'エネルギーが足りていない時はfalseを返す' do
      allow(pikachu).to receive(:energy_count).with('electric').and_return(0)
      expect(pikachu.can_use_attack?(0)).to be false
    end

    it '麻痺状態の時はfalseを返す' do
      pikachu.paralyzed = true
      expect(pikachu.can_use_attack?(0)).to be false
    end
  end

  describe '#use_attack' do
    let(:target) { raichu }
    let(:attacher) { double('Player') }
    let(:defender) { double('Player', battle_zone: target) }

    before do
      allow(pikachu).to receive(:can_use_attack?).with(0).and_return(true)
      allow(pikachu_ex).to receive(:can_use_attack?).with(0).and_return(true)
      allow(attacher).to receive(:bench).and_return([pikachu, pikachu, pikachu])
    end

    it '攻撃を行う' do
      pikachu.use_attack(0, attacher, defender)

      expect(defender.battle_zone.current_hp).to eq 80
    end

    it '追加効果がある場合は適用する(エレキサークル)' do
      pikachu_ex.use_attack(0, attacher, defender)

      expect(defender.battle_zone.current_hp).to eq 10
    end
  end
end
