FROM klakegg/hugo:0.85.0-ext-ubuntu AS builder

ARG TRAINING_HUGO_ENV=default

COPY . /src

RUN hugo --environment ${TRAINING_HUGO_ENV} --minify

FROM pandoc/alpine-latex:2.14.0.3 AS pandoc

COPY --from=builder /src/public /data

RUN pandoc /data/pdf/index.html -o /data/pdf/pandoc.pdf

FROM ubuntu:focal AS wkhtmltopdf
RUN apt-get update \
    && apt-get install -y curl \
    && curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb --output wkhtmltox_0.12.6-1.focal_amd64.deb \
    && ls -la \
    && apt-get install -y /wkhtmltox_0.12.6-1.focal_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /wkhtmltox_0.12.6-1.focal_amd64.deb

COPY --from=builder /src/public /

RUN wkhtmltopdf --outline-depth 4 --enable-internal-links --enable-local-file-access  ./pdf/index.html /wkhtmltopdf.pdf

FROM nginxinc/nginx-unprivileged:1.21-alpine

EXPOSE 8080

COPY --from=builder /src/public /usr/share/nginx/html
COPY --from=pandoc /data/pdf/pandoc.pdf /usr/share/nginx/html/pdf/pandoc.pdf
COPY --from=wkhtmltopdf /wkhtmltopdf.pdf /usr/share/nginx/html/pdf/wkhtmltopdf.pdf
