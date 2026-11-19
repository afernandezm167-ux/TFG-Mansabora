import "dotenv/config"; //lee el env
import express from "express";
import cors from "cors";
import pool from "./config/db.js";
import seccionesRoutes from "./routes/secciones.routes.js";
import authRoutes from "./routes/auth.routes.js"

const app = express(); // crea la aplicacion

app.use(cors()); //permite al front llamar a la api
app.use(express.json()); //permite leer el json
app.use("/api/auth", authRoutes);

app.get("/", (req, res) => {
  res.json({ mensaje: "API del TFG Mansaborá funcionando" }); //cuando alguien hace get es lo que se ejecuta
});

app.use("/api/secciones", seccionesRoutes);

const PORT = process.env.PORT || 3000; // la variable port del env

app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`); //el servidor queda esperando peticiones
});

try {
  const resultado = await pool.query("SELECT NOW()");
  console.log("Conectado a la base de datos:", resultado.rows[0].now);
} catch (error) {
  console.error("No se pudo conectar a la base de datos:", error.message);
}
