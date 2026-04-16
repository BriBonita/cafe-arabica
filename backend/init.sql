-- ─────────────────────────────────────────────────────────────────────────
-- Base de datos: Café Arábica
-- ─────────────────────────────────────────────────────────────────────────
CREATE DATABASE IF NOT EXISTS cafe_arabica;
USE cafe_arabica;

-- Tabla: menú
CREATE TABLE IF NOT EXISTS menu_items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)   NOT NULL,
    description VARCHAR(255)   NOT NULL,
    price       DECIMAL(6, 2)  NOT NULL,
    category    ENUM('cafe','bebidas','postres','desayunos') NOT NULL,
    image       VARCHAR(255)   DEFAULT NULL,
    available   BOOLEAN        DEFAULT TRUE,
    created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: órdenes
CREATE TABLE IF NOT EXISTS orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    items_json    TEXT         NOT NULL,
    status        ENUM('pending','preparing','ready','delivered') DEFAULT 'pending',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: reservaciones
CREATE TABLE IF NOT EXISTS reservations (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL,
    date       DATE         NOT NULL,
    time       TIME         NOT NULL,
    guests     TINYINT      DEFAULT 2,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────────────────────────────────
-- Datos semilla – Menú
-- ─────────────────────────────────────────────────────────────────────────
INSERT INTO menu_items (name, description, price, category) VALUES
-- Cafés
('Espresso',         'Intenso y puro, extraído en 25 segundos de perfección.',          2.50,  'cafe'),
('Cappuccino',       'Espresso, leche vaporizada y espuma sedosa en proporción clásica.',4.50,  'cafe'),
('Latte Arábica',    'Doble espresso con leche cremosa y arte latte exclusivo.',          5.00,  'cafe'),
('Americano',        'Espresso diluido en agua caliente, suave y elegante.',             3.00,  'cafe'),
('Café de Olla',     'Tradicional mexicano con canela y piloncillo.',                    3.50,  'cafe'),
('Cold Brew',        'Infusión en frío 24 h; suave, sin acidez.',                        4.50,  'cafe'),
('Mocha',            'Espresso, chocolate belga y leche montada.',                       5.50,  'cafe'),
-- Bebidas no-café
('Matcha Latte',     'Té matcha ceremonial con leche de avena.',                         5.50,  'bebidas'),
('Limonada de menta','Limonada artesanal con menta fresca y hielo triturado.',           4.00,  'bebidas'),
('Chai Latte',       'Mezcla de especias orientales con leche espumada.',                4.50,  'bebidas'),
-- Postres
('Cheesecake de café','Base de galleta, cremoso queso y reducción de espresso.',        6.50,  'postres'),
('Brownie de chocolate','Húmedo, intenso, con nueces y escama de sal.',                 4.50,  'postres'),
('Croissant de almendra','Hojaldrado, relleno de crema de almendras tostadas.',         3.50,  'postres'),
-- Desayunos
('Avocado Toast',    'Pan artesanal, aguacate, huevo pochado y chile de árbol.',         8.50,  'desayunos'),
('Granola Bowl',     'Granola casera, yogur griego, frutos rojos y miel de abeja.',      7.50,  'desayunos'),
('Waffles belgas',   'Waffles dorados con fresas, crema Chantilly y sirope de maple.',   9.00,  'desayunos');
