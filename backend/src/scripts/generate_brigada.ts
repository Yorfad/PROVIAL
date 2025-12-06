
import bcrypt from 'bcryptjs';

const password = 'brigada01';
const salt = bcrypt.genSaltSync(10);
const hash = bcrypt.hashSync(password, salt);

console.log(`INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('brigada01', '${hash}', 'Agente Brigada 01', 'brigada01@provial.gob.gt', 3, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;`);
