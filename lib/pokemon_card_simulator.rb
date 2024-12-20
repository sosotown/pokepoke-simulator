require 'parallel'
require 'active_support/all'

# 基本クラスの読み込み
require_relative 'pokemon_card_simulator/card'

# カード種類の読み込み
require_relative 'pokemon_card_simulator/cards/pokemon_card'
require_relative 'pokemon_card_simulator/cards/goods_card'
require_relative 'pokemon_card_simulator/cards/support_card'
require_relative 'pokemon_card_simulator/cards/energy_card'

# その他のクラスの読み込み
require_relative 'pokemon_card_simulator/player'
require_relative 'pokemon_card_simulator/battle'
require_relative 'pokemon_card_simulator/simulator'
require_relative 'pokemon_card_simulator/effect_processor'

module PokemonCardSimulator
  class Error < StandardError; end

  # シミュレーション実行のヘルパーメソッド
  def self.run(player1_options:, player2_options:, num_games: 1000)
    simulator = Simulator.new(player1_options: player1_options, player2_options: player2_options, num_games: num_games)
    simulator.run
  end

  # 簡易的なデッキビルダー
  def self.build_deck(cards)
    cards.map do |card_data|
      kind = card_data[:kind]
      case kind
      when 'pokemon'
        Cards::PokemonCard.new(**card_data.except(:kind))
      when 'goods'
        Cards::GoodsCard.new(**card_data.except(:kind))
      when 'support'
        Cards::SupportCard.new(**card_data.except(:kind))
      else
        binding.pry
        raise Error, "Unknown card type: #{kind}"
      end
    end
  end
end
