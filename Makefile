#############################################################
#
#  Web Dev Makefile
#  See: https://github.com/hannenz/frontend_makefile
#
#############################################################

PROJECT_NAME:=myproject
PROJECT_DIR:=$(CURDIR)



##############################
#  Programs, tools & options #
##############################

SASS_COMPILER:=gsassc
# You might want to add include paths like e.g. `-I node_modules/foundation/scss:another/path`
SASS_COMPILER_OPTIONS:=--style compressed --source-map


JS_COMPRESSOR:=uglifyjs
JS_COMPRESSOR_OPTIONS:=--compress --

SVG_OPTIMIZER:=svgo
SVGO_OPTIONS:=--quiet --enable=removeStyleElement --disable=cleanupIDs
SVG_MERGER:=svgmerge
SVGMERGE_OPTIONS:=--prefix=icon-

PNG_OPTIMIZER:=pngcrush
PNG_OPTIMIZER_OPTIONS:=-q
JPG_OPTIMIZER:=jpegtran
JPG_OPTIMIZER_OPTIONS:=-copy none -optimize



###########
#  Paths  #
###########

SRC:=src
DIST:=dist

JS_SRC_DIR:=$(SRC)/js
JS_DEST_DIR:=$(DIST)/js

CSS_SRC_DIR:=$(SRC)/css
CSS_DEST_DIR:=$(DIST)/css

ICON_SRC_DIR:=$(SRC)/icons
ICON_DEST_FILE:=$(DIST)/img/symbols.svg

SVG_SRC_DIR:=$(SRC)/img
SVG_DEST_DIR:=$(DIST)/img

PNG_SRC_DIR:=$(SRC)/img
PNG_DEST_DIR:=$(DIST)/img

JPG_SRC_DIR:=$(SRC)/img
JPG_DEST_DIR:=$(DIST)/img

GIF_SRC_DIR:=$(SRC)/img
GIF_DEST_DIR:=$(DIST)/img

COPYDIRS = fonts

# Vendor files to be copied
# You might want to add stuff like `node_modules/jquery/dist/jquery.min.js`
JS_VENDOR_FILES = $(shell find $(JS_SRC_DIR)/vendor -type f -iname '*.js'))
CSS_VENDOR_FILES = $(shell find $(CSS_SRC_DIR)/vendor -type f -iname '*.css'))
JS_VENDOR_DEST = $(DIST)/js/vendor
CSS_VENDOR_DEST = $(DIST)/css/vendor



# Environment
DATE:=$(shell date +%F-%H%M)
HOSTNAME:=$(shell hostname)
GIT_COMMIT:=$(shell git rev-parse --short HEAD)
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)



##################
#  Source files  #
##################

PNG_SRC_FILES:=$(shell find $(PNG_SRC_DIR) -type f -iname '*.png' 2>/dev/null)
PNG_DEST_FILES:=$(patsubst $(PNG_SRC_DIR)/%.png, $(PNG_DEST_DIR)/%.png, $(PNG_SRC_FILES))
JPG_SRC_FILES:=$(shell find $(JPG_SRC_DIR) -type f -iname '*.jpg' 2>/dev/null)
JPG_DEST_FILES:=$(patsubst $(JPG_SRC_DIR)/%.jpg, $(JPG_DEST_DIR)/%.jpg, $(JPG_SRC_FILES))
GIF_SRC_FILES:=$(shell find $(GIF_SRC_DIR) -type f -iname '*.gif' 2>/dev/null)
GIF_DEST_FILES:=$(patsubst $(GIF_SRC_DIR)/%.gif, $(GIF_DEST_DIR)/%.gif, $(GIF_SRC_FILES))
SVG_SRC_FILES:=$(shell find $(SVG_SRC_DIR) -type f -iname '*.svg' 2>/dev/null)
SVG_DEST_FILES:=$(patsubst $(SVG_SRC_DIR)/%.svg, $(SVG_DEST_DIR)/%.svg, $(SVG_SRC_FILES))
ICON_SRC_FILES:=$(shell find $(ICON_SRC_DIR) -type f -iname '*.svg' 2>/dev/null)
ICON_OPT_FILES:=$(addsuffix o, $(ICON_SRC_FILES))

