.PHONY: yolo

yolo: 
	io.elementary.vala-lint \
		&& cd build \
		&& ninja \
		&& ninja install \
		&& G_MESSAGES_DEBUG=all io.trimir.journal \
		; cd -