-- Migración 013: Actualizar passwords de usuarios de prueba
-- Fecha: 2025-01-26
-- Todos los usuarios tienen password: password123

-- cop01
UPDATE usuario SET password_hash = '$2a$10$wTrRFdjfkF2u6OtcRqwxvu52qYJBg9H4N1N89dE20KvlaSGUGMBr2' WHERE username = 'cop01';

-- cop02
UPDATE usuario SET password_hash = '$2a$10$gQA0ImjjMfDH0T7qQUgYfex8ei2hOUV2yZ9xR.dG7UtBHLq2YzxEC' WHERE username = 'cop02';

-- brigada01
UPDATE usuario SET password_hash = '$2a$10$/8iDhgKIkCMrthv0SmLgqOwPHigb67yUyuAYXZEBJ2mdBd0/ZgNG2' WHERE username = 'brigada01';

-- brigada02
UPDATE usuario SET password_hash = '$2a$10$77dZVt201SnQA4vJA3AJ0.t96Ip/RbIryH7SMX0lnuCcONaFK0.vu' WHERE username = 'brigada02';

-- operaciones01
UPDATE usuario SET password_hash = '$2a$10$xplx6Gu2zp2HbaXi0mZr4OyM/wzVEOWk7irBQQgKbka.NzioLaFom' WHERE username = 'operaciones01';

-- accidentologia01
UPDATE usuario SET password_hash = '$2a$10$SF5LaiASk1yowkMtUBYK5OM7zPgzSBS/UITLxtt6yKgBR4totBmwG' WHERE username = 'accidentologia01';

-- mando01
UPDATE usuario SET password_hash = '$2a$10$Qk3bsa99SfRnpuqR1aAhm.Mi0yb/KKOXbz7tDt5qLHGQeIzRDulrm' WHERE username = 'mando01';

-- admin
UPDATE usuario SET password_hash = '$2a$10$oCaSkpeiMcetbx0jbsD9mOsNmqfUmnkFqCi5rbKI79wUJtAwLm6xa' WHERE username = 'admin';

-- Verificar actualización
SELECT username, nombre, apellido, rol_nombre
FROM v_usuarios_completos
WHERE username IN ('cop01', 'brigada01', 'admin', 'operaciones01')
ORDER BY id;
