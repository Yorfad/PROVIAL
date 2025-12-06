# Docker Setup - Sistema Provial

## Servicios Disponibles

### Servicios Principales (siempre activos)
- **postgres**: PostgreSQL 16 en puerto 5432
- **redis**: Redis 7 en puerto 6379

### Servicios de Desarrollo (perfil `tools`)
- **pgadmin**: Interfaz web para PostgreSQL en http://localhost:5050
  - Email: admin@provial.local
  - Password: admin
- **redis-commander**: Interfaz web para Redis en http://localhost:8081

## Uso Básico

### Iniciar servicios principales

```bash
# Desde la raíz del proyecto
docker-compose up -d
```

### Iniciar con herramientas de desarrollo

```bash
docker-compose --profile tools up -d
```

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo PostgreSQL
docker-compose logs -f postgres

# Solo Redis
docker-compose logs -f redis
```

### Detener servicios

```bash
# Detener pero mantener datos
docker-compose stop

# Detener y eliminar contenedores (datos se mantienen en volumes)
docker-compose down

# Detener, eliminar contenedores Y volúmenes (PELIGRO: elimina datos)
docker-compose down -v
```

## Ejecutar Migraciones

### Opción 1: Desde el host

```bash
# Asegurarse que PostgreSQL está corriendo
docker-compose up -d postgres

# Esperar a que esté listo
sleep 5

# Ejecutar migraciones
cd migrations
./run_migrations.sh postgresql://postgres:postgres@localhost:5432/provial_db
```

### Opción 2: Dentro del contenedor

```bash
# Copiar migraciones al contenedor
docker cp migrations/. provial_postgres:/tmp/migrations/

# Ejecutar dentro del contenedor
docker exec provial_postgres sh -c "cd /tmp/migrations && for f in *.sql; do psql -U postgres -d provial_db -f \$f; done"
```

### Opción 3: Script PowerShell (Windows)

```powershell
$files = Get-ChildItem -Path ./migrations -Filter "*.sql" | Sort-Object Name
foreach ($file in $files) {
    Write-Host "Ejecutando: $($file.Name)"
    Get-Content $file.FullName | docker exec -i provial_postgres psql -U postgres -d provial_db
}
```

## Acceder a PostgreSQL

### Desde línea de comandos

```bash
# Usando psql instalado en el host
psql postgresql://postgres:postgres@localhost:5432/provial_db

# O usando psql dentro del contenedor
docker exec -it provial_postgres psql -U postgres -d provial_db
```

### Desde pgAdmin

1. Abrir http://localhost:5050
2. Login con admin@provial.local / admin
3. Agregar servidor:
   - Host: provial_postgres
   - Port: 5432
   - Database: provial_db
   - Username: postgres
   - Password: postgres

## Acceder a Redis

### Desde línea de comandos

```bash
# Usando redis-cli instalado en el host
redis-cli -h localhost -p 6379

# O usando redis-cli dentro del contenedor
docker exec -it provial_redis redis-cli
```

### Desde Redis Commander

Abrir http://localhost:8081

## Backups

### Backup de PostgreSQL

```bash
# Crear backup
docker exec provial_postgres pg_dump -U postgres provial_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker exec -i provial_postgres psql -U postgres -d provial_db < backup_20250126_120000.sql
```

### Backup de Redis

```bash
# Redis hace snapshots automáticamente
# Para forzar un save:
docker exec provial_redis redis-cli SAVE

# El archivo dump.rdb está en el volume redis_data
```

## Limpiar y Reiniciar

### Reiniciar base de datos vacía

```bash
# Detener y eliminar contenedores + volúmenes
docker-compose down -v

# Iniciar de nuevo
docker-compose up -d

# Ejecutar migraciones
cd migrations && ./run_migrations.sh
```

## Troubleshooting

### PostgreSQL no inicia

```bash
# Ver logs
docker-compose logs postgres

# Verificar que el puerto 5432 no esté ocupado
netstat -an | grep 5432  # Linux/Mac
netstat -an | findstr 5432  # Windows

# Si está ocupado, cambiar el puerto en docker-compose.yml:
ports:
  - "5433:5432"  # Usar puerto 5433 en el host
```

### Redis no inicia

```bash
# Ver logs
docker-compose logs redis

# Verificar puerto 6379
netstat -an | grep 6379  # Linux/Mac
netstat -an | findstr 6379  # Windows
```

### Permisos en Windows

Si tienes problemas con volúmenes en Windows:

```yaml
# En docker-compose.yml, cambiar:
volumes:
  - postgres_data:/var/lib/postgresql/data

# Por:
volumes:
  - ./docker/postgres-data:/var/lib/postgresql/data
```

### Base de datos corrupta

```bash
# Eliminar volumen de PostgreSQL
docker-compose down
docker volume rm proyectoprovialmovil web_postgres_data

# Recrear
docker-compose up -d
cd migrations && ./run_migrations.sh
```

## Configuración de Producción

Para producción, ver `docker-compose.prod.yml` (pendiente de crear).

Cambios importantes:
- Usar secrets de Docker para contraseñas
- Configurar backups automáticos
- Configurar límites de recursos
- Usar networks externas para Nginx
- Configurar logging a archivos
