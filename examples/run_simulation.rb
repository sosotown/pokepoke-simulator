require 'pry'
require_relative '../lib/pokemon_card_simulator'

include PokemonCardSimulator

deck1 = [
  Cards::PokemonCard.new(name: "ピカチュウ", hp: 60, attack: 20),
  Cards::PokemonCard.new(
    name: "ライチュウ",
    hp: 90,
    attack: 40,
    stage: 'evolution',
    evolution_from: "ピカチュウ"
  ),
  Cards::SupportCard.new(
    name: "オーキド博士",
    effects: [{ effect_type: 'draw', value: 3 }]
  ),
  Cards::GoodsCard.new(
    name: "キズぐすり",
    effects: [{ target: 'active_pokemon', type: 'heal', value: 30 }]
  )
] * 5  # 20枚のデッキに

simulator = Simulator.new(deck1: deck1, deck2: deck1.dup, num_games: 10000)

results = simulator.run

puts "合計ゲーム数: #{results[:total_games]} 回"
puts "Player 1 勝率: #{results[:player1_win_rate]}%"
puts "Player 2 勝率: #{results[:player2_win_rate]}%"
puts "引き分け率: #{results[:draw_rate]}%"
