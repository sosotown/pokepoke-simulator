# ポケポケシュミレータ🎴

Rubyで構築されたカードバトルシミュレータ

## 動かし方

- **Dockerのインストール**: Dockerがインストールされていることを確認してください。
- **リポジトリのクローン**: このリポジトリをクローンします。
- **Dockerイメージのビルド**: 以下のコマンドでDockerイメージをビルドします。
  ```bash
  docker compose up --build -d
  ```
- **シミュレーションの実行**: シミュレーションを実行します。
  ```bash
  docker compose exec app bash
  ```
  ```bash
  ruby examples/run_simulation.rb
  ```

## 編集方法
run_simulation.rb内のカード情報等を編集して使用してください

*PR待ってます!*
