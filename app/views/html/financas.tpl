<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Gerenciador de Finanças Pessoais: demonstração do funcionamento de uma aplicação orientada a objetos servida pelo Bottle, na arquitetura MVC.">
    <title>Gerenciador de Finanças Pessoais</title>
    <link rel="stylesheet" href="/static/css/financas.css">
    <script src="/static/js/financas.js" defer></script>
</head>
<body>

<header class="cabecalho">
    <div class="container">
        <p class="selo">Programação Orientada a Objetos &middot; Bottle MVC</p>
        <h1>Gerenciador de Finanças Pessoais</h1>
        <p class="subtitulo">Registre entradas e saídas, controle o orçamento por categoria e acompanhe metas de economia.
            Esta página executa o código real a cada visita e mostra, passo a passo, o que acontece por dentro.</p>

        <dl class="indicadores">
            <div>
                <dt>Saldo final</dt>
                <dd>{{ saldo_final }}</dd>
            </div>
            <div>
                <dt>Total de receitas</dt>
                <dd>{{ total_receitas }}</dd>
            </div>
            <div>
                <dt>Total de despesas</dt>
                <dd>{{ total_despesas }}</dd>
            </div>
            <div>
                <dt>Aceitas / bloqueadas</dt>
                <dd>{{ aceitas }} / {{ bloqueadas }}</dd>
            </div>
        </dl>
    </div>
</header>

<nav class="navegacao" aria-label="Seções da página">
    <ul class="container">
        <li><a href="#proposito">Propósito</a></li>
        <li><a href="#regras">Regras</a></li>
        <li><a href="#arquitetura">Arquitetura MVC</a></li>
        <li><a href="#classes">Classes</a></li>
        <li><a href="#demonstracao">Demonstração</a></li>
        <li><a href="#simulador">Simulador</a></li>
        <li><a href="#executar">Como executar</a></li>
    </ul>
</nav>

