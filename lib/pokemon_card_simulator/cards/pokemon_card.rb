# frozen_string_literal: true

module PokemonCardSimulator
  module Cards
    class PokemonCard < Card
      attr_reader :hp, :attacks, :stage, :type, :evolution_from
      attr_accessor :current_hp, :paralyzed

      def initialize(name:, hp:, type:, stage: 'basic', evolution_from: nil, attacks: [])
        super(name: name, type: 'pokemon')
        @hp = hp
        @current_hp = hp
        @type = type
        @attacks = attacks
        @stage = stage
        @evolution_from = evolution_from
        @attached_energies = []
        @paralyzed = false
      end

      def add_energy(energy_card)
        @attached_energies << energy_card
      end

      def energy_count(type = nil)
        if type
          @attached_energies.count { |e| e.energy_type == type }
        else
          @attached_energies.size
        end
      end

      def can_use_attack?(attack_index)
        return false unless attack = @attacks[attack_index]
        return false if @paralyzed

        # エネルギー要求を満たしているか確認
        attack[:energy_requirement].all? do |type, count|
          energy_count(type) >= count
        end
      end

      # わざの使用
      def use_attack(attack_index, attacker, defender)
        return false unless can_use_attack?(attack_index)

        attack = @attacks[attack_index]
        damage = attack[:damage]

        # 攻撃効果の適用
        defender.battle_zone.take_damage(damage)

        # 追加効果があれば適用
        if attack[:effects].present?
          attack[:effects].each do |effect|
            PokemonCardSimulator::EffectProcessor.process_effect(effect, attacker, defender)
          end
        end

        true
      end

      def playable?(player, game_state = {})
        return true if basic?
        return false unless evolution?

        # 進化の場合、場に進化元ポケモンがいるかチェック
        player.can_evolve?(self)
      end

      def basic?
        @stage == 'basic'
      end

      def evolution?
        @stage == 'evolution'
      end

      def alive?
        @current_hp.positive?
      end

      def take_damage(amount)
        @current_hp = [@current_hp - amount, 0].max
      end

      def heal(amount)
        @current_hp = [@current_hp + amount, @hp].min
      end

      def details
        super.merge(
          hp: @hp,
          current_hp: @current_hp,
          attack: @attack,
          stage: @stage,
          evolution_from: @evolution_from
        )
      end

      private

      def apply_effect(effect, target)
        EffectProcessor.new.process_effect(effect, target, effect_params)
      end
    end
  end
end
