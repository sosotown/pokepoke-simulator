# frozen_string_literal: true

module PokemonCardSimulator
  class Simulator
    def initialize(player1_options:, player2_options:, num_games: 1000)
      @player1_options = player1_options
      @player2_options = player2_options
      @num_games = num_games
    end

    def run
      results = {
        player1_wins: 0,
        player2_wins: 0,
        draws: 0
      }

      Parallel.each(1..@num_games, in_threads: 4) do |_|
        player1_deck = PokemonCardSimulator.build_deck(@player1_options[:deck])
        player2_deck = PokemonCardSimulator.build_deck(@player2_options[:deck])
        player1 = Player.new(deck: player1_deck, energy_elements: @player1_options[:energy_elements])
        player2 = Player.new(deck: player2_deck, energy_elements: @player2_options[:energy_elements])

        battle = Battle.new(player1: player1, player2: player2)

        # 結果を集計
        case battle.simulate
        when :player1_wins
          results[:player1_wins] += 1
        when :player2_wins
          results[:player2_wins] += 1
        when :draw
          results[:draws] += 1
        end
      end

      format_results(results)
    end

    private

    def format_results(results)
      total = @num_games.to_f
      {
        player1_win_rate: (results[:player1_wins] / total * 100).round(2),
        player2_win_rate: (results[:player2_wins] / total * 100).round(2),
        draw_rate: (results[:draws] / total * 100).round(2),
        total_games: @num_games
      }
    end
  end
end
