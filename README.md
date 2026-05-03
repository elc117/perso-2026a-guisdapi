# Book Tracker - Gerenciador de Leitura em Haskell

[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/xDmvZ4it)

Este projeto é um sistema para gerenciar listas de leitura, desenvolvido como parte da disciplina de **Paradigmas de Programação** (UFSM). A aplicação utiliza o framework **Scotty** para fornecer uma API Web RESTful, com foco na aplicação de conceitos de programação funcional isolados dos efeitos colaterais de I/O.

## Tecnologias Utilizadas

* **Linguagem:** Haskell
* **Framework Web:** [Scotty](https://hackage.haskell.org/package/scotty)
* **Persistência de Dados:** `SQLite` (via biblioteca `sqlite-simple`)
* **Testes Unitários:** [HUnit](https://hackage.haskell.org/package/HUnit)
* **Serialização JSON:** `Aeson`

## Estrutura do Projeto

A organização dos arquivos segue o padrão arquitetural para projetos Haskell, separando rigorosamente a lógica de negócio pura da infraestrutura de rede e persistência:
```text
src/
  Main.hs          # Inicialização do servidor Scotty, middlewares (CORS) e definição das rotas da API.
  Types.hs         # Definição dos tipos de dados (Book, Status) e instâncias de conversão para SQLite e JSON.
  Logic.hs         # Lógica de negócio pura (filtros, cálculos de progresso, validações) sem efeitos colaterais.
  Store.hs         # Camada de persistência (I/O) executando as queries SQL no banco `books.db`.

test/
  Spec.hs          # Suíte de testes automatizados com HUnit testando a camada `Logic.hs`.```

## AI

Este projeto foi desenvolvido utilizando os modelos Gemini e Claude como assistentes para:
1. Agilizar a criação da estrutura de front-end (HTML/CSS minimalista e integração via `fetch` API no JavaScript).
2. Auxiliar na configuração e "troubleshooting" do ambiente de desenvolvimento (Docker, Codespaces, Cabal e GHC).
3. Esclarecer erros de compilação inerentes à rigidez do GHC (erros de indentação e `Arity Mismatch` em serialização de dados).

Toda a lógica central, as validações de domínio (padrão funcional) e a integração entre o paradigma funcional e imperativo foram criticamente revisadas, entendidas e estruturadas pelo autor.