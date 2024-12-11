# frozen_string_literal: true

module PokemonCardSimulator
  module Cards
    class SupportCard < Card
      def initialize(name:, effects:, priority: 1)
        super(name: name, kind: 'support', effects: effects)
        @priority = priority  # サポートカードの優先度
      end

      def playable?(_player, game_state = {})
        # サポートカードは1ターンに1枚しか使えない
        !game_state[:support_played_this_turn]
      end

      def play(attacker, game_state = {})
        return false unless playable?(attacker, game_state)

        @effects.each do |effect|
          PokemonCardSimulator::EffectProcessor.process_effect(effect, attacker)
        end

        game_state[:support_played_this_turn] = true
        true
      end

      def priority
        @priority
      end
    end
  end
end
