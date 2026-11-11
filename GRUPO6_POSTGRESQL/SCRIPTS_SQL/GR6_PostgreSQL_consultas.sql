-- =====================================================================
-- NORTHWIND en PostgreSQL 18
-- Fundamentos de Bases de Datos | EPN | 2026-B | Grupo GR2SW
-- 34 ejemplos de consultas (SELECT, JOIN, UPDATE, DELETE)
--
-- Contenido
--   Parte 1  SELECT básicos                      ejemplos  1 a  8
--   Parte 2  Funciones integradas                ejemplos  9 a 14
--   Parte 3  Agregados, GROUP BY y HAVING        ejemplos 15 a 20
--   Parte 4  INNER JOIN                          ejemplos 21 a 22
--   Parte 5  LEFT JOIN                           ejemplos 23 a 24
--   Parte 6  RIGHT JOIN                          ejemplos 25 a 26
--   Parte 7  UPDATE                              ejemplos 27 a 30
--   Parte 8  DELETE                              ejemplos 31 a 34
--
-- Integrantes:
-- Diego Martinez
-- Rosalia Piedra
-- Esteban Quinapanta
-- Daniela Vivanco 
-- =====================================================================


-- =====================================================================
-- PARTE 1: SELECT básicos (ejemplos 1 a 8)
-- =====================================================================

/*
Ejemplo 1 Funciones de formato.
Muestre el nombre de los productos en mayúsculas y su precio con el símbolo $
(solo los 15 primeros productos)
*/

select upper(productname) as producto, '$' || unitprice as precio, unitsinstock as stock
from products
order by productid
limit 15;

/* 
Ejemplo 2  Funciones de formato.
Muestre el nombre completo de los empleados (apellido en mayúsculas), su cargo
y la fecha de ingreso con formato día/mes/año
*/

select firstname || ' ' || upper(lastname) as empleado, title as cargo,
to_char(hiredate, 'DD/MM/YYYY') as fecha_ingreso
from employees;

/* 
Ejemplo 3 WHERE y ORDER BY.
Muestre el código, nombre y precio de los productos no descontinuados con precio
mayor a 30. Presente del más caro al más barato
*/

select productid, productname, unitprice
from products
where unitprice > 30 and discontinued = false
order by unitprice desc;

/*
Ejemplo 4 WHERE y ORDER BY.
Muestre el código, nombre de la empresa, contacto y ciudad de los clientes de Alemania.
Presente ordenado alfabéticamente por el nombre de la empresa
*/
select customerid, companyname, contactname, city
from customers
where country = 'Germany'
order by companyname;

/*
Ejemplo 5 BETWEEN.
Muestre los pedidos realizados entre el 8 y el 12 de julio de 1996
*/

select orderid, customerid, orderdate, freight
from orders
where orderdate between '1996-07-08' and '1996-07-12'
order by orderdate, orderid;

/*
Ejemplo 6 LIKE.
Muestre los clientes cuyo nombre de empresa empieza con la letra B
*/

select customerid, companyname, city, country
from customers
where companyname like 'B%'
order by companyname;

/*
Ejemplo 7 IN.
Muestre los clientes que están en Alemania, Francia o Suecia
*/

select customerid, companyname, country
from customers
where country in ('Germany', 'France', 'Sweden')
order by country, companyname;

/*
Ejemplo 8DISTINCT.
Muestre los países distintos en los que hay clientes
*/

select distinct country
from customers
order by country;

-- =====================================================================
-- PARTE 2: Funciones integradas de fecha, texto y numéricas
--          (ejemplos 9 a 14)
--
-- Equivalencias con SQL Server:
--   DATEADD  -> operador + INTERVAL     DATEDIFF -> resta de fechas
--   DATENAME -> TO_CHAR                 DATEPART -> EXTRACT
--   DAY      -> EXTRACT(DAY FROM ...)   RIGHT    -> RIGHT (igual)
-- =====================================================================

/*
Ejemplo 9 Función de fecha (equivale a DATEADD).
Muestre el número de pedido, su fecha, la fecha límite de pago (30 días después)
y la fecha un mes después
*/

