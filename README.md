# Gerenciador de Finanças Pessoais (BMVC)

Página web que apresenta o funcionamento completo do **Gerenciador de Finanças Pessoais**, um sistema
de finanças escrito em Python com **Programação Orientada a Objetos**, servido pelo **Bottle** na
estrutura **BMVC (Bottle MVC)**.

A página executa o código real a cada visita. Ela mostra as regras de negócio, a arquitetura, as classes,
um roteiro de movimentações (com os registros aceitos e bloqueados), o orçamento por categoria, o
progresso de uma meta, o relatório consolidado e um simulador de progresso.

## Propósito

O sistema organiza a saúde financeira do usuário:

- registra receitas e despesas e calcula o saldo;
- define um limite de orçamento por categoria e bloqueia gastos que o ultrapassem;
- impede que o saldo fique negativo;
- acompanha metas de economia, cujo progresso sobe com receitas e cai com despesas;
- gera um relatório consolidado.

## Arquitetura MVC

| Camada | Arquivo ou pasta | Responsabilidade |
|---|---|---|
| Rotas | `route.py` | Liga `/` ao controlador e serve os arquivos estáticos em `/static/...` |
| Controlador | `app/controllers/application.py` | Cria a `Carteira`, envia o roteiro de movimentações, calcula os dados da página |
| Modelo | `app/models/financas_pkg/` | Regras de negócio em POO: `Transacao`, `Receita`, `Despesa`, `Categoria`, `CalculadoraMixin`, `MetaFinanceira`, `Carteira`, `GeradorRelatorio` |
| Visão | `app/views/html/financas.tpl` | Página HTML com trechos Python entre `{{ }}` e laços `% for` |
| Estáticos | `app/static/css/financas.css`, `app/static/js/financas.js` | Estilo e interatividade no navegador |

Fluxo de uma requisição:

1. O navegador acessa `/`.
2. `route.py` chama `ctl.render('financas')`.
3. O controlador cria a carteira e registra cada lançamento do roteiro. Os modelos validam cada um.
4. O controlador entrega os resultados ao template `financas.tpl`.
5. O Bottle devolve o HTML, e o navegador carrega o CSS e o JS.

## Interatividade (JavaScript)

- **Filtro de movimentações:** os botões *Todas*, *Receitas* e *Despesas* filtram a tabela no navegador.
- **Simulador de progresso:** calcula o progresso da meta após uma receita ou despesa, com a mesma fórmula
  de `MetaFinanceira`. A simulação não grava nada na carteira.
- **Menu:** destaca a seção que está na tela.

## Como executar

Os comandos devem ser executados na pasta raiz do projeto, onde está o `route.py`.

### Localmente

```bash
pip install bottle
python3 route.py
```

Depois, abra `http://localhost:8080/` no navegador.

### Com Docker

```bash
docker build -t gerenciador-financas .
docker run -p 8080:8080 -v "$(pwd)":/bmeta gerenciador-financas
```

## Estrutura do projeto

```text
gerenciador_financas_bmvc/
├── Dockerfile                    # Imagem Python com Bottle (da base BMVC)
├── bmvc_setup.sh                 # Comandos de build e execução com Docker (da base BMVC)
├── route.py                      # Rotas (Bottle)
├── app/
│   ├── controllers/
│   │   └── application.py        # Controlador (C)
│   ├── models/
│   │   └── financas_pkg/         # Modelo (M): regras de negócio em POO
│   ├── views/
│   │   └── html/
│   │       └── financas.tpl      # Visão (V): página principal
│   └── static/
│       ├── css/financas.css      # Estilo da página
│       └── js/financas.js        # Interações da página
└── docs/
    └── diagrama_uml.md           # Diagramas de classes e de sequência (Mermaid)
```

## Origem

- **Estrutura MVC:** base `hgmachine/bmvc_start_from_this` (Bottle MVC). O HTML original de boas-vindas foi
  substituído por uma página própria do gerenciador de finanças.
- **Regras de negócio:** pacote `financas_pkg`, do projeto `dallves-pro/projeto-desktop`, copiado sem alterações
  de lógica. O modelo é consumido pelo controlador, sem depender de nenhum código de interface.

## Limitações conhecidas

- Os dados ficam apenas em memória. A cada visita, a página monta novamente o mesmo cenário de demonstração,
  e nada é salvo em disco.
- Não há login nem controle de usuários.
- A versão de terminal do projeto original (`test_financas.py`) não faz parte desta estrutura web.
