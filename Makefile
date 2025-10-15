compose_file := ./srcs/docker-compose.yml
volume_dirs  := /home/copireyr/data/mariadb /home/copireyr/data/wp

.PHONY: all
all: volumes
	cat ./srcs/.env > /dev/null
	docker compose -f $(compose_file) up --build -d

.PHONY: up
up: all

volumes:
	mkdir -p $(volume_dirs)

.PHONY: down
down:
	docker compose -f $(compose_file) down

.PHONY: clean
clean: down
	docker compose -f $(compose_file) down -v
	@$(RM) -r $(volume_dirs) 2> /dev/null || true

.PHONY: fclean
fclean: clean
	yes | docker system prune
