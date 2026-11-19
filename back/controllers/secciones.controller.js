import { obtenerSecciones } from "../models/secciones.model.js";

// GET /api/secciones
export async function listarSecciones(req, res) {
  try {
    const secciones = await obtenerSecciones();
    res.status(200).json(secciones);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener las secciones" });
  }
}
