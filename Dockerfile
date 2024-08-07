FROM docker.io/floryn90/hugo:0.131.0-ext-ubuntu AS builder

ARG TRAINING_HUGO_ENV=default

COPY . /src

RUN hugo --environment ${TRAINING_HUGO_ENV} --minify

FROM docker.io/ubuntu:noble AS wkhtmltopdf
RUN apt-get update \
    && apt-get install -y curl \
    && curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb --output wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && ls -la \
    && apt-get install -y /wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /wkhtmltox_0.12.6.1-2.jammy_amd64.deb

COPY --from=builder /src/public /

RUN wkhtmltopdf --enable-internal-links --enable-local-file-access \
    --margin-top 35mm --margin-bottom 22mm --margin-left 15mm --margin-right 10mm \
    --enable-internal-links --enable-local-file-access \
    --header-html /pdf/header/index.html --footer-html /pdf/footer/index.html \
    /pdf/index.html /pdf.pdf

FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine

LABEL maintainer acend.ch
LABEL org.opencontainers.image.title "acend.ch's CHANGEME Basics Training"
LABEL org.opencontainers.image.description "Container with acend.ch's CHANGEME Training content"
LABEL org.opencontainers.image.authors acend.ch
LABEL org.opencontainers.image.source https://github.com/acend/changeme-training/
LABEL org.opencontainers.image.licenses CC-BY-SA-4.0

EXPOSE 8080

COPY --from=builder /src/public /usr/share/nginx/html
COPY --from=wkhtmltopdf /pdf.pdf /usr/share/nginx/html/pdf/pdf.pdf
