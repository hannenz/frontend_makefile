# Makefile for Web Development

for Linux, OSX


## Prerequisites


On Ubuntu/Debian etc. install

Tools needed to install the tools:

- make
- git
- vala (should get rid of it)
- gcc
- npm
- homebrew (OSX)


## Make

Obvios ;-)


## Sass compiler

gsassc: A very fast C implementation of libsass:

[gsassc](https://github.com/hannenz/gsassc)

Needs: `libsass`, `glib`, build tools


```
# Ubuntu
sudo apt install libsass build-essential libsass libglib2.0-dev

# OSX
brew install libsass glib

git clone https://github.com/hannenz/gsassc
cd gsassc
make
sudo make install
cp svgmerge ~/.local/bin
```


## Image optmizers

- svgo: `npm install --global svgo`

- pngcrush `sudo apt install pngcrush` / `brew install pngcrush`

- jpegtran `npm install --global jpegtran`



## SVG Merger

- [svgmerge](https://github.com/hannenz/svgmerge)

Needs: Vala, glib

```
git clone https://github.com/hannenz/svgmerge
cd svgmerge
make
cp svgmerge ~/.local/bin
```


## Javascript uglyfier

- uglify-js `npm install uglilfy-js`