select orderid, orderdate::date as fecha_pedido,
orderdate::date + 30 as fecha_limite_pago,
(orderdate + interval '1 month')::date as un_mes_despues
from orders
order by orderid
limit 15;

/*
Ejemplo 10 Función de fecha (equivale a DATEDIFF).
Muestre los 15 pedidos que más días tardaron en enviarse (días entre la fecha
del pedido y la fecha de envío)
*/

select orderid, orderdate::date as fecha_pedido, shippeddate::date as fecha_envio,
shippeddate::date - orderdate::date as dias_hasta_envio
from orders
where shippeddate is not null
order by dias_hasta_envio desc, orderid
limit 15;

/*
Ejemplo 11 Función de fecha (equivale a DATENAME).
Muestre el número de pedido, su fecha, el nombre del día de la semana
y el nombre del mes en que se realizó
*/

select orderid, orderdate::date as fecha_pedido,
trim(to_char(orderdate, 'Day')) as nombre_dia,
trim(to_char(orderdate, 'Month')) as nombre_mes
from orders
order by orderdate, orderid
limit 15;

/*
Ejemplo 12 . Función de fecha (equivale a DATEPART).
Muestre el número de pedido, su fecha, el año, trimestre, mes y semana del año
*/
select orderid, orderdate::date as fecha_pedido,
extract(year from orderdate) as anio,
extract(quarter from orderdate) as trimestre,
extract(month from orderdate) as mes,
extract(week from orderdate) as semana_anio
from orders
order by orderid
limit 15;

/*
Ejecmplo 13 Función de fecha (equivale a DAY) y funciones numéricas.
Muestre el número de pedido, la fecha de envío, el día del mes de envío, el flete,
el flete con 15% de IVA redondeado a un decimal y el flete redondeado hacia arriba
*/
select orderid, shippeddate::date as fecha_envio,
extract(day from shippeddate) as dia_envio,
freight,
round(freight * 1.15, 1) as flete_con_iva_15,
ceil(freight) as flete_redondeado_arriba
from orders
where shippeddate is not null
order by dia_envio, orderid
limit 15;

/* Ejemplo 14 Función de texto (equivale a RIGHT).
Muestre el código del cliente y sus últimos 3 caracteres, el nombre de la empresa
y sus últimos 4 caracteres, y la longitud del nombre
*/

select customerid, right(customerid, 3) as ultimos_3_codigo,
companyname, right(companyname, 4) as ultimos_4_nombre,
length(companyname) as longitud_nombre
from customers
order by customerid
limit 15;

-- =====================================================================
-- PARTE 3: Funciones de agregado, GROUP BY y HAVING (ejemplos 15 a 20)
-- =====================================================================

-- Ejemplo 15: COUNT con GROUP BY y HAVING
-- Cantidad de clientes por país, solo países con 5 o más clientes.
SELECT country AS pais,
       COUNT(*) AS total_clientes
FROM customers
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY total_clientes DESC, pais;


-- Ejemplo 16: SUM y COUNT con GROUP BY y HAVING
-- Total de cada pedido (precio x cantidad con descuento), solo pedidos
-- cuyo total supere 5000.
SELECT order_id AS pedido,
       COUNT(product_id) AS lineas_detalle,
       ROUND(SUM(unit_price * quantity * (1 - discount))::numeric, 2) AS total_pedido
FROM order_details
GROUP BY order_id
HAVING SUM(unit_price * quantity * (1 - discount)) > 5000
ORDER BY total_pedido DESC;


-- Ejemplo 17: AVG, MIN, MAX y COUNT con GROUP BY y HAVING
-- Estadísticas de precios por categoría, solo categorías con precio
-- promedio mayor a 25.
SELECT category_id AS categoria,
       COUNT(*) AS total_productos,
       ROUND(AVG(unit_price)::numeric, 2) AS precio_promedio,
       MIN(unit_price) AS precio_minimo,
       MAX(unit_price) AS precio_maximo
FROM products
GROUP BY category_id
HAVING AVG(unit_price) > 25
ORDER BY precio_promedio DESC;


-- Ejemplo 18: COUNT con GROUP BY y HAVING
-- Pedidos atendidos por cada empleado, solo empleados con más de 100.
SELECT employee_id AS empleado,
       COUNT(*) AS total_pedidos
