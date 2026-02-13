-- =============================================
-- CREACIÓN DE BASE DE DATOS
-- =============================================
CREATE DATABASE SalesAnalyticsDB;
GO

USE SalesAnalyticsDB;
GO

CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    ciudad NVARCHAR(100) NOT NULL,
    fecha_registro DATE NOT NULL
);
GO

CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto NVARCHAR(150) NOT NULL,
    categoria NVARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);
GO


CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (id_cliente)
        REFERENCES Clientes(id_cliente)
);
GO

CREATE TABLE DetalleVentas (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_DetalleVentas_Ventas FOREIGN KEY (id_venta)
        REFERENCES Ventas(id_venta),
    CONSTRAINT FK_DetalleVentas_Productos FOREIGN KEY (id_producto)
        REFERENCES Productos(id_producto)
);
GO

-- =============================================
-- GENERACIÓN DE DATOS MASIVOS (≈5,000 REGISTROS)
-- =============================================


-- INSERTAR CLIENTES (5000) - VERSIÓN CORREGIDA
SET NOCOUNT ON;

;WITH Numeros AS (
    SELECT TOP (5000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Clientes (nombre, ciudad, fecha_registro)
SELECT
    CONCAT('Cliente ', n),
    CASE (ABS(CHECKSUM(NEWID())) % 5)
        WHEN 0 THEN 'Guatemala'
        WHEN 1 THEN 'Mixco'
        WHEN 2 THEN 'Villa Nueva'
        WHEN 3 THEN 'Quetzaltenango'
        ELSE 'Escuintla'
    END,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1000, CAST(GETDATE() AS DATE))
FROM Numeros;
GO

-- INSERTAR PRODUCTOS (5000) 
;WITH Numeros AS (
SELECT TOP (5000)
ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
FROM sys.objects a
CROSS JOIN sys.objects b
)
INSERT INTO Productos (nombre_producto, categoria, precio)
SELECT
CONCAT('Producto ', n),
CASE (ABS(CHECKSUM(NEWID())) % 5)
WHEN 0 THEN 'Electrónica'
WHEN 1 THEN 'Ropa'
WHEN 2 THEN 'Hogar'
WHEN 3 THEN 'Deportes'
ELSE 'Alimentos'
END,
CAST((ABS(CHECKSUM(NEWID())) % 5000 + 100) AS DECIMAL(10,2))
FROM Numeros;
GO

-- INSERTAR VENTAS (5000)
;WITH Numeros AS (
SELECT TOP (5000)
ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
FROM sys.objects a
CROSS JOIN sys.objects b
)
INSERT INTO Ventas (id_cliente, fecha_venta, total)
SELECT
(SELECT TOP 1 id_cliente FROM Clientes ORDER BY NEWID()),
DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, CAST(GETDATE() AS DATE)),
CAST((ABS(CHECKSUM(NEWID())) % 10000 + 50) AS DECIMAL(12,2))
FROM Numeros;
GO

-- INSERTAR DETALLE DE VENTAS (5000)
;WITH Numeros AS (
SELECT TOP (5000)
ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
FROM sys.objects a
CROSS JOIN sys.objects b
)
INSERT INTO DetalleVentas (id_venta, id_producto, cantidad, subtotal)
SELECT
v.id_venta,
p.id_producto,
cantidad = ABS(CHECKSUM(NEWID())) % 5 + 1,
subtotal = (ABS(CHECKSUM(NEWID())) % 5 + 1) * p.precio
FROM Numeros n
CROSS APPLY (SELECT TOP 1 id_venta FROM Ventas ORDER BY NEWID()) v
CROSS APPLY (SELECT TOP 1 id_producto, precio FROM Productos ORDER BY NEWID()) p;
GO


-- =============================================
-- CONSULTAS
-- =============================================
--1. Top 10 clientes con mayor gasto
SELECT TOP 10 c.nombre, SUM(v.total) AS total_gastado
FROM Clientes c
JOIN Ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.nombre
ORDER BY total_gastado DESC;


