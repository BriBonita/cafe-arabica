import os
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL

app = Flask(__name__)
CORS(app)

# ── MySQL config (env vars injected by Docker Compose) ──────────────────────
app.config['MYSQL_HOST']     = os.getenv('MYSQL_HOST', 'db')
app.config['MYSQL_USER']     = os.getenv('MYSQL_USER', 'cafe_user')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD', 'cafe_password')
app.config['MYSQL_DB']       = os.getenv('MYSQL_DB', 'cafe_arabica')
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

# ── Logging setup ────────────────────────────────────────────────────────────
LOG_DIR  = os.getenv('LOG_DIR', '/app/logs')
LOG_FILE = os.path.join(LOG_DIR, 'app.log')
os.makedirs(LOG_DIR, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ── Helpers ──────────────────────────────────────────────────────────────────
def log_event(level: str, message: str):
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    line = f'[{ts}] {level.upper()}: {message}\n'
    with open(LOG_FILE, 'a') as f:
        f.write(line)
    if level.upper() == 'ERROR':
        logger.error(message)
    else:
        logger.info(message)


# ── API Routes ───────────────────────────────────────────────────────────────

@app.route('/api/health', methods=['GET'])
def health():
    log_event('INFO', 'Health check realizado')
    return jsonify({'status': 'ok', 'service': 'Café Arábica API'})


@app.route('/api/menu', methods=['GET'])
def get_menu():
    try:
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM menu_items ORDER BY category, name')
        items = cur.fetchall()
        cur.close()
        log_event('INFO', f'Menú consultado – {len(items)} productos devueltos')
        return jsonify(items)
    except Exception as e:
        log_event('ERROR', f'Fallo al consultar menú: {e}')
        return jsonify({'error': 'Error al obtener el menú'}), 500


@app.route('/api/orders', methods=['POST'])
def create_order():
    data = request.get_json(silent=True) or {}
    customer = data.get('customer_name', '').strip()
    items    = data.get('items', [])

    if not customer or not items:
        log_event('ERROR', 'Orden rechazada: datos incompletos')
        return jsonify({'error': 'Nombre de cliente e items son requeridos'}), 400

    try:
        cur = mysql.connection.cursor()
        cur.execute(
            'INSERT INTO orders (customer_name, items_json, status) VALUES (%s, %s, %s)',
            (customer, str(items), 'pending')
        )
        mysql.connection.commit()
        order_id = cur.lastrowid
        cur.close()
        log_event('INFO', f'Nueva orden #{order_id} creada para {customer}')
        return jsonify({'message': 'Orden creada exitosamente', 'order_id': order_id}), 201
    except Exception as e:
        log_event('ERROR', f'Fallo al crear orden: {e}')
        return jsonify({'error': 'Error al guardar la orden'}), 500


@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data  = request.get_json(silent=True) or {}
    name  = data.get('name', '').strip()
    email = data.get('email', '').strip()
    date  = data.get('date', '').strip()
    time  = data.get('time', '').strip()
    guests = data.get('guests', 1)

    if not all([name, email, date, time]):
        log_event('ERROR', 'Reservación rechazada: campos faltantes')
        return jsonify({'error': 'Todos los campos son requeridos'}), 400

    try:
        cur = mysql.connection.cursor()
        cur.execute(
            'INSERT INTO reservations (name, email, date, time, guests) VALUES (%s, %s, %s, %s, %s)',
            (name, email, date, time, guests)
        )
        mysql.connection.commit()
        res_id = cur.lastrowid
        cur.close()
        log_event('INFO', f'Reservación #{res_id} creada – {name} para {date} {time} ({guests} personas)')
        return jsonify({'message': 'Reservación confirmada', 'reservation_id': res_id}), 201
    except Exception as e:
        log_event('ERROR', f'Fallo al crear reservación: {e}')
        return jsonify({'error': 'Error al guardar la reservación'}), 500


@app.route('/api/reservations', methods=['GET'])
def get_reservations():
    try:
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM reservations ORDER BY date, time')
        rows = cur.fetchall()
        cur.close()
        log_event('INFO', f'Reservaciones consultadas – {len(rows)} registros')
        return jsonify(rows)
    except Exception as e:
        log_event('ERROR', f'Fallo al consultar reservaciones: {e}')
        return jsonify({'error': 'Error al obtener reservaciones'}), 500


@app.route('/api/logs', methods=['GET'])
def get_logs():
    try:
        with open(LOG_FILE, 'r') as f:
            lines = f.readlines()
        last_100 = lines[-100:] if len(lines) > 100 else lines
        return jsonify({'logs': last_100})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    log_event('INFO', 'Servidor Café Arábica iniciado')
    app.run(host='0.0.0.0', port=5000, debug=False)
