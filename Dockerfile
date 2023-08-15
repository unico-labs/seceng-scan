FROM unicoseceng/sast-cli:1.0.0

USER root

COPY entrypoint.sh /app/entrypoint.sh
COPY cleanup.sh /app/cleanup.sh

RUN ls -l /app/bin/

RUN chmod +x /app/entrypoint.sh \
    && chmod +x /app/cleanup.sh
