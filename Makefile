.PHONY: clear

build:
	meson build --prefix=/usr

clear: 
	rm -rf build/

fresh:
	clear build

all:
	fresh yolo

yolo: 
	io.elementary.vala-lint ./src ./tests \
		&& cd build \
		&& ninja \
		&& ninja install \
		&& G_MESSAGES_DEBUG=all GTK_DEBUG=interactive com.github.matthiasjg.trimirjournal \
		; cd -

uninstall:
	cd build \
		&& sudo ninja uninstall \
		; cd -

test: 
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