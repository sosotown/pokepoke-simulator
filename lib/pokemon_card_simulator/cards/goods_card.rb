# frozen_string_literal: true

module PokemonCardSimulator
  module Cards
    class GoodsCard < Card
      def initialize(name:, effects:)
        super(name: name, kind: 'goods', effects: effects)
      end

      def playable?(_player, _game_state = {})
        true # グッズカードは基本的に常に使用可能
      end

      def play(attacker, game_state = {})
        return false unless playable?(attacker, game_state)

        @effects.each do |effect|
          PokemonCardSimulator::EffectProcessor.process_effect(effect, attacker)
        end

        true
      end
    end
  end
end
