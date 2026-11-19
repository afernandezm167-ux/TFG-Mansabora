import pool from "../config/db.js"

//Busca un usuario por email. Devuelve el usuario o undefined si no existe
export async function buscarUsuarioPorEmail(email) {
    const resultado = await pool.query (
        "SELECT id_usuario, nombre, email, contrasena, es_admin FROM usuarios WHERE email = $1",
        [email],
    );
    return resultado.rows[0];
}

//Dice si el usuario es admin y si tiene el permiso indicado
export async function comprobarPermiso(idUsuario, permiso) {
    const resultado = await pool.query(
    `SELECT u.es_admin,
            EXISTS (
              SELECT 1
              FROM usuario_cargo uc
              JOIN cargo_permiso cp ON cp.id_cargo = uc.id_cargo
              JOIN permisos p ON p.id_permiso = cp.id_permiso
              WHERE uc.id_usuario = u.id_usuario
                AND p.nombre = $2
            ) AS tiene_permiso
     FROM usuarios u
     WHERE u.id_usuario = $1`,
     [idUsuario, permiso],
    );
    return resultado.rows[0];
}

export async function crearUsuario (nombre, email, hash, esAdmin) {
    const resultado = await pool.query(
        `INSERT INTO usuarios (nombre, email, contrasena, es_admin)
        VALUES ($1, $2, $3, $4)
        RETURNING id_usuario, nombre, email, es_Admin`,
        [nombre, email, hash, esAdmin],
    );
    return resultado.rows[0];
}
