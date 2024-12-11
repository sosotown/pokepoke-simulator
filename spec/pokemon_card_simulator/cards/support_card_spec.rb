# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Cards::SupportCard do
  let(:okd) do
    described_class.new(
      name: "オーキド博士",
      effects: [
        {
          type: 'draw', value: 3
        }
      ]
    )
  end

  let(:player) do
    PokemonCardSimulator::Player.new(deck: [okd] * 20)
  end

  describe '#playable?' do
    it 'サポートカードが使用されていたら使用できない' do
      expect(okd.playable?(player, { support_played_this_turn: true })).to eq false
    end
  end

  describe '#play' do
    it 'サポートカードが使用されていない場合、効果が発動する' do
      expect(player.hand.size).to eq 0
      okd.play(player, { support_played_this_turn: false })
      expect(player.hand.size).to eq 3
    end

    it 'サポートカードが使用された場合、効果が発動しない' do
      expect(player.hand.size).to eq 0
      okd.play(player, { support_played_this_turn: true })
      expect(player.hand.size).to eq 0
    end
  end
end
