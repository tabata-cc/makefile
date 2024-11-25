MYSQL_USER=isucon
MYSQL_PASS=isucon
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
SLOW_QUERY_LOG=/var/log/mysql/mysql-slow.log

ACCESS_LOG=/var/log/nginx/access.log
ALP_REGEX="/api/livestream/[0-9]+/livecomment,\
/api/livestream/[0-9]+/reaction,\
/api/livestream/[0-9]+/report,\
/api/livestream/[0-9]+/ngwords,\
/api/livestream/[0-9]+/enter,\
/api/livestream/[0-9]+/exit,\
/api/livestream/[0-9]+/moderate,\
/api/user/[^/]+/theme,\
/api/user/[^/]+/livestream,\
/api/user/[^/]+/statistics,\
/api/user/[^/]+/icon"

HTTP_RESPONSE_LOG=/tmp/log/app/request_response_body.log

APP_NAME=isupipe-go.service

# MySQL を再起動する
.PHONY: restart-mysql
restart-mysql:
	sudo systemctl restart mysql

# MySQL にログインする
.PHONY: mysql
mysql:
	mysql -h$(MYSQL_HOST) -P$(MYSQL_PORT) -u$(MYSQL_USER) -p$(MYSQL_PASS)

# MySQL のスロークエリログを空にする
.PHONY: clear-sq
clear-sq:
	sudo truncate -s 0 $(SLOW_QUERY_LOG)

# Nginx のアクセスログを空にする
.PHONY: clear-access
clear-access:
	sudo truncate -s 0 $(ACCESS_LOG)

# HTTP レスポンスのログを空にする
.PHONY: clear-http-res
clear-http-res:
	sudo truncate -s 0 $(HTTP_RESPONSE_LOG)

# ログを空にする
.PHONY: clear-all
clear-all:
	make clear-sq && make clear-access && make clear-http-res

# Go アプリケーションをビルドする
.PHONY: build
build:
	cd ~/webapp/go && make build

# Go アプリケーションを再起動する
.PHONY: restart-app
restart-app:
	sudo systemctl restart $(APP_NAME)

# bench を走らせる
.PHONY: bench
bench:
	make clear-all && cd ~ && ./bench run --enable-ssl

# Go アプリケーションをビルドして bench を走らせる
.PHONY: bench-all
bench-all:
	make build && make restart-app && make bench

# MySQL のスロークエリログを出力する（pt-query-digest）
.PHONY: show-sq
show-sq:
	@if [ -z "$(max_len)" ]; then \
		sudo pt-query-digest $(SLOW_QUERY_LOG); \
        else \
		sudo pt-query-digest --filter 'length($event->{arg}) <= $$(max_len)' $(SLOW_QUERY_LOG); \
        fi

# MySQL のスロークエリログを出力する（mysqldumpslow）
.PHONY: show-sq2
show-sq:
        sudo mysqldumpslow $(SLOW_QUERY_LOG) -s t -r

# Nginx のアクセスログを出力する
.PHONY: show-access
show-access:
	@if [ -z "$(ALP_REGEX)" ]; then \
		sudo cat $(ACCESS_LOG) | alp ltsv --sort=sum -r; \
	else \
		sudo cat $(ACCESS_LOG) | alp ltsv --sort=sum -r -m$(ALP_REGEX); \
	fi

# HTTP レスポンスのログを出力する
.PHONY: show-http-res
show-http-res:
	@if [ -z "$(req)" ]; then \
		cat $(HTTP_RESPONSE_LOG); \
	else \
		awk -v req="$(req)" ' \
			index($$0, req) { in_block=1 } \
			in_block { print } \
			index($$0, "HTTP Response Body: End") && in_block { in_block=0 } \
		' $(HTTP_RESPONSE_LOG); \
        fi