<main class="container">

    <section id="proposito" class="secao">
        <h2>1. Propósito do sistema</h2>
        <p>O Gerenciador de Finanças Pessoais organiza a saúde financeira de uma pessoa de forma simples.
            Ele responde a três perguntas do dia a dia:</p>
        <ul class="perguntas">
            <li><strong>Quanto eu tenho?</strong> O saldo é calculado a partir do saldo inicial e de cada receita e despesa aceita.</li>
            <li><strong>Posso gastar isto?</strong> Cada categoria tem um limite de orçamento, e o saldo nunca fica negativo.</li>
            <li><strong>Estou perto da minha meta?</strong> Cada meta financeira mostra o progresso da economia a cada movimentação.</li>
        </ul>
        <p>O projeto foi desenvolvido com foco em Programação Orientada a Objetos: encapsulamento, herança,
            polimorfismo e composição. A página web apenas apresenta esse funcionamento.</p>
    </section>

    <section id="regras" class="secao">
        <h2>2. Regras de funcionamento</h2>
        <p>Cada tipo de movimentação decide se aceita ou não um lançamento. As regras abaixo vêm diretamente do código.</p>
        <div class="grade-regras">
            <article class="regra despesa-borda">
                <h3>Saldo protegido</h3>
                <p>Uma despesa só é aceita se o saldo disponível cobrir o valor. Caso contrário, a carteira registra
                    <code>Saldo insuficiente.</code></p>
            </article>
            <article class="regra despesa-borda">
                <h3>Orçamento acumulado por categoria</h3>
                <p>O limite vale para o <strong>total</strong> gasto na categoria, não para cada despesa isolada.
                    Uma despesa que ultrapasse o limite somado às anteriores é bloqueada.</p>
            </article>
            <article class="regra receita-borda">
                <h3>Receitas sempre aceitas</h3>
                <p>Receitas nunca são bloqueadas e nunca representam gasto em categoria alguma.</p>
            </article>
            <article class="regra meta-borda">
                <h3>Metas que acompanham as contas</h3>
                <p>O progresso é o saldo inicial da meta, somado às receitas e subtraído das despesas, dividido pelo objetivo.
                    Por isso ele sobe com receitas e cai com despesas.</p>
            </article>
        </div>
    </section>

    <section id="arquitetura" class="secao">
        <h2>3. Arquitetura MVC</h2>
        <p>A aplicação segue o padrão Model-View-Controller da estrutura BMVC. Cada camada tem uma responsabilidade única:</p>

        <div class="tabela-wrapper">
            <table class="tabela">
                <thead>
                    <tr>
                        <th scope="col">Camada</th>
                        <th scope="col">Onde está</th>
                        <th scope="col">Responsabilidade</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Rotas</td>
                        <td><code>route.py</code></td>
                        <td>Liga o endereço <code>/</code> ao controlador e serve os arquivos estáticos.</td>
                    </tr>
                    <tr>
                        <td>Controlador</td>
                        <td><code>app/controllers/application.py</code></td>
                        <td>Monta o cenário, chama os modelos e prepara os dados para a página.</td>
                    </tr>
                    <tr>
                        <td>Modelo</td>
                        <td><code>app/models/financas_pkg/</code></td>
                        <td>Regras de negócio em POO: <code>Carteira</code>, <code>Receita</code>, <code>Despesa</code>, <code>Categoria</code>, <code>MetaFinanceira</code> e <code>GeradorRelatorio</code>.</td>
                    </tr>
                    <tr>
                        <td>Visão</td>
                        <td><code>app/views/html/financas.tpl</code></td>
                        <td>Apresenta o resultado em HTML, com trechos de Python entre <code>&#123;&#123; &#125;&#125;</code>.</td>
                    </tr>
                    <tr>
                        <td>Estáticos</td>
                        <td><code>app/static/css</code> e <code>app/static/js</code></td>
                        <td>Estilo visual e interatividade no navegador.</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Caminho de uma requisição</h3>
        <ol class="fluxo">
            <li>O navegador acessa <code>/</code>.</li>
            <li><code>route.py</code> recebe a requisição e chama <code>ctl.render('financas')</code>.</li>
            <li>O controlador cria a <code>Carteira</code> e envia a ela o roteiro de movimentações.</li>
            <li>Os modelos validam cada lançamento, calculam limites, saldo e metas.</li>
            <li>O controlador entrega os resultados ao template <code>financas.tpl</code>.</li>
            <li>O Bottle devolve o HTML. O navegador carrega <code>financas.css</code> e <code>financas.js</code>.</li>
        </ol>
    </section>

    <section id="classes" class="secao">
        <h2>4. Modelo de classes</h2>
        <p>O pacote <code>financas_pkg</code> reúne as classes abaixo. O diagrama completo de classes 
            está em <code>docs/diagrama_uml.md</code>.</p>

        <div class="tabela-wrapper">
            <table class="tabela">
                <thead>
                    <tr>
                        <th scope="col">Classe</th>
                        <th scope="col">Tipo</th>
                        <th scope="col">Papel</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><code>Transacao</code></td>
                        <td>Abstrata</td>
                        <td>Base de todas as movimentações. Define valor, descrição e data, e exige a implementação de <code>tipo()</code>, <code>efeito_no_saldo()</code>, <code>gasto_em()</code> e <code>validar()</code>.</td>
                    </tr>
                    <tr>
                        <td><code>Receita</code></td>
                        <td>Concreta</td>
                        <td>Entrada de dinheiro. Herda de <code>Transacao</code> e de <code>CalculadoraMixin</code>.</td>
                    </tr>
                    <tr>
                        <td><code>Despesa</code></td>
                        <td>Concreta</td>
                        <td>Saída de dinheiro vinculada a uma <code>Categoria</code>. Passa pelas validações de limite e saldo.</td>
                    </tr>
                    <tr>
                        <td><code>Categoria</code></td>
                        <td>Concreta</td>
                        <td>Guarda o nome e o limite de orçamento. Verifica se um total gasto está dentro do limite.</td>
                    </tr>
                    <tr>
                        <td><code>CalculadoraMixin</code></td>
                        <td>Mixin</td>
                        <td>Ferramentas de cálculo: soma o efeito das transações no saldo e calcula percentuais de progresso.</td>
                    </tr>
                    <tr>
                        <td><code>MetaFinanceira</code></td>
                        <td>Concreta</td>
                        <td>Objetivo de economia. Calcula o saldo atual e o progresso a partir das transações da carteira.</td>
                    </tr>
                    <tr>
                        <td><code>Carteira</code></td>
                        <td>Central</td>
                        <td>Controla saldo, transações e metas. Cria as metas e decide o que é aceito.</td>
                    </tr>
                    <tr>
                        <td><code>GeradorRelatorio</code></td>
                        <td>Serviço</td>
                        <td>Gera o texto consolidado com saldo, movimentações e progresso das metas.</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Polimorfismo: o mesmo método, comportamentos diferentes</h3>
        <p>A <code>Carteira</code> trata receitas e despesas pela mesma interface. Cada classe responde pelo próprio comportamento.</p>
        <div class="tabela-wrapper">
            <table class="tabela">
                <thead>
                    <tr>
                        <th scope="col">Método</th>
                        <th scope="col">Em <code>Receita</code></th>
                        <th scope="col">Em <code>Despesa</code></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><code>tipo()</code></td>
                        <td>Retorna <code>"Receita"</code></td>
                        <td>Retorna <code>"Despesa"</code></td>
                    </tr>
                    <tr>
                        <td><code>efeito_no_saldo()</code></td>
                        <td>Soma o valor ao saldo</td>
                        <td>Subtrai o valor do saldo</td>
                    </tr>
                    <tr>
                        <td><code>gasto_em(categoria)</code></td>
                        <td>Sempre <code>0</code></td>
                        <td>O valor, se a categoria for a mesma; senão <code>0</code></td>
                    </tr>
                    <tr>
                        <td><code>validar(saldo, transacoes)</code></td>
                        <td>Sempre aceita (<code>None</code>)</td>
                        <td>Recusa se exceder o limite da categoria ou se o saldo for insuficiente</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="demonstracao" class="secao">
        <h2>5. Demonstração em execução</h2>
        <p>Os dados abaixo saem do código Python desta visita. O controlador cria uma carteira com saldo inicial de
            <strong>{{ saldo_inicial }}</strong>, uma meta de <strong>{{ meta['objetivo'] }}</strong> e envia o roteiro de movimentações, um lançamento por vez.</p>

        <h3>5.1 Registro do roteiro</h3>
        <p>Cada linha abaixo é a mensagem real que a <code>Carteira</code> registrou ao receber o lançamento.</p>
        <div class="terminal" role="log" aria-label="Mensagens de registro da carteira">
            % for r in registros:
            <p class="linha-terminal {{ r['classe'] }}">{{ r['mensagem'] }}</p>
            % end
        </div>
        <p class="legenda">Resultado: <strong>{{ aceitas }}</strong> movimentações aceitas e <strong>{{ bloqueadas }}</strong> bloqueadas.</p>

        <h3>5.2 Movimentações aceitas</h3>
        <p>Use os filtros para mostrar só receitas ou só despesas. A tabela é filtrada no navegador.</p>
        <div class="filtros" role="group" aria-label="Filtrar movimentações por tipo">
            <button type="button" class="filtro" data-filtro="todas" aria-pressed="true">Todas</button>
            <button type="button" class="filtro" data-filtro="Receita" aria-pressed="false">Receitas</button>
            <button type="button" class="filtro" data-filtro="Despesa" aria-pressed="false">Despesas</button>
        </div>
        <div class="tabela-wrapper">
            <table class="tabela" id="tabela-movimentacoes">
                <thead>
                    <tr>
                        <th scope="col">Tipo</th>
                        <th scope="col">Descrição</th>
                        <th scope="col">Data</th>
                        <th scope="col">Valor</th>
                        <th scope="col">Efeito no saldo</th>
                    </tr>
                </thead>
                <tbody>
                    % for m in movimentacoes:
                    <tr data-tipo-linha="{{ m['tipo'] }}" class="{{ m['tipo'].lower() }}">
                        <td>{{ m['tipo'] }}</td>
                        <td>{{ m['descricao'] }}</td>
                        <td>{{ m['data'] }}</td>
                        <td>{{ m['valor'] }}</td>
                        <td class="efeito">{{ m['efeito'] }}</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>

        <h3>5.3 Orçamento por categoria</h3>
        <p>A barra mostra quanto do limite de cada categoria já foi usado. Os gastos já estão somados pela regra de limite acumulado.</p>
        <div class="cartoes">
            % for c in categorias:
            <article class="cartao">
                <h4>{{ c['nome'] }}</h4>
                <p>Limite: <strong>{{ c['limite'] }}</strong></p>
                <p>Gasto: <strong>{{ c['gasto'] }}</strong> ({{ c['percentual_texto'] }} do limite)</p>
                <p>Disponível: <strong>{{ c['disponivel'] }}</strong></p>
                <div class="barra" role="img" aria-label="{{ c['nome'] }}: {{ c['percentual_texto'] }} do limite usado">
                    <div class="barra-preenchimento" style="width: {{ c['percentual'] }}%"></div>
                </div>
            </article>
            % end
        </div>

        <h3>5.4 Meta financeira</h3>
        <div class="meta-caixa">
            <p>Objetivo: <strong>{{ meta['objetivo'] }}</strong></p>
            <p>Valor economizado até agora: <strong>{{ meta['saldo_atual'] }}</strong></p>
            <p>Progresso: <strong>{{ meta['progresso'] }}</strong></p>
            <div class="barra barra-grande" role="img" aria-label="Progresso da meta: {{ meta['progresso'] }}">
                <div class="barra-preenchimento" style="width: {{ meta['largura'] }}%"></div>
            </div>
        </div>

        <h3>5.5 Relatório consolidado</h3>
        <p>Texto gerado pela classe <code>GeradorRelatorio</code> a partir da carteira, exatamente como ela produz no terminal.</p>
        <pre class="relatorio">{{ relatorio }}</pre>

        <h3>5.6 Caso extra: bloqueio por saldo insuficiente</h3>
        <div class="aviso">
            <p>Uma carteira com saldo de {{ saldo_caso_extra }} tenta registrar uma despesa de {{ bloqueio['valor'] }} na categoria Lazer.
                O valor cabe no limite da categoria, mas não há saldo para cobri-lo.</p>
            <p class="linha-terminal {{ bloqueio['classe'] }}">{{ bloqueio['mensagem'] }}</p>
            <p>Saldo final dessa carteira: <strong>{{ saldo_sem_saldo_final }}</strong></p>
        </div>
    </section>

    <section id="simulador" class="secao">
        <h2>6. Simulador de progresso da meta</h2>
        <p>Escolha uma receita ou despesa e veja como ela mudaria o progresso da meta principal. O cálculo segue a
            mesma fórmula de <code>MetaFinanceira.calcular_progresso()</code>.</p>

        <form id="simulador-form" class="simulador"
              data-saldo="{{ meta['saldo_bruto'] }}"
              data-objetivo="{{ meta['objetivo_bruto'] }}">
            <div class="campo">
                <label for="simulador-tipo">Tipo</label>
                <select id="simulador-tipo" name="tipo">
                    <option value="Receita">Receita (soma ao saldo)</option>
                    <option value="Despesa">Despesa (subtrai do saldo)</option>
                </select>
            </div>
            <div class="campo">
                <label for="simulador-valor">Valor (R$)</label>
                <input id="simulador-valor" name="valor" type="number" min="0.01" step="0.01" value="500" required>
            </div>
            <button type="submit" class="botao">Simular progresso</button>
        </form>

        <p id="simulador-resultado" class="resultado" role="status" aria-live="polite">
            Saldo atual da meta: {{ meta['saldo_atual'] }} ({{ meta['progresso'] }} do objetivo de {{ meta['objetivo'] }}).
        </p>
        <div class="barra barra-grande" role="img" aria-label="Progresso simulado da meta">
            <div id="simulador-barra" class="barra-preenchimento" style="width: {{ meta['largura'] }}%"></div>
        </div>
        <p class="legenda">Esta simulação não grava nada na carteira e não aplica os limites de categoria. Ela mostra só o efeito no progresso da meta.</p>
    </section>

    <section id="executar" class="secao">
        <h2>7. Como executar</h2>
        <p>A aplicação roda na porta 8080. Execute os comandos a partir da pasta raiz do projeto.</p>

        <h3>Localmente</h3>
        <pre class="codigo"><code>pip install bottle
python3 route.py</code></pre>

        <h3>Com Docker</h3>
        <pre class="codigo"><code>docker build -t gerenciador-financas .
docker run -p 8080:8080 -v "$(pwd)":/bmeta gerenciador-financas</code></pre>

        <p>Depois, abra <code>http://localhost:8080/</code> no navegador.</p>
    </section>

</main>

<footer class="rodape">
    <div class="container">
        <p>Gerenciador de Finanças Pessoais &middot; estrutura BMVC (Bottle MVC) com modelos em POO.</p>
    </div>
</footer>

</body>
</html>
