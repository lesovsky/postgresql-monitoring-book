SHELL = /bin/bash

all: help

# define target variable depending on target suffix
primary/%: TARGET = primary
standby/%: TARGET = standby
app1/%: TARGET = app1
app2/%: TARGET = app2
app3/%: TARGET = app3
app4/%: TARGET = app4

help: ## Display this help screen
		@echo "Makefile available targets:"
		@grep -h -E '^[a-zA-Z_/%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  * \033[36m%-16s\033[0m %s\n", $$1, $$2}'

up: ## Start playground environment
	docker-compose up -d

ps: ## Show current status of playground services
	docker-compose ps

down: ## Stop playground environment (without cleanup)
	docker-compose down

destroy: ## Stop playground environment and clean up related resources
	docker-compose down -v --rmi all

%/logs: ## Show service logs; % - service name, e.g. primary or standby
	docker-compose exec ${TARGET} /bin/bash -c 'cat $$(psql -U postgres -qAtX -c "select pg_current_logfile()")'

%/logs/tail: ## Tail service logs; % - service name, e.g. primary or standby
	docker-compose exec ${TARGET} /bin/bash -c 'tail -f $$(psql -U postgres -qAtX -c "select pg_current_logfile()")'

%/shell: ## Start shell session; % - service name, e.g. primary or standby
	docker-compose exec ${TARGET} /bin/bash

%/psql: ## Start psql session; % - service name, e.g. primary or standby
	docker-compose exec ${TARGET} psql -U postgres pgbench

%/pgcenter: ## Start pgcenter session; % - service name, e.g. primary or standby
	docker-compose exec ${TARGET} pgcenter top -U postgres pgbench
