PROJECT_NAME:=myproject
PROJECT_DIR:=$(CURDIR)

# Programs and tool
SASS_COMPILER:=gsassc
JS_COMPRESSOR:=yui-compressor
SVG_OPTIMIZER:=svgo
SVGO_OPTIONS:=--quiet --enable=removeStyleElement --disable=cleanupIDs
SVG_MERGER:=svgmerge
SVGMERGE_OPTIONS:=--prefix=icon-
PNG_OPTIMIZER:=pngcrush
PNG_OPTIMIZER_OPTIONS:=-q
JPG_OPTIMIZER:=jpegtran
JPG_OPTIMIZER_OPTIONS:=-copy none -optimize

# Paths
JS_SRC_DIR:=src/js
JS_DEST_DIR:=js

CSS_SRC_DIR:=src/sass
CSS_DEST_DIR:=css

ICON_SRC_DIR:=src/icons
ICON_DEST_FILE:=img/defs.svg

SVG_SRC_DIR:=src/svg
SVG_DEST_DIR:=img

PNG_SRC_DIR:=src/img
PNG_DEST_DIR:=img

JPG_SRC_DIR:=src/img
JPG_DEST_DIR:=img

GIF_SRC_DIR:=src/img
GIF_DEST_DIR:=img

BACKUP_DIR:=/tmp
# Specify directories under /client/src to be copied directly (No trailing slashes!!)

COPYDIRS = js/vendor 

# Database
DB_NAME:=dbname
DB_USER:=dbuser
DB_PASSWORD:=secret

# Deploy Staging
# STAGING_DIR:=/var/www/halma
# STAGING_DB_NAME:=
# STAGING_DB_USER:=
# STAGING_DB_PASSWORD:=secret

# Deploy Production
# PRODUCTION_DIR:=
# PRODUCTION_DB_NAME:=
# PRODUCTION_DB_USER:=
# PRODUCTION_DB_PASSWORD:=

# Environment
DATE:=$(shell date +%F-%H%M)
HOSTNAME:=$(shell hostname)

PNG_SRC_FILES:=$(shell find $(PNG_SRC_DIR) -type f -iname '*.png')
PNG_DEST_FILES:=$(patsubst $(PNG_SRC_DIR)/%.png, $(PNG_DEST_DIR)/%.png, $(PNG_SRC_FILES))
JPG_SRC_FILES:=$(shell find $(JPG_SRC_DIR) -type f -iname '*.jpg')
JPG_DEST_FILES:=$(patsubst $(JPG_SRC_DIR)/%.jpg, $(JPG_DEST_DIR)/%.jpg, $(JPG_SRC_FILES))
GIF_SRC_FILES:=$(shell find $(GIF_SRC_DIR) -type f -iname '*.gif')
GIF_DEST_FILES:=$(patsubst $(GIF_SRC_DIR)/%.gif, $(GIF_DEST_DIR)/%.gif, $(GIF_SRC_FILES))
SVG_SRC_FILES:=$(shell find $(SVG_SRC_DIR) -type f -iname '*.svg')
SVG_DEST_FILES:=$(patsubst $(SVG_SRC_DIR)/%.svg, $(SVG_DEST_DIR)/%.svg, $(SVG_SRC_FILES))
ICON_SRC_FILES:=$(shell find $(ICON_SRC_DIR) -type f -iname '*.svg')
ICON_OPT_FILES:=$(addsuffix o, $(ICON_SRC_FILES))

