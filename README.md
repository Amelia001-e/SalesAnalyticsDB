# 📊 Sales Analytics Dashboard

Proyecto de análisis de datos enfocado en la construcción de un **dashboard de ventas en Power BI**, utilizando **SQL, modelado de datos y DAX** para la generación de indicadores clave de negocio.

---

## 🎯 Objetivo del proyecto

Desarrollar una solución de análisis que permita:

* Centralizar la información de ventas, clientes y productos
* Medir el desempeño comercial mediante KPIs
* Analizar la evolución de ingresos en el tiempo
* Identificar categorías de productos con mayor demanda

Este proyecto simula un **escenario empresarial real**, donde un analista de datos debe transformar datos transaccionales en información útil para la toma de decisiones.

---

## 🛠 Tecnologías utilizadas

* **SQL Server** → creación de base de datos, tablas y carga de 5,000 registros simulados
* **Power BI** → modelado de datos, medidas DAX y visualización
* **DAX** → cálculo de KPIs y métricas de negocio
* **GitHub** → control de versiones y documentación del proyecto

---

## 🗂 Estructura del repositorio

```
sales-analytics-dashboard/
│
├── sql/
│   ├── create_tables.sql
│   ├── insert_data.sql
│   └── analysis_queries.sql
│
├── powerbi/
│   └── sales_dashboard.pbix
│
└── README.md
```

---

## 📈 KPIs desarrollados

El dashboard incluye los siguientes indicadores clave:

* **Ingresos totales**
* **Total de ventas registradas**
* **Total de clientes activos**
* **Ticket promedio por compra**
* **Evolución mensual de ingresos**
* **Distribución de ventas por categoría de producto**

Estos KPIs permiten evaluar el rendimiento comercial y detectar tendencias de consumo.

---

## 📊 Principales hallazgos

* Los ingresos presentan una **tendencia creciente con variaciones estacionales** durante el año.
* El **ticket promedio** permite estimar el valor de cada transacción y apoyar estrategias de precios.
* Algunas **categorías concentran mayor volumen de ventas**, lo que facilita priorizar inventario y campañas comerciales.

---

## 🚀 Cómo usar el proyecto

1. Ejecutar los scripts SQL en el siguiente orden:

   * `create_tables.sql`
   * `insert_data.sql`
2. Abrir el archivo **Power BI (.pbix)** incluido en la carpeta `powerbi/`.
3. Explorar los KPIs y visualizaciones del dashboard.

---
