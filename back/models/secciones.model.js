import pool from "../config/db.js";

// Devuelve todas las secciones ordenadas por nombre
export async function obtenerSecciones() {
  const resultado = await pool.query(
    "SELECT id_seccion, nombre FROM secciones ORDER BY nombre",
  );
  return resultado.rows; // las filas vienen dentro de .rows
}
