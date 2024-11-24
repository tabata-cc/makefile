# Makefile

## 導入方法

1. EC2 インスタンスを起動し、isucon ユーザーでログインする
2.  `~` で `git clone` する
3.   `cd makefile` をして、各コマンドを実行

## コマンド

| コマンド名 | 引数 | 説明 |
|--|--|--|
| `make restart-mysql` | なし | MySQL を再起動する |
| `make mysql` | `MYSQL_HOST`<br>`MYSQL_PORT`<br>`MYSQL_USER`<br>`MYSQL_PASS` | MySQL にログインする |
| `make clear-sq` | なし | MySQL のスロークエリログを空にする |
| `make clear-access` | なし | Nginx のアクセスログを空にする |
| `make clear-http-res` | なし | HTTP レスポンスのログを空にする |
| `make clear-all` | なし | ログを空にする |
| `make build` | なし | Go アプリケーションをビルドする |
| `make restart-app` | なし | Go アプリケーションを再起動する |
| `make bench` | なし | bench を走らせる |
| `make bench-all` | なし | Go アプリケーションをビルドして、bench を走らせる |
| `make show-sq` | なし | MySQL のスロークエリログを出力する |
| `make show-access` | `ALP_REGEX` | Nginx のアクセスログを出力する。<br>`ALP_REGEX` で指定した正規表現でリクエストをまとめられる |
| `make show-http-res` | `req` | HTTP レスポンスのログを出力する。<br>`req` で特定のリクエストを指定すると、そのリクエストのみを抽出する |

## 実行例

### 引数なしの場合

```sh
make bench-all
```

### 引数ありの場合

```sh
make show-http-res req="POST /api/livestream/7554/moderate"
```