CSS_SRC_FILES:=$(shell find $(CSS_SRC_DIR) -type f -iname '*.scss')
JS_SRC_FILES:=$(shell ls $(JS_SRC_DIR)/*.js)



# Function for colored output

define colorecho
	@tput setaf $1
	@echo $2
	@tput sgr0
endef



############
#  Banner  #
############

BANNER:=\
	"/**\n"\
	" * @project       $(PROJECT_NAME)\n"\
	" * @author        Johannes Braun <j.braun@agentur-halma.de>\n"\
	" * @build         $(DATE)\n"\
	" * @release       $(GIT_COMMIT) [$(GIT_BRANCH)]\n"\
	" * @copyright     Copyright (c) " $(shell date +%Y) ", <HALMA GmbH & Co. KG>\n"\
	" */\n"\
	"\n"



all: css js icons svg png jpg gif $(COPYDIRS) $(JS_VENDOR_FILES) $(CSS_VENDOR_FILES)



# -----------------------
# CSS / SASS
# -----------------------

css: $(CSS_DEST_DIR)/main.css
	$(call colorecho, 3, $(shell du -h $^))

$(CSS_DEST_DIR)/main.css: $(CSS_SRC_DIR)/main.scss $(CSS_SRC_FILES)
	@mkdir -p $(CSS_DEST_DIR)
	$(call colorecho, 3, "Compiling $@");
	@-(printf "%b" $(BANNER) ; $(SASS_COMPILER) $(SASS_COMPILER_OPTIONS) $<) > $@



# -----------------------
# JAVASCRIPT
# -----------------------

js: $(JS_DEST_DIR)/main.min.js
	$(call colorecho, 2, $(shell du -h $^))

$(JS_DEST_DIR)/main.min.js: $(JS_SRC_FILES)
	$(call colorecho, 3, "Compressing $@")
	@mkdir -p $(JS_DEST_DIR)
	(printf "%b" $(BANNER); $(JS_COMPRESSOR) $(JS_COMPRESSOR_OPTIONS) $^) > $@ 



# -------------------------
# ICONS
# -------------------------

icons:		$(ICON_OPT_FILES) $(ICON_DEST_FILE)
	$(call colorecho, 2, $(shell du -h $(ICON_DEST_FILE)))

$(ICON_DEST_FILE): 	$(ICON_OPT_FILES)
	@mkdir -p $(DIST)/img
	$(call colorecho, 3, "Compiling icons file: $@")
	@-$(SVG_MERGER) $(SVGMERGE_OPTIONS) -o $@ $^ \
			&& ([ $$? -eq 0 ] && (tput setaf 2; echo ✔ Compilation succeeded; tput sgr0))\
			|| (tput setaf 1; tput bold; echo ✖ Compilation failed; tput  sgr0)
	# On OSX .bak is needed when using sed -i, so we create the backup and remove it immediately
	@-sed -i .bak '1d' $@
	@-rm $@.bak

%.svgo: %.svg
	$(call colorecho, 3, "Optimizing icon file: $@")
	@$(SVG_OPTIMIZER) $(SVGO_OPTIONS) -i $^ -o $@



# -----------------------
#  SVG
#  ----------------------

svg:	$(SVG_DEST_FILES)

$(SVG_DEST_DIR)/%.svg : $(SVG_SRC_DIR)/%.svg
	@mkdir -p $(SVG_DEST_DIR)
	$(call colorecho, 3, "Optimizing file: $@")
	$(call colorecho, 7, $(shell du -h $<))
	@$(SVG_OPTIMIZER) $(SVGO_OPTIONS) -i $< -o $@ && (tput setaf 2; du -h $@ ; tput sgr0)



# -----------------------
# IMAGES (PNG, JPG)
#  ----------------------

png: 	$(PNG_DEST_FILES)

$(PNG_DEST_DIR)/%.png : $(PNG_SRC_DIR)/%.png
	@mkdir -p $(PNG_DEST_DIR)
	$(call colorecho, 3, "Optimizing file: $@")
	$(call colorecho, 7, $(shell du -h $<))
	@$(PNG_OPTIMIZER) $(PNG_OPTIMIZER_OPTIONS) $< $@ && (tput setaf 2; du -h $@ ; tput sgr0)



jpg: 	$(JPG_DEST_FILES)

$(JPG_DEST_DIR)/%.jpg : $(JPG_SRC_DIR)/%.jpg
	@mkdir -p $(JPG_DEST_DIR)
	$(call colorecho, 3, "Optimizing file: $@")
	$(call colorecho, 7, $(shell du -h $<))
	@$(JPG_OPTIMIZER) $(JPG_OPTIMIZER_OPTIONS) -outfile $@ $< && (tput setaf 2; du -h $@ ; tput sgr0)



gif: 	$(GIF_DEST_FILES)

$(GIF_DEST_DIR)/%.gif : $(GIF_SRC_DIR)/%.gif
	@mkdir -p $(GIF_DEST_DIR)
	$(call colorecho, 3, "Copying file: $@")
	@cp -a $< $@



# -----------------------
# Directly copy files
# Copies from $(SRC) to $(DIST)
# ----------------------

copy: $(COPYDIRS)
$(COPYDIRS):
	@echo "Copying dir: $@"
	@mkdir -p $@
	@rsync -rupE $(SRC)/$@/ $(DIST)/$@



# -----------------------
# Copy vendor files
# -----------------------

jsvendor: $(JS_VENDOR_FILES)
$(JS_VENDOR_FILES):
	@echo "Copying js vendor file: $@"
	@cp -af $@ $(JS_VENDOR_DEST)



cssvendor: $(CSS_VENDOR_FILES)
$(CSS_VENDOR_FILES):
	@echo "Copying css vendor file: $@"
	@cp -af $@ $(CSS_VENDOR_DEST)



clean:
	@echo "Cleaning up"
	@rm -Rf $(DIST)
	@rm -Rf $(SRC)/icons/*.svgo
	@rm -Rf $(SRC)/svg/*.svgo

rebuild: clean all



.PHONY: css js png jpg svg gif client clean rebuild copy jsvendor cssvendor icons $(COPYDIRS) $(JS_VENDOR_FILES) $(CSS_VENDOR_FILES)
