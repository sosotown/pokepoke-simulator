# 最新のRuby 3.3.0をベースイメージとして使用
FROM ruby:3.3.6-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを設定
WORKDIR /app

# Gemfileをコピーして依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーションのソースをコピー
COPY . .

# PRNG高速化のための環境変数設定
ENV RUBY_YJIT_ENABLE=1

# コンテナ起動時にirbを実行
CMD ["irb"]
