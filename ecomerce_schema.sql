-- =========================================================================
-- ИТГООВЫЙ СКРИПТ: СХЕМА БАЗЫ ДАННЫХ ИНТЕРНЕТ-МАГАЗИНА (PostgreSQL)
-- =========================================================================

-- 1. Удаление существующих таблиц в правильном порядке (с учетом зависимостей)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- 2. Создание таблицы пользователей
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Создание таблицы категорий товаров (поддерживает древовидную структуру)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT REFERENCES categories(category_id) ON DELETE SET NULL
);

-- 4. Создание таблицы товаров
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE
);

-- 5. Создание таблицы заказов (шапка заказа)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE RESTRICT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'NEW',
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT NOT NULL
);

-- 6. Создание таблицы позиций заказа (детали заказа, связь "многие ко многим")
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);


-- =========================================================================
-- НАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- =========================================================================

-- Пользователи
INSERT INTO users (email, password_hash, full_name, phone) VALUES
('daniyar@example.com', 'hash_pass_123', 'Данияр Рахимбеков', '+77015556677'),
('alexey@example.com', 'hash_pass_456', 'Алексей Смирнов', '+77023334455'),
('elena@example.com', 'hash_pass_789', 'Елена Васильева', '+77051112233'),
('timur@example.com', 'hash_pass_321', 'Тимур Каримов', '+77079998877');

-- Категории
INSERT INTO categories (name, parent_id) VALUES
('Электроника', NULL),          -- ID 1
('Смартфоны', 1),               -- ID 2
('Бытовая техника', NULL),      -- ID 3
('Ноутбуки', 1),                -- ID 4
('Аксессуары', 1);              -- ID 5

-- Товары
INSERT INTO products (category_id, name, description, price, stock_quantity) VALUES
(2, 'Google Pixel 9 Pro XL', 'Смартфон 256GB', 450000.00, 10),
(2, 'Xiaomi Mi Router 4A', 'Гигабитный роутер', 15000.00, 25),
(3, 'Утюг Philips', 'Паровой утюг', 25000.00, 15),
(4, 'MacBook Pro 14 M3', 'Ноутбук для работы и графики', 850000.00, 5),
(4, 'ASUS TUF Gaming A15', 'Игровой ноутбук', 520000.00, 8),
(5, 'Беспроводная мышь Logitech', 'Эргономичная мышь', 18000.00, 40),
(5, 'Механическая клавиатура', 'RGB подсветка, синие свитчи', 35000.00, 20);

-- Заказы
INSERT INTO orders (user_id, status, total_amount, shipping_address) VALUES
(1, 'PAID', 465000.00, 'г. Астана, ул. Туркестана, 28'),
(2, 'PROCESSING', 885000.00, 'г. Алматы, пр. Достык, 12'),
(3, 'NEW', 538000.00, 'г. Шымкент, ул. Тауке хана, 45'),
(1, 'DELIVERED', 53000.00, 'г. Астана, ул. Сарайшык, 5');

-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 450000.00),
(1, 2, 1, 15000.00),
(2, 4, 1, 850000.00),
(2, 7, 1, 35000.00),
(3, 5, 1, 520000.00),
(3, 6, 1, 18000.00),
(4, 7, 1, 35000.00),
(4, 6, 1, 18000.00);