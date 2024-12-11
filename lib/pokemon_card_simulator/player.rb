# frozen_string_literal: true

module PokemonCardSimulator
  class Player
    attr_accessor :battle_zone, :bench, :pokemon_played_this_turn
    attr_reader :deck, :hand, :discard_pile, :energy_elements

    INITIAL_DRAW_CARD_COUNT = 5
    MAX_BENCH_SIZE = 3

    def initialize(deck:, energy_elements:, strategy: {})
      @deck = deck.dup
      @energy_elements = energy_elements
      @hand = []
      @battle_zone = nil
      @bench = []
      @discard_pile = []
      @strategy = strategy
      @pokemon_played_this_turn = []
    end

    def draw_card
      return false if @deck.empty?

      @hand << @deck.shift
      true
    end

    def initial_draw
      INITIAL_DRAW_CARD_COUNT.times { draw_card }
    end

    def can_evolve?(evolution_card)
      return false unless evolution_card.evolution?

      target = [@battle_zone, *@bench].compact.find do |card|
        card.name == evolution_card.evolution_from
      end

      # 進化元が見つからない、もしくはこのターンに場に出したポケモンの場合は進化できない
      return false unless target
      return false if @pokemon_played_this_turn.include?(target)

      true
    end

    def play_turn(game_state = {})
      @pokemon_played_this_turn = []

      draw_card
      play_cards(game_state)
      true
    end

    def battle_zone_knocked_out
      if @battle_zone
        @discard_pile << @battle_zone
        pick_from_bench
      end
    end

    def pick_from_bench
      @battle_zone = @bench.random
    end

    private

    def play_cards(game_state)
      played_support = false

      # グッズカードを使う
      play_goods_cards(game_state)

      # サポートカードを使う（優先度順）
      play_support_cards(game_state) unless played_support

      # ポケモンを場に出す
      play_pokemon_cards

      # エネルギーを付ける
      play_energy_cards(game_state)

      # 攻撃する
      @battle_zone.attacks.times do |index|
        return black if @battle_zone.use_attack(index, self, game_state)
      end
    end

    def play_energy_cards(game_state)
      energy_element = @energy_elements.sample

      energy_element.play(self, game_state) if energy_element.playable?(self, game_state)
    end

    def play_pokemon_cards
      playable_pokemons = @hand.select { |card|
        card.is_a?(Cards::PokemonCard) && (card.basic? || can_evolve?(card))
      }

      playable_pokemons.each do |pokemon|
        if @battle_zone.nil? && pokemon.basic?
          @battle_zone = pokemon
          @hand.delete_at(@hand.find_index(pokemon))
          @pokemon_played_this_turn << pokemon
        elsif @bench.size < MAX_BENCH_SIZE && pokemon.basic?
          @bench << pokemon
          @hand.delete_at(@hand.find_index(pokemon))
          @pokemon_played_this_turn << pokemon
        elsif pokemon.evolution? && can_evolve?(pokemon)
          evolve_pokemon(pokemon)
        end
      end
    end

    def play_support_cards(game_state)
      support_cards = @hand.select { |card| card.is_a?(Cards::SupportCard) }
      return if support_cards.empty?

      # 優先度順にソート
      support_cards.sort_by(&:priority).each do |card|
        if card.playable?(self, game_state)
          if card.play(self, game_state)
            @hand.delete(card)
            @discard_pile << card
            break
          end
        end
      end
    end

    def play_goods_cards(game_state)
      goods_cards = @hand.select { |card| card.is_a?(Cards::GoodsCard) }

      goods_cards.each do |card|
        if card.playable?(self, game_state)
          if card.play(self, game_state)
            @hand.delete(card)
            @discard_pile << card
          end
        end
      end
    end

    def evolve_pokemon(evolution_card)
      target = [@battle_zone, *@bench].find { |card|
        card&.name == evolution_card.evolution_from
      }
      return unless target

      if target == @battle_zone
        @discard_pile << @battle_zone
        @battle_zone = evolution_card
      else
        @discard_pile << target
        @bench[@bench.index(target)] = evolution_card
      end
      @hand.delete(evolution_card)
    end
  end
end
