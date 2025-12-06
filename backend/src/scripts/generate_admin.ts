
import bcrypt from 'bcryptjs';

const password = 'admin';
const salt = bcrypt.genSaltSync(10);
const hash = bcrypt.hashSync(password, salt);


console.log(`INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('admin', '${hash}', 'Administrador Sistema', 'admin@provial.gob.gt', 1, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;`);
