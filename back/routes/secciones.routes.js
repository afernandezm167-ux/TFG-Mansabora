import { Router } from "express";
import { listarSecciones, crearSecciones } from "../controllers/secciones.controller.js";
import { autenticar } from "../middlewares/autenticar.js";
import { requierePermiso } from "../middlewares/requierePermiso.js";

const router = Router();

router.get("/", listarSecciones); // pública

router.post(
  "/",
  autenticar,                            // 1. ¿ha iniciado sesión?
  requierePermiso("gestionar_actividades"), // 2. ¿tiene el permiso?
  crearSecciones,                           // 3. crea el género
);

export default router;