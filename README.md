# Backend Web com Haskell+Scotty

## 1. Identificação

- **Nome:** Guilherme Serafini Dapieve
- **Curso:** Sistemas de Informação (3º semestre)

---

## 2. Tema/objetivo

O objetivo deste trabalho é desenvolver o **Book Tracker (Diário de Leitura)**, um sistema web para gerenciamento de listas de leitura pessoais e resenhas. 

A lógica principal do serviço opera em cima do conceito de um CRUD (Create, Read, Update, Delete) de livros, integrado a um painel de estatísticas automáticas. O trabalho aplica o paradigma da programação funcional ao isolar rigorosamente as regras de negócio e os cálculos matemáticos (funções puras de estatística, validação de limites de páginas, consistência de notas e status) das operações impuras que causam efeitos colaterais, como as requisições HTTP gerenciadas pelo framework Scotty e a persistência no banco de dados SQLite.

---

## 3. Processo de desenvolvimento

O desenvolvimento foi construído de forma incremental, com forte ênfase em manter a pureza do núcleo em Haskell. 

**Evolução da Ideia Inicial:**
No início do projeto, a minha ideia original era integrar uma API externa de catálogo de livros (como a do Google Books). O objetivo era que, ao digitar o título, o sistema buscasse automaticamente a capa, o autor e o ano. No entanto, decidi descartar essa integração. Percebi que lidar com chamadas HTTP complexas e parsing de JSON de terceiros diretamente no backend em Haskell traria uma carga massiva de efeitos colaterais (I/O), o que desviaria o escopo do projeto, que é aplicar e avaliar os conceitos de Paradigmas de Programação de forma estruturada. Deixei essa melhoria arquitetural (possivelmente delegada ao JavaScript no front-end) para a posteridade.

**Decisões e Construção:**
A arquitetura foi baseada em quatro pilares: `Types.hs` (domínio), `Logic.hs` (regras puras), `Store.hs` (I/O e banco) e `Main.hs` (rotas).
Durante o desenvolvimento, decidi expandir o escopo dos dados. Inicialmente, o livro tinha apenas atributos básicos, mas decidi adicionar "Autor", "Ano de Lançamento" e "Gênero". Essa mudança exigiu uma refatoração em cadeia que me fez compreender na prática a rigidez e a segurança do sistema de tipos do Haskell: precisei atualizar o construtor do tipo, as funções de validação, e deletar o arquivo do banco SQLite local (`books.db`), pois a tentativa de parear um tipo de 10 argumentos com uma tabela de 7 colunas causava quebra imediata de contrato (`Arity Mismatch`).

**Erros e Dificuldades Enfrentadas:**
1. **Sensibilidade à Indentação:** Enfrentei o erro `Unexpected do block in function application`. Demorei a perceber que o compilador do Haskell (GHC) é matematicamente rigoroso com espaços, e uma rota do Scotty desalinhada quebrava a compilação.
2. **Viés nas Estatísticas (Lógica Pura):** A minha função que calculava a nota média dividia a soma das notas pelo total absoluto de livros cadastrados. Como livros "na fila" tinham nota 0, a média era puxada drasticamente para baixo. Resolvi isso usando *Higher-Order Functions* (`filter` e `foldl`) para isolar o cálculo apenas aos livros que já haviam recebido avaliação maior que zero.

**Aspectos Funcionais e Compreensão:**
Ficou muito clara a diferença estrutural entre o Haskell e linguagens imperativas. O uso de *Algebraic Data Types (ADTs)* para definir o `Status` (Quero Ler, Lendo, Lido) garantiu que estados inválidos fossem impossíveis de existir. O uso do tipo `Either String Book` na validação mostrou-se uma forma muito elegante de tratar fluxos de erro sem recorrer ao lançamento de exceções abruptas.

---

## 4. Testes

Os testes unitários foram focados estritamente na camada `Logic.hs`, garantindo que o núcleo matemático do serviço fosse avaliado de forma isolada do Scotty e do SQLite.

- **Ferramenta utilizada:** `HUnit`, rodando isoladamente via `cabal test --test-show-details=direct`.
- **Funções Puras Testadas:** 
  - `calcProgress`: Para verificar se o cálculo de porcentagem lidava corretamente com livros de zero páginas (evitando erro de divisão por zero).
  - `validateBook`: Uma função central que retorna um `Either`. 
