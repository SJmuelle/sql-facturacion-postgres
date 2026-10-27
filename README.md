# 🧾 Modelo de Facturación — PostgreSQL

![CI](https://github.com/SJmuelle/sql-facturacion-postgres/actions/workflows/ci.yml/badge.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![PL/pgSQL](https://img.shields.io/badge/PL%2FpgSQL-triggers%20%26%20procedures-336791)

Base de datos de facturación con la lógica de negocio en la propia base: cálculo de IVA colombiano (0%, 5%, 19%), consecutivos, reglas de estado y reportes.

## Qué incluye

| Archivo | Contenido |
|---|---|
| `sql/01_esquema.sql` | Tablas, tipos ENUM, restricciones `CHECK`, columnas generadas, índices |
| `sql/02_logica.sql` | Triggers (precio/IVA vigente, recálculo de totales, bloqueo de facturas emitidas) y procedimiento `sp_emitir_factura` |
| `sql/03_vistas.sql` | Ventas mensuales, ranking de clientes (`RANK()`), productos más vendidos |
| `sql/04_datos.sql` | Datos de ejemplo |
| `sql/05_consultas.sql` | Reportes: IVA por tarifa, acumulados con funciones de ventana |
| `tests/pruebas.sql` | Pruebas automáticas con `ASSERT` |

## Modelo

```
clientes 1───* facturas 1───* factura_detalle *───1 productos
```

Reglas implementadas:
- El detalle toma el **precio e IVA vigentes** del producto al momento de facturar.
- Los **totales se recalculan** automáticamente al insertar, modificar o borrar ítems.
- Una factura **emitida no se puede modificar**, y no se puede emitir una factura sin ítems.
- Consecutivo automático `FE-1000`, `FE-1001`, …

## Ejecutar

Con Docker:

```bash
docker compose up -d
psql -h localhost -U postgres -f sql/05_consultas.sql
```

Con un PostgreSQL existente (crea el esquema, carga datos y corre las pruebas):

```bash
PGHOST=localhost PGUSER=postgres PGDATABASE=postgres ./run.sh
```
