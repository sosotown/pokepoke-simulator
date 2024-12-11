require 'pry'
require_relative '../lib/pokemon_card_simulator'

include PokemonCardSimulator

deck = [
  { kind: 'pokemon', name: "ピカチュウ EX", hp: 120, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキサークル', damage: 0, energy_requirement: { 'electric' => 2 }, effects: [ { type: 'electric_circle' } ]}] },
  { kind: 'pokemon', name: "ピカチュウ EX", hp: 120, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキサークル', damage: 0, energy_requirement: { 'electric' => 2 }, effects: [ { type: 'electric_circle' } ]}] },
  { kind: 'pokemon', name: "ビリリダマ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'たいあたり', damage: 20, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "ビリリダマ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'たいあたり', damage: 20, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "マルマイン", hp: 80, type: 'electric', stage: 'evolution', evolution_from: "ビリリダマ", attacks: [{ name: 'エレキボール', damage: 70, energy_requirement: { 'electric' => 2 } }] },
  { kind: 'pokemon', name: "シママ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキック', damage: 20, energy_requirement: { 'electric' => 2 } }] },
  { kind: 'pokemon', name: "シママ", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'エレキック', damage: 20, energy_requirement: { 'electric' => 2 } }] },
  { kind: 'pokemon', name: "ゼブライカ", hp: 90, type: 'electric', stage: 'evolution', evolution_from: "シママ", attacks: [{ name: 'サンダーアロー', damage: 0, energy_requirement: { 'electric' => 3 }, effects: [ { type: 'damage', target: 'opponent_anyone', value: 30 } ] }] },
  { kind: 'pokemon', name: "エレキテル", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'しっぽではたく', damage: 20, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "エレキテル", hp: 60, type: 'electric', stage: 'basic', attacks: [{ name: 'しっぽではたく', damage: 20, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "エレザード", hp: 90, type: 'electric', stage: 'evolution', evolution_from: "エレキテル", attacks: [{ name: 'でんこうせっか', damage: 40, energy_requirement: { 'normal' => 3 }, effects: [ { type: 'damage', target: 'opponent_active', flip_coin: true } ] }] },
  { kind: 'pokemon', name: "シビシラス", hp: 30, type: 'electric', stage: 'basic', attacks: [{ name: 'プチでんき', damage: 30, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "シビシラス", hp: 30, type: 'electric', stage: 'basic', attacks: [{ name: 'プチでんき', damage: 30, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "シビビール", hp: 80, type: 'electric', stage: 'evolution', evolution_from: "シビシラス", attacks: [{ name: 'ヘッドボルト', damage: 40, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "シビビール", hp: 80, type: 'electric', stage: 'evolution', evolution_from: "シビシラス", attacks: [{ name: 'ヘッドボルト', damage: 40, energy_requirement: { 'electric' => 1 } }] },
  { kind: 'pokemon', name: "シビルドン", hp: 140, type: 'electric', stage: 'evolution', evolution_from: "シビビール", attacks: [{ name: 'かみなりのキバ', damage: 80, energy_requirement: { 'electric' => 2, 'normal' => 1 }, effects: [ { type: 'paralyze', target: 'opponent_active', flip_coin: true } ] }] },
  { kind: 'goods', name: "モンスターボール", effects: [{ type: 'search', target: 'basic_pokemon_in_deck', value: 1 }] },
  { kind: 'goods', name: "モンスターボール", effects: [{ type: 'search', target: 'basic_pokemon_in_deck', value: 1 }] },
  { kind: 'support', name: "オーキド博士", effects: [{ type: 'draw', value: 2 }] },
  { kind: 'support', name: "オーキド博士", effects: [{ type: 'draw', value: 2 }] },
]

results = PokemonCardSimulator.run(
  player1_options: { deck: deck, energy_elements: [Cards::EnergyCard.new(energy_type: 'electric')] },
  player2_options: { deck: deck, energy_elements: [Cards::EnergyCard.new(energy_type: 'electric')] },
  num_games: 1000
)

puts "合計ゲーム数: #{results[:total_games]} 回"
puts "Player 1 勝率: #{results[:player1_win_rate]}%"
puts "Player 2 勝率: #{results[:player2_win_rate]}%"
puts "引き分け率: #{results[:draw_rate]}%"