- **Exemplos de Verificação:** 
  Foram criados cenários (`TestCase`) simulando o envio de dados inválidos para o domínio, como:
  1. Inserir um livro com `readPages` maior que `totalPages`. A asserção verificava se a função bloqueava e retornava `Left "Inconsistencia: paginas lidas excedem o total."`.
  2. Inserir um livro com `publishYear` no futuro (> 2026), garantindo que a regra de negócio rejeitasse a entrada antes de qualquer persistência.

---

## 5. Execução

O projeto foi construído e executado originalmente utilizando um ambiente no Codespaces (Docker/Linux).

**Dependências necessárias:**
- GHC (Glasgow Haskell Compiler) versão 9.8+
- Cabal
- Bibliotecas do sistema: `libsqlite3-dev` e `pkg-config` (para o banco de dados).

**Passos para rodar localmente:**
1. Clone o repositório e abra o terminal na raiz do projeto.
2. Atualize as dependências e compile o código:
   `cabal build`
3. Execute o servidor:
   `cabal run`
4. Acesse no navegador: `http://localhost:3000`.

---

## 6. Deploy

**Link do serviço publicado:** https://demo-scotty-codespace-2026a-99ws.onrender.com

O deploy foi realizado utilizando a plataforma Render.com, seguindo a abordagem de *Infrastructure as Code* (IaC) através dos arquivos `render.yaml` e `Dockerfile` fornecidos. 

Para que a aplicação em Haskell rodasse com sucesso na nuvem, precisei adaptar a infraestrutura do código:
1. **Porta Dinâmica:** Substituí a porta estática (3000) no `Main.hs` pela captura da variável de ambiente injetada pelo provedor (`lookupEnv "PORT"`), garantindo que o servidor escutasse a porta designada pelo Render.
2. **Health Check:** O Render exige uma rota de verificação de integridade. Implementei uma rota `GET /healthz` retornando "OK", evitando que o Load Balancer da plataforma derrubasse o contêiner por *timeout*.
*(Nota: O banco de dados SQLite foi mantido com dados de teste para facilitar a avaliação, porém, como o disco da camada gratuita do Render é efêmero, os dados são resetados a cada novo deploy).*

---
## 7. Resultado final

`https://github.com/user-attachments/assets/aa2e4faa-001b-4413-a845-74a1fb681777`

**O que está sendo demonstrado no vídeo acima:**
1. Acesso à aplicação em ambiente de produção (nuvem Render).
2. **Update (Atualização):** Edição do livro "Jogos Vorazes", alterando o status para "Lido", o que aciona as funções puras de Haskell para recalcular e atualizar automaticamente as Estatísticas Globais (aumentando a Nota Média).
3. **Create (Inserção):** Adição de um novo livro à biblioteca ("Pessoas Normais").
4. **Delete (Exclusão):** Remoção de um registro ("O Conto de Aia") da persistência do banco de dados, recalculando o painel novamente.

---

## 8. Uso de IA 

### 8.1 Ferramentas de IA utilizadas

- Gemini 3.1 Pro (Plano Advanced / Experimental)
- Claude 3.5 Sonnet

---

### 8.2 Interações relevantes com IA

#### Interação 1
- **Objetivo da consulta:** Entender e resolver um erro de compilação do GHC após adicionar uma nova rota.
- **Trecho do prompt ou resumo fiel:** Enviei o log de erro do terminal: `src/Main.hs:70:20: error: [GHC-52095] Unexpected do block in function application: do bid <- pathParam "id"...`.
- **O que foi aproveitado:** A explicação analítica de que o Haskell é sensível ao alinhamento (indentação) e que a nova rota estava desalinhada em relação à rota anterior, fazendo o GHC tratá-la como um argumento.
- **O que foi modificado ou descartado:** Reestruturei manualmente os espaçamentos das funções dentro do escopo do Scotty.

