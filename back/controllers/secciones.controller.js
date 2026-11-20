import { obtenerSecciones } from "../models/secciones.model.js";
import { insertarSeccion } from "../models/secciones.model.js";

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

export async function crearSecciones(req, res) {
  const { nombre } = req.body ?? {};

  if (!nombre || !nombre.trim()) {
    return res.status(400).json({ error:"Falta el nombre de la seccion" });
  }

  try {
    const seccion = await insertarSeccion(nombre.trim());
    res.status(201).json(seccion);
  }catch (error) {
    if (error.code === "23505") { //codigo ue da POSTGRESQL cuando se incumple un UNIQUE 
      return res.status(409).json({ error: "Ya has creado esa seccion"});
    }
    console.error(error);
    res.status(500).json({ error: "Error al crear la seccion"});
  }
}
