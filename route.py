from app.controllers.application import Application
from bottle import Bottle, run, static_file


app = Bottle()
ctl = Application()


#-----------------------------------------------------------------------------
# Arquivos estáticos (CSS e JS) da página

@app.route('/static/<filepath:path>')
def serve_static(filepath):
    return static_file(filepath, root='./app/static')


#-----------------------------------------------------------------------------
# Rotas do Gerenciador de Finanças Pessoais

@app.route('/', method='GET')
def action_financas():
    return ctl.render('financas')


#-----------------------------------------------------------------------------


if __name__ == '__main__':

    run(app, host='0.0.0.0', port=8080, debug=True)
