/*


----------------BASES DE DATOS--------------------

INTEGRANTES:
1.	Martínez Diego
2.	Piedra Rosalía
3.	Quinapanta Esteban
4.	Vivanco Daniela

* CONSULTAS SOBRE LA BASE DE DATOS NORTHWIND (PostgreSQL)

•	8 ejemplos de SELECT. Incluya 2 que utilicen modificadores de formato con el uso de funciones, 2 que usen la cláusula where y order by, 4 que incluyan between, like, in, distinct.
•	6 ejemplos de SELECT con uso de funciones integradas sobre tipos de datos (fecha, character, numérico)
•	6 ejemplos de SELECT con funciones de agregado, cláusula GROUP BY, cláusula HAVING
•	2 ejemplos de SELECT con Join, una de ellas debe contener un join de tres tablas. 
•	2 ejemplos de SELECT con left join y 2 ejemplos con right join.  
•	4 ejemplos de operaciones de UPDATE, 2 que utilicen cláusula where y 2 que utilicen subconsultas.
•	4 ejemplos de operaciones de DELETE, que utilicen la cláusula where. 

*/

--8 ejemplos de SELECT.

/*
1. Funciones de formato.
Muestre el nombre de los productos en mayúsculas y su precio con el símbolo $
(solo los 15 primeros productos)
*/

select upper(productname) as producto, '$' || unitprice as precio, unitsinstock as stock
from products
order by productid
limit 15;

/*
2. Funciones de formato.
Muestre el nombre completo de los empleados (apellido en mayúsculas), su cargo
y la fecha de ingreso con formato día/mes/año
*/

select firstname || ' ' || upper(lastname) as empleado, title as cargo,
       to_char(hiredate, 'DD/MM/YYYY') as fecha_ingreso
from employees;

/*
3. WHERE y ORDER BY.
Muestre el código, nombre y precio de los productos no descontinuados con precio
mayor a 30. Presente del más caro al más barato
*/

select productid, productname, unitprice
from products
where unitprice > 30 and discontinued = false
order by unitprice desc;

/*
4. WHERE y ORDER BY.
Muestre el código, nombre de la empresa, contacto y ciudad de los clientes de Alemania.
Presente ordenado alfabéticamente por el nombre de la empresa
*/

select customerid, companyname, contactname, city
from customers
where country = 'Germany'
order by companyname;

/*
5. BETWEEN.
Muestre los pedidos realizados entre el 8 y el 12 de julio de 1996
*/

select orderid, customerid, orderdate, freight
from orders
where orderdate between '1996-07-08' and '1996-07-12'
order by orderdate, orderid;

/*
6. LIKE.
Muestre los clientes cuyo nombre de empresa empieza con la letra B
*/

select customerid, companyname, city, country
from customers
where companyname like 'B%'
order by companyname;

/*
7. IN.
Muestre los clientes que están en Alemania, Francia o Suecia
*/

select customerid, companyname, country
from customers
where country in ('Germany', 'France', 'Sweden')
order by country, companyname;

/*
8. DISTINCT.
Muestre los países distintos en los que hay clientes
*/

select distinct country
from customers
order by country;

--6 ejemplos de SELECT con uso de funciones integradas sobre tipos de datos (fecha, character, numérico)
/*
1. Función de fecha (DATEADD).
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
2. Función de fecha(DATEDIFF)
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
3. Función de fecha (DATENAME).
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
4. Función de fecha (DATEPART).
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
5. Función de fecha (DAY) y funciones numéricas.
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

/*
6. Función de texto (RIGHT).
Muestre el código del cliente y sus últimos 3 caracteres, el nombre de la empresa
y sus últimos 4 caracteres, y la longitud del nombre
*/

select customerid, right(customerid, 3) as ultimos_3_codigo,
       companyname, right(companyname, 4) as ultimos_4_nombre,
       length(companyname) as longitud_nombre
from customers
order by customerid
limit 15;

--6 ejemplos de SELECT con funciones de agregado, cláusula GROUP BY, cláusula HAVING

/*
1. Muestre el número de clientes por país.
Presente solo los países que tienen 5 o más clientes
*/

select country, count(*) as total_clientes
from customers
group by country
having count(*) >= 5
order by total_clientes desc, country;

/*
2. Muestre el apellido y nombre de los empleados y el número de pedidos que ha atendido cada uno.
Presente solo a los empleados que han atendido más de 100 pedidos
*/

select e.lastname, e.firstname, count(*) as total_pedidos
from employees e join orders o
    on e.employeeid = o.employeeid
group by e.lastname, e.firstname
having count(*) > 100
order by total_pedidos desc;

/*
3. Muestre el código del producto y la suma de unidades vendidas en los pedidos.
Presente solo los productos con más de 1000 unidades vendidas
*/

select productid, sum(quantity) as unidades_vendidas
from order_details
group by productid
having sum(quantity) > 1000
order by unidades_vendidas desc, productid;

/*
4. Muestre el nombre de la categoría, el número de productos en esa categoría
y el precio promedio de los productos.
Solo muestre los grupos en los que el precio promedio sea mayor a 30
*/

select c.categoryname, count(*) as total_productos, round(avg(p.unitprice), 2) as precio_promedio
from categories c join products p
    on c.categoryid = p.categoryid
group by c.categoryname
having avg(p.unitprice) > 30
order by precio_promedio desc;

/*
5. Muestre por cada país de envío el número de pedidos, el flete total y el flete promedio.
Presente solo los países con flete total mayor a 5000
*/

select shipcountry, count(*) as total_pedidos, sum(freight) as flete_total,
       round(avg(freight), 2) as flete_promedio
from orders
group by shipcountry
having sum(freight) > 5000
order by flete_total desc;

