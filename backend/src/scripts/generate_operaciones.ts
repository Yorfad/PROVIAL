
import bcrypt from 'bcryptjs';

const password = 'operaciones';
const salt = bcrypt.genSaltSync(10);
const hash = bcrypt.hashSync(password, salt);

console.log(`INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('operaciones', '${hash}', 'Operaciones Central', 'operaciones@provial.gob.gt', 4, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;`);
