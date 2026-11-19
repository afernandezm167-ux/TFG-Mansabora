import { Router } from "express";
import { listarSecciones } from "../controllers/secciones.controller.js";

const router = Router();

router.get("/", listarSecciones); // GET /api/secciones

export default router;
