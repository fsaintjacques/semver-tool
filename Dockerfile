FROM alpine:latest
LABEL maintainer="Manuel de la Peña"

RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add \
        bash && \
    rm -rf /var/cache/apk/*

ADD src/semver /usr/local/bin/semver

ARG BUILD_VERSION
ARG BUILD_DATE
ARG SCHEMA_NAME
ARG SCHEMA_VENDOR
ARG BUILD_VCS_REF
ARG BUILD_VCS_URL

LABEL org.label-schema.schema-version=$BUILD_VERSION \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name=$SCHEMA_NAME \
    org.label-schema.vcs-ref=$BUILD_VCS_REF \
    org.label-schema.vcs-ref=$BUILD_VCS_URL \
    org.label-schema.vendor=$SCHEMA_VENDOR \
    org.label-schema.version=$BUILD_VERSION

ENTRYPOINT ["semver"]
CMD [""]