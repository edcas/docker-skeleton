CONTAINER_PHP=php
FOLDER_PATH=/var/www/html
COMPOSER_OPTIONS=-n -a --prefer-dist --no-suggest
UID=$(shell id -u)

.PHONY: config
config:
	docker-compose -f docker-compose.yml -f docker-compose.deploy.yml config

.PHONY: up
up:
	docker-compose -f docker-compose.yml -f docker-compose.deploy.yml up -d

.PHONY: down
down:
	docker-compose -f docker-compose.yml -f docker-compose.deploy.yml down -v

.PHONY: restart
restart: down up

.PHONY: rebuild
rebuild: down
	docker-compose -f docker-compose.yml -f docker-compose.deploy.yml up -d --build
	make install

.PHONY: bash
bash:
	docker exec -u www-data -it $(CONTAINER_PHP) sh

.PHONY: logs
logs:
	docker logs $(CONTAINER_PHP) -f

.PHONY: exist-env
exist-env:
	[ ! -f .env ] && echo "We need .env file, please create it." || echo "Environment file found, continue"

.PHONY: install
install: exist-env dev-down up
	docker exec -u www-data -it $(CONTAINER_PHP) composer install --no-dev $(COMPOSER_OPTIONS) || exit 0
	docker exec -u www-data -it $(CONTAINER_PHP) php artisan key:generate || exit 0
	@echo "That is all!"

.PHONY: dev-config
dev-config: exist-env
	docker-compose config

.PHONY: dev-up
dev-up: exist-env
	docker-compose up -d

.PHONY: dev-down
dev-down:
	docker-compose down

.PHONY: dev-restart
dev-restart: dev-down dev-up

.PHONY: dev-rebuild
dev-rebuild: dev-down
	docker-compose up -d --build
	make dev-install

.PHONY: dev-bash
dev-bash: bash

.PHONY: dev-logs
dev-logs: logs

.PHONY: dev-install
dev-install: exist-env down add-user dev-up
	sudo setfacl -dR -m u:www-data:rwX -m u:`whoami`:rwX `pwd`
	sudo setfacl -R -m u:www-data:rwX -m u:`whoami`:rwX `pwd`
	docker exec -u $(USER) -it $(CONTAINER_PHP) composer install $(COMPOSER_OPTIONS) || exit 0
	docker exec -u $(USER) -it $(CONTAINER_PHP) php artisan key:generate || exit 0
	docker exec -u $(USER) -it $(CONTAINER_PHP) php artisan migrate || exit 0
	@echo "Happy development!"

.PHONY: add-user
add-user: dev-up
	docker exec -u root -it $(CONTAINER_PHP) adduser -D -u $(UID) -G www-data $(USER)

.PHONY: dev-update
dev-update:
	docker exec -u $(USER) -it $(CONTAINER_PHP) composer update $(DEP) || exit 0

.PHONY: tests
tests:
	docker exec -u www-data -it $(CONTAINER_PHP) vendor/bin/phpunit || exit 0