.PHONY: build 

COMPOSE = docker-compose

build: slanger

slanger:
	$(COMPOSE) build slanger

up:
	$(COMPOSE) up -d slanger

down:
	${COMPOSE} down

