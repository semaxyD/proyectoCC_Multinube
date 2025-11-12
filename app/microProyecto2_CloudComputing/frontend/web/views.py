from flask import Flask, render_template, request, Response
from flask_cors import CORS
import requests

app = Flask(__name__)
app.secret_key = 'secret123'
CORS(app, supports_credentials=True)

# URLs internas de los servicios (dentro del cluster)
USERS_SERVICE = 'http://users.microstore.svc.cluster.local:5002'
PRODUCTS_SERVICE = 'http://products.microstore.svc.cluster.local:5003'
ORDERS_SERVICE = 'http://orders.microstore.svc.cluster.local:5004'

# ================ RUTAS DE VISTAS ================
@app.route('/')
def index():
    return render_template('index.html', 
                         users_service_url='',
                         products_service_url='',
                         orders_service_url='')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html',
                         users_service_url='',
                         products_service_url='',
                         orders_service_url='')

@app.route('/users')
def users():
    return render_template('users.html', users_service_url='')

@app.route('/products')
def products():
    return render_template('products.html', products_service_url='')

@app.route('/orders')
def orders():
    return render_template('orders.html',
                         orders_service_url='',
                         users_service_url='',
                         products_service_url='')

@app.route('/editUser/<string:id>')
def edit_user(id):
    return render_template('editUser.html', id=id, users_service_url='')

@app.route('/editProduct/<string:id>')
def edit_product(id):
    return render_template('editProduct.html', id=id, products_service_url='')

@app.route('/editOrder/<string:id>')
def edit_order(id):
    return render_template('editOrder.html', id=id, orders_service_url='')

# ================ RUTAS PROXY ================

def proxy_request(service_url, path=''):
    """Función auxiliar para hacer proxy de requests"""
    # Construir URL completa
    if path:
        url = f"{service_url}/{path}"
    else:
        url = service_url
    
    # Eliminar query params del path si existen
    if '?' in url:
        url = url.split('?')[0]
    
    # Agregar query params de la request original
    if request.query_string:
        url = f"{url}?{request.query_string.decode()}"
    
    print(f"Proxying {request.method} to: {url}")
    
    try:
        # Copiar headers relevantes
        headers = {}
        if request.headers.get('Content-Type'):
            headers['Content-Type'] = request.headers.get('Content-Type')
        
        # Hacer la petición
        resp = requests.request(
            method=request.method,
            url=url,
            headers=headers,
            data=request.get_data(),
            allow_redirects=False,
            timeout=10
        )
        
        print(f"Response status: {resp.status_code}")
        
        # Crear respuesta
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        response_headers = [(name, value) for (name, value) in resp.headers.items()
                           if name.lower() not in excluded_headers]
        
        return Response(resp.content, resp.status_code, response_headers)
        
    except requests.exceptions.RequestException as e:
        print(f"Proxy error: {str(e)}")
        return {'error': str(e)}, 500

# Proxy para Login (ruta especial)
@app.route('/api/login', methods=['POST', 'OPTIONS'])
def proxy_login():
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(USERS_SERVICE, 'api/login')

# Proxy para Users
@app.route('/api/users', methods=['GET', 'POST', 'OPTIONS'])
@app.route('/api/users/', methods=['GET', 'POST', 'OPTIONS'])
def proxy_users_list():
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(USERS_SERVICE, 'api/users')

@app.route('/api/users/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def proxy_users_detail(path):
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(USERS_SERVICE, f'api/users/{path}')

# Proxy para Products
@app.route('/api/products', methods=['GET', 'POST', 'OPTIONS'])
@app.route('/api/products/', methods=['GET', 'POST', 'OPTIONS'])
def proxy_products_list():
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(PRODUCTS_SERVICE, 'api/products')

@app.route('/api/products/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def proxy_products_detail(path):
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(PRODUCTS_SERVICE, f'api/products/{path}')

# Proxy para Orders
@app.route('/api/orders', methods=['GET', 'POST', 'OPTIONS'])
@app.route('/api/orders/', methods=['GET', 'POST', 'OPTIONS'])
def proxy_orders_list():
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(ORDERS_SERVICE, 'api/orders')

@app.route('/api/orders/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def proxy_orders_detail(path):
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response
    return proxy_request(ORDERS_SERVICE, f'api/orders/{path}')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
