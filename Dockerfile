FROM python:3.10-slim

WORKDIR /app

# 環境変数の設定
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    build-essential \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# pipのアップグレードとuvのインストール
RUN pip install --upgrade pip && \
    pip install uv

# 依存関係ファイルのコピー
COPY pyproject.toml uv.lock ./

# プロジェクトファイルのコピー
COPY apps/ ./apps/
COPY packages/ ./packages/
COPY config/ ./config/
COPY data/ ./data/
COPY README.md ./

# 仮想環境の作成と依存関係のインストール（ビルド時に実行）
RUN uv venv && \
    . .venv/bin/activate && \
    uv pip install -e .

# 実行コマンド（既存の仮想環境を使用）
ENTRYPOINT [".venv/bin/finance-tools-mcp"]
# デフォルトでstdioトランスポートを使用