FROM orders
GROUP BY employee_id
HAVING COUNT(*) > 100
ORDER BY total_pedidos DESC;


-- Ejemplo 19: SUM, AVG y COUNT con GROUP BY y HAVING
-- Costo de flete por país de envío, solo países con flete total mayor a 1000.
SELECT ship_country AS pais_envio,
       COUNT(*) AS total_pedidos,
       ROUND(SUM(freight)::numeric, 2) AS flete_total,
       ROUND(AVG(freight)::numeric, 2) AS flete_promedio
FROM orders
GROUP BY ship_country
HAVING SUM(freight) > 1000
ORDER BY flete_total DESC;


-- Ejemplo 20: SUM y MAX con GROUP BY y HAVING
-- Unidades vendidas por producto, solo productos con más de 1000 unidades.
SELECT product_id AS producto,
       SUM(quantity) AS unidades_vendidas,
       MAX(quantity) AS mayor_cantidad_en_una_linea
FROM order_details
GROUP BY product_id
HAVING SUM(quantity) > 1000
ORDER BY unidades_vendidas DESC;


-- =====================================================================
-- PARTE 4: INNER JOIN (ejemplos 21 a 22)
-- =====================================================================

-- Ejemplo 21: INNER JOIN de 2 tablas (products y categories)
-- Productos con precio mayor a 30 junto con el nombre de su categoría.
SELECT p.product_id AS codigo,
       p.product_name AS producto,
       c.category_name AS categoria,
       p.unit_price AS precio
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.unit_price > 30
ORDER BY c.category_name, p.product_name;


-- Ejemplo 22: INNER JOIN de 3 tablas (orders, customers y employees)
-- Pedidos con el nombre del cliente y del empleado que los atendió
-- (se muestran los primeros 15).
SELECT o.order_id AS pedido,
       c.company_name AS cliente,
       e.first_name || ' ' || e.last_name AS empleado,
       o.order_date AS fecha_pedido,
       o.ship_country AS pais_envio
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
ORDER BY o.order_id
LIMIT 15;


-- =====================================================================
-- PARTE 5: LEFT JOIN (ejemplos 23 a 24)
-- =====================================================================

-- Ejemplo 23: LEFT JOIN (customers y orders)
-- Clientes que nunca han realizado un pedido.
SELECT c.customer_id AS cliente,
       c.company_name AS empresa,
       c.country AS pais,
       o.order_id AS pedido
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.company_name;


-- Ejemplo 24: LEFT JOIN sobre la misma tabla (employees y employees)
-- Cada empleado con su jefe; quien no tiene jefe aparece como 'Sin jefe'.
SELECT e.employee_id AS codigo,
       e.first_name || ' ' || e.last_name AS empleado,
       e.title AS cargo,
       COALESCE(j.first_name || ' ' || j.last_name, 'Sin jefe') AS jefe
FROM employees e
LEFT JOIN employees j ON e.reports_to = j.employee_id
ORDER BY e.employee_id;


-- =====================================================================
-- PARTE 6: RIGHT JOIN (ejemplos 25 a 26)
-- =====================================================================

-- Ejemplo 25: RIGHT JOIN (order_details y products)
-- Los 10 productos menos vendidos; con RIGHT JOIN se conservan todos los
-- productos aunque no tengan ventas (COALESCE los muestra con 0).
SELECT p.product_id AS codigo,
       p.product_name AS producto,
       COALESCE(SUM(od.quantity), 0) AS unidades_vendidas
FROM order_details od
RIGHT JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY unidades_vendidas ASC, p.product_name
LIMIT 10;


-- Ejemplo 26: RIGHT JOIN (products y categories)
-- Cantidad de productos y unidades en stock por categoría; con RIGHT JOIN
-- se conservan todas las categorías aunque no tengan productos.
SELECT c.category_id AS codigo,
       c.category_name AS categoria,
       COUNT(p.product_id) AS total_productos,
       COALESCE(SUM(p.units_in_stock), 0) AS unidades_en_stock
FROM products p
RIGHT JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_productos DESC, c.category_name;


