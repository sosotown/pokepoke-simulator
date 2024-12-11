# frozen_string_literal: true

RSpec.describe PokemonCardSimulator::Battle do
  let(:pikachu) do
    PokemonCardSimulator::Cards::PokemonCard.new(
      name: "ピカチュウ",
      hp: 60,
      attack: 20,
      stage: 'basic'
    )
  end

  let(:deck) { [pikachu] * 20 }  # 20枚のピカチュウデッキ
  let(:player1) { PokemonCardSimulator::Player.new(deck: deck.dup) }
  let(:player2) { PokemonCardSimulator::Player.new(deck: deck.dup) }
  let(:battle) { described_class.new(player1: player1, player2: player2) }

  describe '#simulate' do
    it 'returns a valid result' do
      result = battle.simulate
      expect([:player1_wins, :player2_wins, :draw]).to include(result)
    end

    context 'when a player runs out of cards' do
      before do
        player1.deck.clear
      end

      it 'ends the game with player2 winning' do
        expect(battle.simulate).to eq :player2_wins
      end
    end
  end
end
