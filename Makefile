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
	io.elementary.vala-lint \
		&& cd build \
		&& ninja \
		&& ninja install \
		&& G_MESSAGES_DEBUG=all io.trimir.journal \
		; cd -