-- 2. Ventas totales por mes
SELECT
YEAR(fecha_venta) AS anio,
MONTH(fecha_venta) AS mes,
SUM(total) AS ventas_totales
FROM Ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- 3. Producto más vendido por cantidad
SELECT TOP 1 p.nombre_producto, SUM(d.cantidad) AS total_vendido
FROM DetalleVentas d
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY total_vendido DESC;


-- 4. Ticket promedio por cliente
SELECT c.nombre, AVG(v.total) AS ticket_promedio
FROM Clientes c
JOIN Ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.nombre
ORDER BY ticket_promedio DESC;

-- 5. Clientes sin compras en los últimos 90 días
SELECT c.nombre
FROM Clientes c
LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
AND v.fecha_venta >= DATEADD(DAY, -90, GETDATE())
WHERE v.id_venta IS NULL;

-- =============================================
-- VISTAS SQL PROFESIONALES
-- =============================================
-- Vista: Top clientes por gasto total
CREATE VIEW vw_top_clientes AS
SELECT c.id_cliente, c.nombre, SUM(v.total) AS total_gastado
FROM Clientes c
JOIN Ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre;
GO

-- Vista: Ventas mensuales
CREATE VIEW vw_ventas_mensuales AS
SELECT
YEAR(fecha_venta) AS anio,
MONTH(fecha_venta) AS mes,
SUM(total) AS ventas_totales
FROM Ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta);
GO

-- Vista: Productos más vendidos
CREATE VIEW vw_productos_populares AS
SELECT p.id_producto, p.nombre_producto, SUM(d.cantidad) AS total_vendido
FROM DetalleVentas d
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre_producto;
GO

-- =============================================
-- STORED PROCEDURES PROFESIONALES
-- =============================================

-- 1. Ventas por rango de fechas
CREATE PROCEDURE sp_ventas_por_fecha
@fecha_inicio DATE,
@fecha_fin DATE
AS
BEGIN
SET NOCOUNT ON;

SELECT
v.id_venta,
c.nombre AS cliente,
v.fecha_venta,
v.total
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
WHERE v.fecha_venta BETWEEN @fecha_inicio AND @fecha_fin
ORDER BY v.fecha_venta;
END;
GO

-- 2. Buscar clientes por ciudad
CREATE PROCEDURE sp_clientes_por_ciudad
@ciudad NVARCHAR(100)
AS
BEGIN
SET NOCOUNT ON;

SELECT id_cliente, nombre, ciudad, fecha_registro
FROM Clientes
WHERE ciudad = @ciudad
ORDER BY nombre;
END;
GO

-- 3. Top productos más vendidos con parámetro
CREATE PROCEDURE sp_top_productos
@top INT = 10
AS
BEGIN
SET NOCOUNT ON;

SELECT TOP (@top)
p.nombre_producto,
SUM(d.cantidad) AS total_vendido
FROM DetalleVentas d
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY total_vendido DESC;
END;
GO


-- 4. Resumen general de ventas
CREATE PROCEDURE sp_resumen_ventas
AS
BEGIN
SET NOCOUNT ON;

SELECT
COUNT(DISTINCT id_cliente) AS total_clientes,
COUNT(*) AS total_ventas,
SUM(total) AS ingresos_totales,
AVG(total) AS ticket_promedio
FROM Ventas;
END;
GO

---Ejecución
EXEC sp_ventas_por_fecha '2024-01-01', '2026-12-31';
EXEC sp_clientes_por_ciudad 'Guatemala';
EXEC sp_top_productos 5;
EXEC sp_resumen_ventas;


---Consultas
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DetalleVentas';

Select * from Productos

SELECT DISTINCT categoria
FROM Productos;

SELECT 
    p.categoria,
    COUNT(*) AS CantidadVentas
FROM DetalleVentas d
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY CantidadVentas DESC;

SELECT COUNT(*) FROM Productos;

UPDATE d
SET id_producto = p.id_producto
FROM DetalleVentas d
JOIN (
    SELECT 
        id_producto,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn
    FROM Productos
) p
ON p.rn = (
    ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM Productos)
) + 1;


SELECT 
    p.categoria,
    COUNT(*) AS CantidadVentas
FROM DetalleVentas d
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY CantidadVentas DESC;


