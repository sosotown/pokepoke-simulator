require 'parallel'
require 'active_support/all'

# 基本クラスの読み込み
require_relative 'pokemon_card_simulator/card'

# カード種類の読み込み
require_relative 'pokemon_card_simulator/cards/pokemon_card'
require_relative 'pokemon_card_simulator/cards/goods_card'
require_relative 'pokemon_card_simulator/cards/support_card'

# その他のクラスの読み込み
require_relative 'pokemon_card_simulator/player'
require_relative 'pokemon_card_simulator/battle'
require_relative 'pokemon_card_simulator/simulator'
require_relative 'pokemon_card_simulator/effect_processor'

module PokemonCardSimulator
  class Error < StandardError; end

  # シミュレーション実行のヘルパーメソッド
  def self.run(deck1:, deck2:, num_games: 1000)
    simulator = Simulator.new(deck1: deck1, deck2: deck2, num_games: num_games)
    simulator.run
  end

  # 簡易的なデッキビルダー
  def self.build_deck(cards)
    cards.map do |card_data|
      case card_data[:type]
      when 'pokemon'
        Cards::PokemonCard.new(**card_data)
      when 'goods'
        Cards::GoodsCard.new(**card_data)
      when 'support'
        Cards::SupportCard.new(**card_data)
      else
        raise Error, "Unknown card type: #{card_data[:type]}"
      end
    end
  end
end
