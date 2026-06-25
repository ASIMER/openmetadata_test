# =============================================================================
# OpenMetadata server — standalone image.
#
# Bundles ONLY the OpenMetadata server. It connects to your EXTERNAL, already
# deployed PostgreSQL, Elasticsearch/OpenSearch and (optionally) Airflow —
# entirely through environment variables. Nothing else is included.
#
# Build:
#   docker build --build-arg OPENMETADATA_VERSION=1.10.0 \
#     -t <your-registry>/openmetadata-server:1.10.0 server-image
#
# Run:
#   docker run --env-file .env -p 8585:8585 <your-registry>/openmetadata-server:1.10.0
#
# All start parameters are environment variables — see .env.example / README.md.
# =============================================================================
ARG OPENMETADATA_VERSION=1.10.0
FROM docker.getcollate.io/openmetadata/server:${OPENMETADATA_VERSION}

# Thin entrypoint: optionally run DB migrations, then start the server in one container.
USER root
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
USER openmetadata

WORKDIR /opt/openmetadata

# Run DB migrations automatically on startup. Set to "false" to manage migrations
# separately (e.g. a one-shot `docker run ... migrate` job before rollout).
ENV OM_MIGRATE_ON_START=true

EXPOSE 8585 8586

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=15 \
  CMD wget -q --spider http://localhost:8586/healthcheck || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["server"]
