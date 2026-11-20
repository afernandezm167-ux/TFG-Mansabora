import pool from "../config/db.js";

// Devuelve todas las secciones ordenadas por nombre
export async function obtenerSecciones() {
  const resultado = await pool.query(
    "SELECT id_seccion, nombre FROM secciones ORDER BY nombre",
  );
  return resultado.rows; // las filas vienen dentro de .rows
}

export async function insertarSeccion(nombre) {
  const resultado = await pool.query(
    `INSERT INTO secciones (nombre) VALUES ($1) RETURNING id_seccion, nombre`,
    [nombre],
  );
  return resultado.rows[0];
}