# Book Tracker - Gerenciador de Leitura em Haskell

[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/xDmvZ4it)

Este projeto é um sistema simples para gerenciar listas de leitura, desenvolvido como parte da disciplina de **Paradigmas de Programação** (UFSM). A aplicação utiliza o framework **Scotty** para fornecer uma API Web e foca na aplicação de conceitos de programação funcional.

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** Haskell
* **Framework Web:** [Scotty](https://hackage.haskell.org/package/scotty)
* **Gerenciamento de Estado:** `IORef` (Banco de dados em memória)
* **Testes:** [HUnit](https://hackage.haskell.org/package/HUnit)

## 📂 Estrutura do Projeto

A organização dos arquivos segue o padrão para projetos Haskell, separando a lógica de negócio da infraestrutura de rede:

```text
.
├── src/
│   ├── Main.hs          # Inicialização do servidor Scotty e definição das rotas.
│   ├── Types.hs         # Definição dos tipos de dados (Book, Status, etc.).
│   ├── Logic.hs         # Lógica de negócio pura (filtros, cálculos de progresso).
│   └── Store.hs         # Camada de persistência em memória utilizando IORef.
└── test/
    └── Spec.hs          # Suíte de testes automatizados com HUnit.