CSS_SRC_FILES:=$(shell find $(CSS_SRC_DIR) -type f -iname '*.scss')
JS_SRC_FILES:=$(shell ls $(JS_SRC_DIR)/*.js)

# Function for colored output

define colorecho
	@tput setaf $1
	@echo $2
	@tput sgr0
endef

all: css js icons svg png jpg gif $(COPYDIRS)

# -----------------------
# CSS / SASS
# -----------------------

css: $(CSS_DEST_DIR)/main.css
	$(call colorecho, 3, $(shell du -BK $@))

$(CSS_DEST_DIR)/main.css: $(CSS_SRC_DIR)/main.scss $(CSS_SRC_FILES)
	@mkdir -p $(CSS_DEST_DIR)
	$(call colorecho, 3, "Compiling $@");
	@-$(SASS_COMPILER) -t compressed -o $@ $< \
			&& ([ $$? -eq 0 ] && (tput setaf 2; echo ✔ Compilation succeeded; tput sgr0))\
			|| (tput setaf 1; tput bold; echo ✖ Compilation failed; tput  sgr0)

	

# -----------------------
# JAVASCRIPT
# -----------------------

js: $(JS_DEST_DIR)/main.min.js
	$(call colorecho, 2, $(shell du -BK $@))

$(JS_DEST_DIR)/main.min.js: $(JS_SRC_FILES)
	$(call colorecho, 3, "Compiling $@")
	@mkdir -p $(JS_DEST_DIR)
	@-cat $^ | $(JS_COMPRESSOR) --type js -o $@ \
			&& ([ $$? -eq 0 ] && (tput setaf 2; echo ✔ Compilation succeeded; tput sgr0))\
			|| (tput setaf 1; tput bold; echo ✖ Compilation failed; tput  sgr0)


#--------------------------
# ICONS
# -------------------------

icons:		$(ICON_OPT_FILES) $(ICON_DEST_FILE)
	$(call colorecho, 2, $(shell du -BK $(ICON_DEST_FILE)))

$(ICON_DEST_FILE): 	$(ICON_OPT_FILES)
	@mkdir -p img
	$(call colorecho, 3, "Compiling icons file: $@")
	@-$(SVG_MERGER) $(SVGMERGE_OPTIONS) -o $@ $^ \
			&& ([ $$? -eq 0 ] && (tput setaf 2; echo ✔ Compilation succeeded; tput sgr0))\
			|| (tput setaf 1; tput bold; echo ✖ Compilation failed; tput  sgr0)
	@-sed '1d' -i $@

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
	$(call colorecho, 7, $(shell du -BK $<))
	@$(SVG_OPTIMIZER) $(SVGO_OPTIONS) -i $< -o $@ && (tput setaf 2; du -BK $@ ; tput sgr0)


# -----------------------
# IMAGES (PNG, JPG) 
#  ----------------------

png: 	$(PNG_DEST_FILES)

$(PNG_DEST_DIR)/%.png : $(PNG_SRC_DIR)/%.png
	@mkdir -p $(PNG_DEST_DIR)
	$(call colorecho, 3, "Optimizing file: $@")
	$(call colorecho, 7, $(shell du -BK $<))
	@$(PNG_OPTIMIZER) $(PNG_OPTIMIZER_OPTIONS) $< $@ && (tput setaf 2; du -BK $@ ; tput sgr0)

jpg: 	$(JPG_DEST_FILES)

$(JPG_DEST_DIR)/%.jpg : $(JPG_SRC_DIR)/%.jpg
	@mkdir -p $(JPG_DEST_DIR)
	$(call colorecho, 3, "Optimizing file: $@")
	$(call colorecho, 7, $(shell du -BK $<))
	@$(JPG_OPTIMIZER) $(JPG_OPTIMIZER_OPTIONS) -outfile $@ $< && (tput setaf 2; du -BK $@ ; tput sgr0)

gif: 	$(GIF_DEST_FILES)

$(GIF_DEST_DIR)/%.gif : $(GIF_SRC_DIR)/%.gif
	@mkdir -p $(GIF_DEST_DIR)
	$(call colorecho, 3, "Copying file: $@")
	@cp -a $< $@ 

# -----------------------
# Directly copy files
# ----------------------

copy: $(COPYDIRS)
$(COPYDIRS):
	@echo "Copying dir: $@"
	@mkdir -p $@
	@rsync -rupE src/$@/ $@



# -----------------------
# BACKUP & DEPLOY
# -----------------------

backup:
	$(call colorecho, 7, "Creating Backup at $(BACKUP_DIR)")
	@mkdir -p $(BACKUP_DIR)/$(PROJECT_NAME)/$(DATE)
	$(call colorecho, 3, "Creating SQL Dump")
	@mysqldump -u $(DB_USER) -p$(DB_PASSWORD) $(DB_NAME) | gzip > $(BACKUP_DIR)/$(PROJECT_NAME)/$(DATE)/$(DB_NAME).$(HOSTNAME).$(DATE).sql.gz
	$(call colorecho, 3, "Copying files")
	@rsync -a ./ $(BACKUP_DIR)/$(PROJECT_NAME)/$(DATE)/ --exclude-from=".backup-excludes"
	$(call colorecho, 3, "Creating Archive")
	@tar cfz $(BACKUP_DIR)/$(PROJECT_NAME).$(HOSTNAME).$(DATE).tar.gz $(BACKUP_DIR)/$(PROJECT_NAME)/$(DATE)/
	$(call colorecho, 3, "Cleaning up")
	@rm -rf $(BACKUP_DIR)/$(PROJECT_NAME).$(HOSTNAME).$(DATE)

deploy:
	@echo "Deploying to $(DEPLOY)


deploy-staging:
	@echo "Deploying to Staging"
	@ssh tom "mkdir -p /var/www/$(PROJECT_NAME)"
	@rsync -ave ssh $(PROJECT_DIR)/ tom:/var/www/$(PROJECT_NAME)/ --exclude-from=".deploy_excludes"
	mysqldump -u $(DB_USER) -p$(DB_PASSWORD) $(DB_NAME) | ssh tom "mysql -u $(STAGING_DB_USER) -p$(STAGING_DB_PASSWORD) $(STAGING_DB_NAME)"

clean:
	@echo "Cleaning up"
	@rm -Rf $(JS_DEST_DIR)
	@rm -Rf $(CSS_DEST_DIR)
	@rm -Rf src/icons/*.svgo
	@rm -Rf src/svg/*.svgo
	@rm -Rf $(PNG_DEST_FILES)
	@rm -Rf $(JPEG_DEST_FILES)
	@rm -Rf $(SVG_DEST_DIR)

rebuild: clean all


.PHONY: css js png jpg svg gif client clean rebuild copy $(COPYDIRS) deploy deploy-staging backup icons
