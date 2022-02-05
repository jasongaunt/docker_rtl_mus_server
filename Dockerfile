FROM alpine:latest

COPY init.sh /root/init.sh
RUN \
	chmod +x /root/init.sh && \
	apk add --no-cache libusb librtlsdr git python2 && \
	git clone https://github.com/ha7ilm/rtl_mus.git /root/rtl_mus

EXPOSE 7373/tcp

ENTRYPOINT ["/root/init.sh"]
