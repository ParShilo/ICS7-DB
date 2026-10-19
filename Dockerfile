FROM postgres:16

RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-plpython3-16 \
 && rm -rf /var/lib/apt/lists/*