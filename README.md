[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/xDmvZ4it)

## Estrutura de arquivos

src/
  Main.hs        ← servidor Scotty + rotas
  Types.hs       ← tipo de dado Book e afins
  Logic.hs       ← funções puras (filtros, progresso, etc.)
  Store.hs       ← "banco" em memória com IORef
test/
  Spec.hs        ← testes HUnit das funções puras