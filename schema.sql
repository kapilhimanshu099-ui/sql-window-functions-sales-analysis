-- Sales Analysis
DROP DATABASE IF EXISTS sales_analysis;
CREATE DATABASE sales_analysis;
USE sales_analysis;

CREATE TABLE customers (
  customer_id   INT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  region        VARCHAR(20)  NOT NULL,
  city          VARCHAR(50)
);
CREATE TABLE products (
  product_id   INT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  category     VARCHAR(50),
  list_price   DECIMAL(10,2)
);
CREATE TABLE orders (
  order_id    INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date  DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id)   REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

