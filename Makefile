.PHONY: all clean build push

# Hugo-related fields
HUGO=$(shell which hugo)
THEME="coder"
OUTPUT_DIR:="public/"

# Push-related fields
USER_EMAIL:="chip.senkbeil@gmail.com"
USER_NAME:="Chip Senkbeil"
REPO:="git@github.com:chipsenkbeil/chipsenkbeil.github.io.git"
BRANCH:="master"
DOMAIN:="chipsenkbeil.com"
CNAME:="$(DOMAIN)\nwww.$(DOMAIN)"
REV=$(shell git rev-parse --short HEAD)


all: clean build

clean:
	@rm -rf $(OUTPUT_DIR)

update:
	@git pull origin master
	@git submodule update --remote --merge

build:
	@$(HUGO) --theme="$(THEME)"

serve:
	@$(HUGO) serve --theme="$(THEME)"

push: build
	cd $(OUTPUT_DIR) && \
	git init && \
	git config user.email $(USER_EMAIL) && \
	git config user.name $(USER_NAME) && \
	git remote add upstream "$(REPO)" && \
	git fetch upstream && \
	git reset upstream/$(BRANCH) && \
	echo $(CNAME) > CNAME && \
	touch . && \
	git add -A && \
	git commit -m "Rebuilt pages at $(REV)" && \
	git push -q upstream HEAD:$(BRANCH)

