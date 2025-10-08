FROM --platform=linux/amd64 packetstream/psclient:latest AS source_amd64

FROM --platform=linux/arm64 packetstream/psclient:latest AS source_arm64

FROM --platform=linux/i386 packetstream/psclient:latest AS source_i386

FROM --platform=linux/arm/v7 packetstream/psclient:latest AS source_arm

FROM alpine:latest AS final

WORKDIR /app

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates ca-certificates-bundle unzip curl bash dos2unix tzdata iptables redsocks \
    && update-ca-certificates

COPY --from=source_amd64 /usr/local/bin/linux_amd64/psclient /app/amd64/psclient

COPY --from=source_arm64 /usr/local/bin/linux_arm64/psclient /app/arm64/psclient

COPY --from=source_i386 /usr/local/bin/linux_386/psclient /app/386/psclient

COPY --from=source_arm /usr/local/bin/linux_arm/psclient /app/arm/psclient

COPY entrypoint.sh /app/entrypoint.sh

RUN dos2unix /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh \
             /app/amd64/psclient \
             /app/arm64/psclient \
             /app/386/psclient \
             /app/arm/psclient

ENTRYPOINT ["/app/entrypoint.sh"]