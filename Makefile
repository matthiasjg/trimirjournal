.PHONY: all clear fresh yolo

all: fresh yolo

build:
	meson build --prefix=/usr

clear: 
	rm -rf build/

fresh: clear build

ninja-build: build
	io.elementary.vala-lint ./src ./tests \
		&& cd build \
		&& ninja \
		; cd -

ninja-install: 
	cd build \
		&& ninja install \
		; cd -

ninja-run: 
	G_MESSAGES_DEBUG=all GTK_DEBUG=interactive com.github.matthiasjg.trimirjournal

ninja-uninstall:
	cd build \
		&& ninja uninstall \
		; cd -

test: fresh
	io.elementary.vala-lint ./src ./tests \
		&& cd build \
		&& ninja test \
		; cd -

i18n:
	cd build \
		&& ninja com.github.matthiasjg.trimirjournal-pot \
		&& ninja com.github.matthiasjg.trimirjournal-update-po \
		; cd -

flatpak-build:
	flatpak-builder \
		build com.github.matthiasjg.trimirjournal.yml --user --install --force-clean

flatpak-run: 
	flatpak run com.github.matthiasjg.trimirjournal

yolo: flatpak-build flatpak-run