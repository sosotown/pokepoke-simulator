# frozen_string_literal: true

module PokemonCardSimulator
  class Battle
    def initialize(player1:, player2:)
      @player1 = player1
      @player2 = player2
      @turn = 0
      @game_state = { support_played_this_turn: false }
    end

    def simulate
      setup_game
      play_game
    end

    private

    def setup_game
      [@player1, @player2].each(&:initial_draw)
    end

    def play_game
      max_turns = 50 # 無限ループ防止

      while @turn < max_turns
        @turn += 1
        @game_state[:support_played_this_turn] = false

        # プレイヤー1のターン
        return :player2_wins unless play_turn(@player1, @player2)

        # プレイヤー2のターン
        @game_state[:support_played_this_turn] = false
        return :player1_wins unless play_turn(@player2, @player1)

        # 勝敗判定
        if winner = check_winner
          return winner
        end
      end

      :draw
    end

    def play_turn(player, opponent)
      result = player.play_turn(opponent, @game_state)
      return false unless result
      return false unless player.battle_zone

      execute_battle(player, opponent) if player.battle_zone

      return false unless @turn == 0 || opponent.battle_zone

      true
    end

    def execute_battle(attacker, defender)
      return unless attacker.battle_zone && defender.battle_zone

      attacker.battle_zone.use_attack(0, attacker, defender)

      if !defender.battle_zone.alive?
        defender.battle_zone_knocked_out
      end
    end

    def check_winner
      if @player1.deck.empty? || (!@player1.battle_zone && @player1.bench.empty?)
        :player2_wins
      elsif @player2.deck.empty? || (!@player2.battle_zone && @player2.bench.empty?)
        :player1_wins
      end
    end
  end
end
