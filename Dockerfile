FROM haskell:9.8.4 
WORKDIR /app 
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/* 
COPY . . 
# O diretório de trabalho é a raiz (onde está o book-tracker.cabal)
RUN cabal update && \
    cabal build && \
    cp "$(cabal list-bin book-tracker)" /usr/local/bin/book-tracker 
CMD ["book-tracker"]