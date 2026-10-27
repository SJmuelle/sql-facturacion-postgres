#!/usr/bin/env bash
# Crea el esquema, carga datos de ejemplo y ejecuta las pruebas.
# Uso: PGHOST=localhost PGUSER=postgres PGDATABASE=postgres ./run.sh
set -euo pipefail
for f in sql/01_esquema.sql sql/02_logica.sql sql/03_vistas.sql sql/04_datos.sql tests/pruebas.sql; do
  echo "→ $f"
  psql -v ON_ERROR_STOP=1 -q -f "$f"
done
echo "✔ Base de datos lista y pruebas superadas"
