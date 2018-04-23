
# Following https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example

.PHONY: all clean build push

USER_NAME:="Chip Senkbeil"
USER_EMAIL:="chip.senkbeil+travis@gmail.com"
OUTPUT_DIR:="public/"

BRANCH:="master"
REPO:="github.com/chipsenkbeil/chipsenkbeil.github.io.git"

DOMAIN:="chipsenkbeil.com"
CNAME:="$(DOMAIN)\nwww.$(DOMAIN)"

# Used to generate videos with the specified dimensions
# Format is WIDTHxHEIGHT and will be converted to proper ffmpeg format
# VIDEO_SIZE will set dimension for all but 3GP
VIDEO_SIZE:="480x320"
VIDEO_SIZE_MP4:=$(VIDEO_SIZE)
VIDEO_SIZE_WEBM:=$(VIDEO_SIZE)
VIDEO_SIZE_OGV:=$(VIDEO_SIZE)
VIDEO_SIZE_FLV:=$(VIDEO_SIZE)
VIDEO_SIZE_3GP:="352x288"

# This is rerun every time it is accessed
REV=$(shell git rev-parse --short HEAD)

all: clean build

clean:
	rm -rf $(OUTPUT_DIR)

# Function to generate an output video from an input
# arg1: Input video file
# arg2: Scale in the form of WIDTHxHEIGHT
# arg3: Output video extension
generate_video=ffmpeg -i "$(1)" -vf scale="$(subst x,:,$(2))" "$(basename $1)_$(2)$(3)"

# Generates mp4, webm, ogv, flv, and 3gp using provided scales
# arg1: Input video file
generate_all=\
	$(call generate_video,$(1),$(VIDEO_SIZE_MP4),".mp4") &&\
	$(call generate_video,$(1),$(VIDEO_SIZE_WEBM),".webm") &&\
	$(call generate_video,$(1),$(VIDEO_SIZE_OGV),".ogv") &&\
	$(call generate_video,$(1),$(VIDEO_SIZE_FLV),".flv") &&\
	$(call generate_video,$(1),$(VIDEO_SIZE_3GP),".3gp")

generate:
	$(foreach \
		mp4,\
		$(abspath $(wildcard ./$(GEN_DIR)/*.mp4)),\
		$(call generate_all,$(mp4))\
	)

update:
	git pull origin master
	(cd themes/coder/ && git checkout master && git pull origin master)

build:
	$(GOPATH)/bin/hugo --theme="coder"

push:
	cd $(OUTPUT_DIR) && \
	git init && \
	git config user.email $(USER_EMAIL) && \
	git config user.name $(USER_NAME) && \
	git remote add upstream "https://$(GH_TOKEN)@$(REPO)" && \
	git fetch upstream && \
	git reset upstream/$(BRANCH) && \
	echo $(CNAME) > CNAME && \
	touch . && \
	git add -A && \
	git commit -m "Rebuilt pages at $(REV)" && \
	git push -q upstream HEAD:$(BRANCH)

