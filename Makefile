.PHONY: all clean build push

# Hugo-related fields
HUGO=$(shell which hugo)
THEME="coder"
OUTPUT_DIR:=public

# Push-related fields
USER_EMAIL:="chip.senkbeil@gmail.com"
USER_NAME:="Chip Senkbeil"
REPO:="git@github.com:chipsenkbeil/chipsenkbeil.github.io.git"
BRANCH:="master"
DOMAIN:="chipsenkbeil.com"
CNAME:="$(DOMAIN)\nwww.$(DOMAIN)"
REV=$(shell git rev-parse --short HEAD)


all: clean build ## (Default) Cleans and builds website

help: ## Display help information
	@printf 'usage: make [target] ...\n\ntargets:\n'
	@egrep '^(.+)\:\ .*##\ (.+)' ${MAKEFILE_LIST} | sed 's/:.*##/#/' | column -t -c 2 -s '#'

clean: ## Removes contents inside output directory
	@rm -rf $(OUTPUT_DIR)/*

update: ## Updates theme and pulls latest changes from master repo
	@git pull origin master
	@git submodule update --remote --merge

update-theme: ## Updates theme from upstream, rather than origin
	@(cd themes/$(THEME) && git pull upstream master && git push origin HEAD:master)
	@git add themes/$(THEME)
	@git commit -m "Updated themes/$(THEME)"
	@git push origin master

build: ## Builds website
	@$(HUGO) --theme="$(THEME)"

serve: ## Runs server to test out website
	@$(HUGO) serve --theme="$(THEME)"

$(OUTPUT_DIR)/.git:
	mkdir -p $(OUTPUT_DIR) && \
	cd $(OUTPUT_DIR) && \
	git init && \
	git config user.email $(USER_EMAIL) && \
	git config user.name $(USER_NAME) && \
	git remote add upstream "$(REPO)" && \
	git fetch upstream && \
	git reset upstream/$(BRANCH)

push: clean $(OUTPUT_DIR)/.git build ## Cleans, builds, and publishes website
	cd $(OUTPUT_DIR) && \
	echo $(CNAME) > CNAME && \
	touch . && \
	git add -A && \
	git commit -m "Rebuilt pages at $(REV)" && \
	git push --force upstream HEAD:$(BRANCH)
