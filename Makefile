APP_NAME=isupipe-go.service

# Go アプリケーションを build する
.PHONY: build
build:
	cd ~/webapp/go && make build && cd ~

# Go アプリケーションを restart する
.PHONY: restart-app
restart-app:
	sudo systemctl restart $(APP_NAME)

# bench を走らせる
.PHONY: bench
bench:
	cd ~ && ./bench run --enable-ssl

# Go アプリケーションを build して bench を走らせる
.PHONY: bench-all
bench-all:
	make build && make restart-app && make bench

