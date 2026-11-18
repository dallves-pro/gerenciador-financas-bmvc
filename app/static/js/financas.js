/* Gerenciador de Finanças Pessoais: interações da página principal.
 *
 * Funções:
 *  1. Filtro da tabela de movimentações (Todas / Receitas / Despesas).
 *  2. Simulador do progresso da meta (mesma fórmula de MetaFinanceira).
 *  3. Destaque, no menu, da seção que está na tela.
 */

(function () {
    'use strict';

    // Regras espelhadas do modelo Python (CalculadoraMixin e MetaFinanceira)

    function aplicarMovimento(saldoAtual, tipo, valor) {
        // Receita soma ao saldo; despesa subtrai (efeito_no_saldo)
        return tipo === 'Receita' ? saldoAtual + valor : saldoAtual - valor;
    }

    function calcularProgresso(saldo, objetivo) {
        // Sem divisão por zero: objetivo zero ou negativo resulta em 0%
        if (objetivo <= 0) {
            return 0;
        }
        return (saldo / objetivo) * 100;
    }

    // Formatação para exibição

    function formatarReal(valor) {
        try {
            return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        } catch (erro) {
            return 'R$ ' + valor.toFixed(2).replace('.', ',');
        }
    }

    function formatarPercentual(valor) {
        return valor.toFixed(2).replace('.', ',') + '%';
    }

    // 1. Filtro da tabela de movimentações

    function iniciarFiltroMovimentacoes() {
        const botoes = document.querySelectorAll('[data-filtro]');
        const linhas = document.querySelectorAll('[data-tipo-linha]');
        if (!botoes.length || !linhas.length) {
            return;
        }

        botoes.forEach(function (botao) {
            botao.addEventListener('click', function () {
                const filtro = botao.dataset.filtro;

                botoes.forEach(function (outro) {
                    outro.setAttribute('aria-pressed', String(outro === botao));
                });

                linhas.forEach(function (linha) {
                    const mostrar = filtro === 'todas' || linha.dataset.tipoLinha === filtro;
                    linha.hidden = !mostrar;
                });
            });
        });
    }

    // 2. Simulador do progresso da meta

    function iniciarSimulador() {
        const formulario = document.getElementById('simulador-form');
        const campoTipo = document.getElementById('simulador-tipo');
        const campoValor = document.getElementById('simulador-valor');
        const resultado = document.getElementById('simulador-resultado');
        const barra = document.getElementById('simulador-barra');
        if (!formulario || !campoTipo || !campoValor || !resultado || !barra) {
            return;
        }

        const saldoAtual = parseFloat(formulario.dataset.saldo);
        const objetivo = parseFloat(formulario.dataset.objetivo);
        if (!Number.isFinite(saldoAtual) || !Number.isFinite(objetivo)) {
            return;
        }

        formulario.addEventListener('submit', function (evento) {
            evento.preventDefault();

            const valor = Number(campoValor.value);
            if (!Number.isFinite(valor) || valor <= 0) {
                resultado.classList.add('erro');
                resultado.textContent = 'Informe um valor maior que zero para simular.';
                return;
            }

            const tipo = campoTipo.value;
            const novoSaldo = aplicarMovimento(saldoAtual, tipo, valor);
            const progresso = calcularProgresso(novoSaldo, objetivo);
            // Largura da barra limitada entre 0% e 100%, com duas casas decimais
            const largura = Math.min(Math.max(progresso, 0), 100).toFixed(2);

            resultado.classList.remove('erro');
            resultado.textContent =
                tipo + ' de ' + formatarReal(valor) + ': o saldo da meta passaria de ' +
                formatarReal(saldoAtual) + ' para ' + formatarReal(novoSaldo) +
                ', ou seja, ' + formatarPercentual(progresso) +
                ' do objetivo de ' + formatarReal(objetivo) + '.';
            barra.style.width = largura + '%';
        });
    }

    // 3. Destaque da seção ativa no menu

    function destacarSecaoAtiva() {
        const links = document.querySelectorAll('.navegacao a[href^="#"]');
        if (!links.length || !('IntersectionObserver' in window)) {
            return;
        }

        const linkPorSecao = {};
        links.forEach(function (link) {
            linkPorSecao[link.getAttribute('href').slice(1)] = link;
        });

        const observador = new IntersectionObserver(function (entradas) {
            entradas.forEach(function (entrada) {
                if (!entrada.isIntersecting) {
                    return;
                }
                links.forEach(function (link) {
                    link.classList.remove('ativo');
                });
                const link = linkPorSecao[entrada.target.id];
                if (link) {
                    link.classList.add('ativo');
                }
            });
        }, { rootMargin: '-35% 0px -60% 0px' });

        Object.keys(linkPorSecao).forEach(function (id) {
            const secao = document.getElementById(id);
            if (secao) {
                observador.observe(secao);
            }
        });
    }

    function iniciar() {
        iniciarFiltroMovimentacoes();
        iniciarSimulador();
        destacarSecaoAtiva();
    }

    if (typeof document !== 'undefined') {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', iniciar);
        } else {
            iniciar();
        }
    }

    // Exporta as funções puras para testes automatizados (Node.js)
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = {
            aplicarMovimento: aplicarMovimento,
            calcularProgresso: calcularProgresso,
            formatarPercentual: formatarPercentual,
        };
    }
})();
