module PokemonCardSimulator
  module EffectProcessor
    extend self

    def process_effect(effect, player, opponent = nil)
      return if (effect[:flip_coin] && rand(2) == 0)

      case effect[:type]
      when 'damage'
        apply_damage(effect, player)
      when 'heal'
        apply_heal(effect, player)
      when 'draw'
        apply_draw(effect, player)
      when 'search'
        apply_search(effect, player)
      when 'paralyze'
        apply_paralyze(opponent)
      when 'electric_circle'
        apply_electric_circle(player, opponent)
      end
    end

    private

    def apply_electric_circle(player, opponent)
      damage = player.bench.count { |pokemon| pokemon.type == 'electric' } * 30
      opponent.battle_zone.take_damage(damage)
    end

    def apply_damage(effect, player)
      target = find_target(effect[:target], player)
      target.take_damage(effect[:value]) if target
    end

    def apply_heal(effect, player)
      target = find_target(effect[:target], player)
      target.heal(effect[:value]) if target
    end

    def apply_draw(effect, player)
      effect[:value].times { player.draw_card }
    end

    def apply_energy(effect, player)
      target = find_target(effect[:target], player)
      if target
        target.add_energy(effect)
      end
    end

    def apply_search(effect, player)
      target = find_target(effect[:target], player)

      if target
        player.hand << target
        # targetのカードを一枚だけ取り出す
        player.deck.delete_at(player.deck.find_index(target))
        player.deck.shuffle!
      end
    end

    def apply_paralyze(opponent)
      opponent.battle_zone.paralyzed = true
    end

    def find_target(target_type, player, opponent = nil)
      case target_type
      when 'self'
        player
      when 'opponent_active'
        opponent.battle_zone
      when 'opponent_anyone'
        [opponent.battle_zone, *opponent.bench].sample
      when 'own_battle_zone'
        player.battle_zone
      when 'basic_pokemon_in_deck'
        player.deck.find { _1.is_a?(PokemonCardSimulator::Cards::PokemonCard) && _1.basic? }
      when 'heal_anyone'
        # 一番体力が減っているポケモンを選択
        [player.battle_zone, *player.bench].max_by { _1.hp - _1.current_hp }
      end
    end
  end
end
