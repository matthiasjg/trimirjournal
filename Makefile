.PHONY: default
default: yolo ;

build:
	meson build --prefix=/usr

clear: 
	rm -rf build/

fresh:
	clear build

yolo: 
	io.elementary.vala-lint \
		&& cd build \
		&& ninja \
		&& ninja install \
		&& G_MESSAGES_DEBUG=all io.trimir.journal \
		; cd -