#### Interação 2
- **Objetivo da consulta:** Refinar a UX do front-end e sincronizar com a lógica em Haskell (marcar como lido).
- **Trecho do prompt ou resumo fiel:** "Ainda falta uma lógica, quando mudar para lido, em status, automaticamente deixar em 100%. E mudar nas estatísticas globais para lidos e lendo."
- **O que foi aproveitado:** A estratégia de fazer a interceptação no JavaScript (`if status === "Finished"`) para forçar o valor de `readPages` a igualar `totalPages` antes de enviar o payload JSON via `PUT` para o Haskell validar.
- **O que foi modificado ou descartado:** Ajustei as paletas de cores sugeridas no CSS para refletir um estilo mais voltado para "diário antigo".

#### Interação 3 
- **Objetivo da consulta:** Configurar e solucionar problemas de Deploy na plataforma Render e resolver conflitos de versionamento no Git.
- **Trecho do prompt ou resumo fiel:** Enviei os logs de erro do terminal da nuvem (`Status: 404 Not Found` em `/healthz` seguido de `==> Timed Out`) e os logs do terminal local informando rejeição no `git push`.
- **O que foi aproveitado:** O diagnóstico técnico de que a plataforma em nuvem exige uma rota específica de monitoramento (`/healthz`) para não matar o processo, e a necessidade de usar `System.Environment` para portas dinâmicas. Além disso, utilizei os comandos de `git pull origin main --rebase` para resolver o conflito de histórico entre o ambiente Codespaces e as edições feitas diretamente no GitHub.
- **O que foi modificado ou descartado:** Uma sugestão anterior da IA sobre realizar o deploy prematuramente foi descartada e ignorada, pois a suíte de testes do HUnit ainda não havia sido executada e a infraestrutura de rotas não estava pronta para a nuvem.

---

### 8.3 Exemplo de erro, limitação ou sugestão inadequada da IA

Durante a configuração inicial do ambiente de desenvolvimento para rodar o projeto localmente, a IA apresentou uma limitação significativa. Ao enfrentar problemas de infraestrutura para compilar o projeto e acessar o servidor web no navegador, o modelo entrou em um "loop", insistindo persistentemente em técnicas parecidas e ineficazes de configuração do Cabal e do GHC. 

A ferramenta falhou em diagnosticar o problema real do ambiente, repetindo comandos que não resolviam os conflitos de dependência ou de exposição de portas. Isso acabou consumindo muito tempo útil do projeto, exigindo que eu ignorasse as sugestões da IA, investigasse a documentação de forma independente e reestruturasse o ambiente manualmente para finalmente conseguir acessar o servidor web. Esse episódio evidenciou que a IA pode perder o contexto da máquina do usuário e insistir em "alucinações" de configuração.

---

### 8.4 Comentário pessoal sobre o processo envolvendo IA

O uso da IA foi um diferencial estratégico, especialmente para lidar com tecnologias que não eram o foco da disciplina. A ferramenta assumiu o trabalho de escrever a interface front-end (HTML, CSS e a integração via `fetch` no JavaScript). Ter essa interface visual pronta rapidamente me ajudou muito a ter uma noção mais concreta e palpável do projeto, facilitando a compreensão de como o serviço RESTful que eu estava escrevendo em Haskell operava na prática.

Além da geração de código secundário, a IA atuou como uma parceira de *brainstorming*. Ela ajudou a dar ideias de como organizar e estruturar o escopo do projeto de forma profissional (como a arquitetura dividida em `Types`, `Logic` e `Store`). A grande lição que fica é que a IA é excelente para acelerar a infraestrutura e o front-end, mas para a lógica funcional pura no backend, o domínio conceitual do desenvolvedor continua sendo indispensável para corrigir e guiar a ferramenta.

---

## 9. Referências e créditos

- Documentação do framework Scotty: [https://hackage.haskell.org/package/scotty](https://hackage.haskell.org/package/scotty)
- Documentação da biblioteca sqlite-simple: [https://hackage.haskell.org/package/sqlite-simple](https://hackage.haskell.org/package/sqlite-simple)
- Documentação de Testes HUnit: [https://hackage.haskell.org/package/HUnit](https://hackage.haskell.org/package/HUnit)
- Documentação de Deploy Web Services do Render: [https://docs.render.com/web-services](https://docs.render.com/web-services)
- Materiais e exemplos práticos da disciplina de Paradigmas de Programação (Profª. Andrea).</Substitua>
