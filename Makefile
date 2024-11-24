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

APP_NAME=isupipe-go.service

# MySQL を再起動する
.PHONY: restart-mysql
restart-mysql:
	sudo systemctl restart mysql

# MySQL にログインする
.PHONY: mysql
mysql:
	mysql -h$(MYSQL_HOST) -P$(MYSQL_PORT) -u$(MYSQL_USER) -p$(MYSQL_PASS)

# MySQL のスロークエリのログを空にする
.PHONY: clear-sq
clear-sq:
	sudo truncate -s 0 $(SLOW_QUERY_LOG)

# Nginx のアクセスログを空にする
.PHONY: clear-access
clear-access:
	sudo truncate -s 0 $(ACCESS_LOG)

# ログを空にする
.PHONY: clear-all
clear-all:
	make clear-sq && make clear-access

# Go アプリケーションを build する
.PHONY: build
build:
	cd ~/webapp/go && make build

# Go アプリケーションを restart する
.PHONY: restart-app
restart-app:
	sudo systemctl restart $(APP_NAME)

# bench を走らせる
.PHONY: bench
bench:
	make clear-all && cd ~ && ./bench run --enable-ssl

# Go アプリケーションを build して bench を走らせる
.PHONY: bench-all
bench-all:
	make build && make restart-app && make bench

# MySQL のスロークエリを出力する
.PHONY: show-sq
show-sq:
	sudo mysqldumpslow $(SLOW_QUERY_LOG) -s t -r

# Nginx のアクセスログを出力する
.PHONY: show-access
show-access:
	sudo cat $(ACCESS_LOG) | alp ltsv --sort=sum -r -m $(ALP_REGEX)

