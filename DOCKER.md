# Docker を使用した finance-tools-mcp の実行方法

このドキュメントでは、finance-tools-mcp を Docker コンテナとして実行する方法について説明します。

## 実装の特徴

このDockerfile実装では、以下の特徴があります：

1. ビルド時に仮想環境を作成し、すべての依存関係をインストール
2. コンテナ起動時には、既に準備された環境を使用
3. パッケージのインストール時に作成されるエントリーポイントを自動的に使用

## 前提条件

- Docker がインストールされていること

## 使用方法

### 1. イメージのビルド

リポジトリのルートディレクトリで以下のコマンドを実行します：

```bash
docker build -t finance-tools-mcp .
```

これにより、Docker イメージがビルドされます。

### 2. コンテナの実行（stdio モード）

MCP サーバーを stdio トランスポートモードで実行するには：

```bash
docker run -i --rm finance-tools-mcp --transport stdio
```

このコマンドは標準入出力（stdio）を使用して MCP サーバーと通信します。Claude Desktop などのクライアントは、このコンテナを直接起動して通信します。

### 3. 環境変数の設定

環境変数を設定してコンテナを実行するには：

```bash
docker run -i --rm -e FRED_API_KEY=your_api_key finance-tools-mcp --transport stdio
```

## 環境変数

以下の環境変数を設定することができます：

- `FRED_API_KEY`: FRED API キー（オプション）

環境変数を設定してコンテナを起動する例：

```bash
FRED_API_KEY=your_api_key docker run -i --rm finance-tools-mcp --transport stdio
```

## Claude Desktop との連携

Claude Desktop で finance-tools-mcp を使用するには、`claude_desktop_config.json` に以下の設定を追加します：

```json
{
  "mcpServers": {
    "investor": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "finance-tools-mcp", "--transport", "stdio"]
    }
  }
}
```

これにより、Claude Desktop は Docker コンテナを起動し、stdio トランスポートを使用して MCP サーバーと通信します。

FRED API キーを設定する場合：

```json
{
  "mcpServers": {
    "investor": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "FRED_API_KEY=your_api_key", "finance-tools-mcp", "--transport", "stdio"]
    }
  }
}
```

## トラブルシューティング

### デバッグ情報の取得

コンテナのビルド情報やログを確認するには：

```bash
# イメージの詳細情報を表示
docker inspect finance-tools-mcp

# コンテナのログを表示
docker logs <container_id>
```

注意: 現在の実装では、コンテナは自動的に `finance-tools-mcp` コマンドを実行するため、`/bin/bash` などのシェルを直接実行することはできません。

## カスタマイズ

### データの永続化

データを永続化するには、ボリュームマウントを使用します：

```bash
docker run -i --rm -v $(pwd)/data:/app/data finance-tools-mcp --transport stdio
```

これにより、ホストマシンの `data` ディレクトリがコンテナ内の `/app/data` ディレクトリにマウントされます。

### イメージのカスタマイズ

Dockerfile を編集することで、イメージをカスタマイズできます。変更後は以下のコマンドでイメージを再ビルドします：

```bash
docker build -t finance-tools-mcp .