module PokemonCardSimulator
  module Cards
    class EnergyCard < Card
      attr_reader :energy_type

      def initialize(energy_type:)
        super(name: energy_type, type: 'energy')
        @energy_type = energy_type
      end

      def playable?(player, game_state = {})
        return false if game_state[:first_turn]  # 先攻の1ターン目は付けられない
        return false if game_state[:energy_played_this_turn]  # すでにエネルギーを付けている

        # バトル場かベンチにポケモンがいる場合のみ付けられる
        player.battle_zone || !player.bench.empty?
      end

      def play(player, game_state = {}, target: nil)
        return false unless playable?(player, game_state)

        # 対象のポケモンにエネルギーを付ける
        target ||= player.battle_zone || player.bench.first
        target.add_energy(self)

        game_state[:energy_played_this_turn] = true
        true
      end
    end
  end
end