/*
6. Muestre el nombre del proveedor, el número de productos que ofrece, el precio máximo
y el precio mínimo de sus productos. Presente solo a los proveedores con 4 o más productos
*/

select s.companyname, count(*) as total_productos, max(p.unitprice) as precio_maximo,
       min(p.unitprice) as precio_minimo
from suppliers s join products p
    on s.supplierid = p.supplierid
group by s.companyname
having count(*) >= 4
order by total_productos desc, s.companyname;

--2 ejemplos de SELECT con Join, una de ellas debe contener un join de tres tablas. 

/*
1. Join de dos tablas.
Muestre el código, nombre y precio de los productos con precio mayor a 50
y el nombre de su categoría
*/

select p.productid, p.productname, p.unitprice, c.categoryname
from products p join categories c
    on p.categoryid = c.categoryid
where p.unitprice > 50
order by p.unitprice desc;

/*
2. Join de tres tablas.
Muestre el número de pedido, la fecha, el nombre de la empresa cliente y el apellido
del empleado que atendió el pedido (solo los 15 primeros pedidos)
*/

select o.orderid, o.orderdate::date as fecha, c.companyname, e.lastname as empleado
from orders o join customers c
    on o.customerid = c.customerid
join employees e
    on o.employeeid = e.employeeid
order by o.orderid
limit 15;

--2 ejemplos de SELECT con left join y 2 ejemplos con right join.  
/*
left join
1. Muestre los clientes que no han realizado ningún pedido
*/

select c.customerid, c.companyname, c.country
from customers c left join orders o
    on c.customerid = o.customerid
where o.orderid is null;

/*
left join
2. Muestre el código y apellido de cada empleado con el apellido de su jefe.
El empleado que no tiene jefe aparece con valor nulo
*/

select e.employeeid, e.lastname as empleado, j.lastname as jefe
from employees e left join employees j
    on e.reportsto = j.employeeid
order by e.employeeid;

/*
right join
1. Muestre todos los clientes con el número de pedidos que tienen, aunque no tengan pedidos.
Presente los 10 clientes con menos pedidos
*/

select c.customerid, c.companyname, count(o.orderid) as total_pedidos
from orders o right join customers c
    on o.customerid = c.customerid
group by c.customerid, c.companyname
order by total_pedidos, c.customerid
limit 10;

/*
right join
2. Muestre todas las categorías con el número de productos y el stock total,
aunque la categoría no tenga productos
*/

select c.categoryname, count(p.productid) as total_productos, sum(p.unitsinstock) as stock_total
from products p right join categories c
    on p.categoryid = c.categoryid
group by c.categoryname
order by c.categoryname;

/*
Los ejemplos siguientes modifican los datos.
Por lo tanto se deben ejecutar en orden 
*/

--4 ejemplos de operaciones de UPDATE, 2 que utilicen cláusula where y 2 que utilicen subconsultas.

/*
Where
1. Suba un 10% el precio de los productos de la categoría 1 (Beverages)
*/

select productid, productname, unitprice
from products
where categoryid = 1
order by productid;

update products
set unitprice = unitprice * 1.10
where categoryid = 1;

select productid, productname, unitprice
from products
where categoryid = 1
order by productid;

/*
Where
2. Aumente en 50 unidades el stock de los productos cuyo stock es menor al nivel de reposición
*/

select productid, productname, unitsinstock, reorderlevel
from products
where unitsinstock < reorderlevel
order by productid
limit 5;

update products
set unitsinstock = unitsinstock + 50
where unitsinstock < reorderlevel;

select productid, productname, unitsinstock, reorderlevel
from products
where productid in (2, 3, 11, 21, 30)
order by productid;

/*
SUBCONSULTAS
3. Suba un 5% el precio de los productos entregados por el proveedor 'Exotic Liquids'
*/

select productid, productname, unitprice, supplierid
from products
where supplierid = 1
order by productid;

update products
set unitprice = unitprice * 1.05
where supplierid =
    (select supplierid
     from suppliers
     where companyname = 'Exotic Liquids');

select productid, productname, unitprice, supplierid
from products
where supplierid = 1
order by productid;

/*
SUBCONSULTAS
4. Suba un 10% el flete de los pedidos de los clientes que están en Alemania
*/

select orderid, customerid, freight
from orders
where customerid in
    (select customerid
     from customers
     where country = 'Germany')
order by orderid
limit 10;

update orders
set freight = freight * 1.10
where customerid in
    (select customerid
     from customers
     where country = 'Germany');

select orderid, customerid, freight
from orders
where customerid in
    (select customerid
     from customers
     where country = 'Germany')
order by orderid
limit 10;

-- 4 ejemplos de operaciones de DELETE, que utilicen la cláusula where. 
/*
1. Elimine el cliente 'FISSA', que no tiene pedidos
*/

select customerid, companyname
from customers
where customerid = 'FISSA';

delete from customers
where customerid = 'FISSA';

select customerid, companyname
from customers
where customerid = 'FISSA';

/*
2. Elimine las asignaciones de territorios del empleado 9
*/

select employeeid, territoryid
from employeeterritories
where employeeid = 9;

delete from employeeterritories
where employeeid = 9;

select employeeid, territoryid
from employeeterritories
where employeeid = 9;

/*
3. Elimine los detalles del pedido 10248
(primero se borran los detalles porque dependen del pedido)
*/

select orderid, productid, unitprice, quantity
from order_details
where orderid = 10248;

delete from order_details
where orderid = 10248;

select orderid, productid, unitprice, quantity
from order_details
where orderid = 10248;

/*
4. Elimine el pedido 10248, que ya no tiene detalles
*/

select orderid, customerid, orderdate
from orders
where orderid = 10248;

delete from orders
where orderid = 10248;

select orderid, customerid, orderdate
from orders
where orderid = 10248;
