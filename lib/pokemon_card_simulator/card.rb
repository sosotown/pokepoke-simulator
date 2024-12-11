# frozen_string_literal: true

module PokemonCardSimulator
  class Card
    # 基本属性の読み取り専用アクセサ
    attr_reader :name, :type

    class << self
      def define_effect(name, &block)
        effect_definitions[name] = block
      end

      def effect_definitions
        @effect_definitions ||= {}
      end
    end

    # 効果の定義
    define_effect :draw do |player, game_state, params|
      params[:count].times { player.draw_card }
    end

    define_effect :search_pokemon do |player, game_state, params|
      pokemon = player.deck.find { |card|
        card.is_a?(PokemonCard) &&
        (
          (params[:name].nil? || card.name == params[:name])
          (params[:stage].nil? || card.stage == params[:stage])
        )
      }

      if pokemon
        player.deck.delete(pokemon)
        player.hand << pokemon
        player.deck.shuffle!
      end
    end

    define_effect :heal do |player, game_state, params|
      targets = case params[:target]
      when 'active'
        [player.battle_zone]
      when 'bench'
        player.bench
      when 'all'
        [player.battle_zone, *player.bench]
      end

      targets.each do |target|
        target.heal(params[:amount])
      end if targets
    end

    define_effect :boost_attack do |player, game_state, params|
      target = player.battle_zone
      if target
        target.instance_variable_set(:@attack_boost, params[:amount])
      end
    end

    # カードの初期化
    # @param name [String] カードの名前
    # @param type [String] カードの種類 ('pokemon', 'goods', 'support')
    # @param effects [Array<Hash>] カードの効果（オプション）
    def initialize(name:, type:, effects: [])
      @name = name
      @type = type
      @effects = effects
    end

    # カードが使用可能かどうかを判定
    # @param player [Player] カードを使用するプレイヤー
    # @param game_state [Hash] 現在のゲーム状態
    # @return [Boolean] 使用可能かどうか
    def playable?(player, game_state = {})
      true  # 基本的にはプレイ可能。制限がある場合は子クラスでオーバーライド
    end

    # カードを使用する（抽象メソッド）
    # @param player [Player] カードを使用するプレイヤー
    # @param game_state [Hash] 現在のゲーム状態
    def play(player, game_state = {})
      raise NotImplementedError, "#{self.class}#play must be implemented"
    end

    # カード情報の文字列表現
    # @return [String] カードの情報
    def to_s
      "#{@name} (#{@type})"
    end

    # カードの詳細情報
    # @return [Hash] カードの詳細情報
    def details
      {
        name: @name,
        type: @type,
        effects: @effects
      }
    end

    # カードの複製
    # @return [Card] カードの新しいインスタンス
    def dup
      self.class.new(
        name: @name,
        type: @type,
        effects: @effects.map(&:dup)
      )
    end
  end
end
