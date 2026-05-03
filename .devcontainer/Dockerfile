FROM haskell:9.8.4

# Instala as dependências do sistema necessárias para o desenvolvimento e o banco de dados
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev \
    pkg-config \
    git \
    curl \
 && rm -rf /var/lib/apt/lists/*