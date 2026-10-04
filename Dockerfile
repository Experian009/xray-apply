FROM alpine:3.21

ARG XRAY_VERSION=v26.3.27

RUN apk add --no-cache ca-certificates curl gettext unzip \
    && curl -Ls "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" -o /tmp/xray.zip \
    && unzip -o /tmp/xray.zip -d /usr/local/bin/ \
    && rm -f /tmp/xray.zip \
    && chmod +x /usr/local/bin/xray \
    && xray version

COPY config.json.tmpl /etc/xray/config.json.tmpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
