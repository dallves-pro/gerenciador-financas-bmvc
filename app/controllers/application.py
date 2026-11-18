"""Controlador (C do MVC).

Monta um cenário de demonstração usando as classes reais do pacote
app.models.financas_pkg e entrega os resultados para a visão (financas.tpl).
"""
import io
from contextlib import redirect_stdout

from bottle import template

from app.models.financas_pkg import (
    Carteira,
    Categoria,
    Despesa,
    GeradorRelatorio,
    Receita,
)


SALDO_INICIAL = 1500.0
LIMITES = {'Essencial': 2000.0, 'Lazer': 500.0}
META_OBJETIVO = 10000.0
META_SALDO_INICIAL = 2000.0

# Roteiro de movimentações enviadas à Carteira, na ordem em que aparecem.
# Cada item: (tipo, descrição, data, valor, fonte da receita ou nome da categoria)
ROTEIRO = [
    ('Receita', 'Salário', '01/11/2026', 3000.0, 'Empresa X'),
    ('Despesa', 'Aluguel', '05/11/2026', 1200.0, 'Essencial'),
    ('Despesa', 'Cinema', '06/11/2026', 800.0, 'Lazer'),
    ('Despesa', 'Compra grande', '07/11/2026', 2500.0, 'Essencial'),
    ('Despesa', 'Jantar', '08/11/2026', 300.0, 'Lazer'),
    ('Despesa', 'Teatro', '09/11/2026', 250.0, 'Lazer'),
    ('Despesa', 'Café', '10/11/2026', 200.0, 'Lazer'),
]


def formatar_moeda(valor, com_sinal=False):
    """Formata no padrão brasileiro: 3000 -> 'R$ 3.000,00'."""
    texto = f"{abs(valor):,.2f}".replace(',', '#').replace('.', ',').replace('#', '.')
    if valor < 0:
        sinal = '-'
    elif com_sinal and valor > 0:
        sinal = '+'
    else:
        sinal = ''
    return f"{sinal}R$ {texto}"


def formatar_percentual(valor):
    """Formata percentuais no padrão brasileiro: 33.0 -> '33,00%'."""
    return f"{valor:.2f}".replace('.', ',') + '%'


def criar_transacao(tipo, descricao, data, valor, referencia, categorias):
    """Cria Receita ou Despesa conforme o tipo informado no roteiro."""
    if tipo == 'Receita':
        return Receita(valor, descricao, data, referencia)
    return Despesa(valor, descricao, data, categorias[referencia])


def registrar(carteira, transacao):
    """Envia a transação à Carteira e captura a mensagem que ela registra.

    A Carteira valida a movimentação (polimorfismo) e imprime [SUCESSO] ou
    [BLOQUEADO]; essa mensagem é capturada para ser exibida na página.
    """
    buffer = io.StringIO()
    with redirect_stdout(buffer):
        carteira.adicionar_transacao(transacao)
    mensagem = buffer.getvalue().strip()
    aceita = mensagem.startswith('[SUCESSO]')
    return {
        'tipo': transacao.tipo(),
        'descricao': transacao.descricao,
        'data': transacao.data,
        'valor': formatar_moeda(transacao.valor),
        'aceita': aceita,
        'classe': 'aceita' if aceita else 'bloqueada',
        'mensagem': mensagem,
    }


class Application():

    def __init__(self):
        self.pages = {
            'financas': self.financas,
        }

    def render(self, page):
        content = self.pages.get(page, self.financas)
        return content()

    def financas(self):
        return template('app/views/html/financas', **self.montar_painel())

    def montar_painel(self):
        categorias = {nome: Categoria(nome, limite) for nome, limite in LIMITES.items()}

        # Cenário principal: uma carteira, uma meta e o roteiro de movimentações
        carteira = Carteira(SALDO_INICIAL)
        carteira.criar_meta(META_OBJETIVO, META_SALDO_INICIAL)

        registros = []
        for tipo, descricao, data, valor, referencia in ROTEIRO:
            transacao = criar_transacao(tipo, descricao, data, valor, referencia, categorias)
            registros.append(registrar(carteira, transacao))

        # Movimentações efetivamente aceitas pela carteira
        movimentacoes = [
            {
                'tipo': t.tipo(),
                'descricao': t.descricao,
                'data': t.data,
                'valor': formatar_moeda(t.valor),
                'efeito': formatar_moeda(t.efeito_no_saldo(), com_sinal=True),
            }
            for t in carteira.transacoes
        ]

        # Gasto acumulado por categoria (regra do limite sobre o total)
        resumo_categorias = []
        for categoria in categorias.values():
            limite = LIMITES[categoria.nome]
            gasto = sum((t.gasto_em(categoria) for t in carteira.transacoes), 0.0)
            percentual = gasto / limite * 100
            resumo_categorias.append({
                'nome': categoria.nome,
                'limite': formatar_moeda(limite),
                'gasto': formatar_moeda(gasto),
                'disponivel': formatar_moeda(limite - gasto),
                'percentual': round(min(percentual, 100.0), 2),
                'percentual_texto': formatar_percentual(percentual),
            })

        # Progresso da meta, calculado pela própria MetaFinanceira
        meta = carteira.metas[0]
        saldo_meta = meta.saldo_atual(carteira.transacoes)
        progresso = meta.calcular_progresso(carteira.transacoes)
        meta_principal = {
            'objetivo': formatar_moeda(meta.objetivo),
            'saldo_atual': formatar_moeda(saldo_meta),
            'progresso': formatar_percentual(progresso),
            'largura': round(min(max(progresso, 0.0), 100.0), 2),
            # valores brutos usados pelo simulador em JavaScript
            'saldo_bruto': round(saldo_meta, 2),
            'objetivo_bruto': meta.objetivo,
        }

        total_receitas = sum((t.valor for t in carteira.transacoes if t.tipo() == 'Receita'), 0.0)
        total_despesas = sum((t.valor for t in carteira.transacoes if t.tipo() == 'Despesa'), 0.0)

        # Caso extra: a despesa cabe no limite da categoria, mas não há saldo
        saldo_caso_extra = 100.0
        carteira_sem_saldo = Carteira(saldo_caso_extra)
        bloqueio = registrar(
            carteira_sem_saldo,
            Despesa(150.0, 'Show', '09/11/2026', categorias['Lazer']),
        )

        return {
            'saldo_inicial': formatar_moeda(SALDO_INICIAL),
            'saldo_final': formatar_moeda(carteira.saldo),
            'total_receitas': formatar_moeda(total_receitas),
            'total_despesas': formatar_moeda(total_despesas),
            'aceitas': sum(1 for r in registros if r['aceita']),
            'bloqueadas': sum(1 for r in registros if not r['aceita']),
            'registros': registros,
            'movimentacoes': movimentacoes,
            'categorias': resumo_categorias,
            'meta': meta_principal,
            'relatorio': GeradorRelatorio().gerar_dados(carteira),
            'bloqueio': bloqueio,
            'saldo_caso_extra': formatar_moeda(saldo_caso_extra),
            'saldo_sem_saldo_final': formatar_moeda(carteira_sem_saldo.saldo),
        }