-- =====================================================================
-- PARTE 7: UPDATE (ejemplos 27 a 30)
-- Cada ejemplo muestra primero las filas afectadas con un SELECT y
-- luego ejecuta el UPDATE con RETURNING para ver el resultado.
-- =====================================================================

-- Ejemplo 27: UPDATE con WHERE
-- Sube 10 % el precio de los productos de la categoría 1.
SELECT product_id, product_name, unit_price
FROM products
WHERE category_id = 1
ORDER BY product_id;

UPDATE products
SET unit_price = ROUND((unit_price * 1.10)::numeric, 2)
WHERE category_id = 1
RETURNING product_id, product_name, unit_price;


-- Ejemplo 28: UPDATE con WHERE
-- Suma 20 unidades de stock a los productos con menos de 10 en bodega.
SELECT product_id, product_name, units_in_stock
FROM products
WHERE units_in_stock < 10
ORDER BY product_id;

UPDATE products
SET units_in_stock = units_in_stock + 20
WHERE units_in_stock < 10
RETURNING product_id, product_name, units_in_stock;


-- Ejemplo 29: UPDATE con subconsulta
-- Baja 5 % el precio de los productos que cuestan más que el promedio.
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY product_id;

UPDATE products
SET unit_price = ROUND((unit_price * 0.95)::numeric, 2)
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
RETURNING product_id, product_name, unit_price;


-- Ejemplo 30: UPDATE con subconsulta
-- Sube 1 el precio de los productos de la categoría 'Beverages'.
SELECT product_id, product_name, unit_price
FROM products
WHERE category_id IN (SELECT category_id FROM categories WHERE category_name = 'Beverages')
ORDER BY product_id;

UPDATE products
SET unit_price = unit_price + 1
WHERE category_id IN (SELECT category_id FROM categories WHERE category_name = 'Beverages')
RETURNING product_id, product_name, unit_price;


-- =====================================================================
-- PARTE 8: DELETE (ejemplos 31 a 34)
-- Cada ejemplo inserta filas de prueba, muestra la tabla, elimina con
-- WHERE y RETURNING, y vuelve a mostrar la tabla para comprobarlo.
-- =====================================================================

-- Ejemplo 31: DELETE con WHERE (igualdad)
-- Elimina un transportista de prueba por su nombre exacto.
INSERT INTO shippers (shipper_id, company_name, phone) VALUES (7, 'Prueba Envios A', '000-0001');
INSERT INTO shippers (shipper_id, company_name, phone) VALUES (8, 'Prueba Envios B', '000-0002');

SELECT * FROM shippers ORDER BY shipper_id;

DELETE FROM shippers WHERE company_name = 'Prueba Envios A' RETURNING *;

SELECT * FROM shippers ORDER BY shipper_id;


-- Ejemplo 32: DELETE con WHERE (LIKE)
-- Elimina los transportistas de prueba que quedan, por patrón de nombre.
SELECT * FROM shippers WHERE company_name LIKE 'Prueba Envios%';

DELETE FROM shippers WHERE company_name LIKE 'Prueba Envios%' RETURNING *;

SELECT * FROM shippers ORDER BY shipper_id;


-- Ejemplo 33: DELETE con WHERE
-- Elimina una categoría de prueba por su nombre.
INSERT INTO categories (category_id, category_name, description) VALUES (9, 'Categoria Prueba', 'Solo para DELETE');

SELECT category_id, category_name FROM categories ORDER BY category_id;

DELETE FROM categories WHERE category_name = 'Categoria Prueba' RETURNING category_id, category_name, description;

SELECT category_id, category_name FROM categories ORDER BY category_id;


-- Ejemplo 34: DELETE con WHERE
-- Elimina un cliente de prueba por su código y comprueba que ya no existe.
INSERT INTO customers (customer_id, company_name, country) VALUES ('ZZZZZ', 'Cliente Prueba', 'Ecuador');

SELECT customer_id, company_name, country FROM customers WHERE customer_id = 'ZZZZZ';

DELETE FROM customers WHERE customer_id = 'ZZZZZ' RETURNING customer_id, company_name, country;

SELECT COUNT(*) FROM customers WHERE customer_id = 'ZZZZZ';
