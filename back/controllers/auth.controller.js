import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { buscarUsuarioPorEmail } from "../models/usuarios.model.js";

//POST /api/auth/login
export async function login (req, res) {
    //recibir email y contraseña
    const { email, contrasena } = req.body ?? {};

    if (!email || !contrasena) {
        return res.status(400).json( {error: 'Faltan el email o la contraseña'})
    }

    try {
        //buscar por email
        const usuario = await buscarUsuarioPorEmail(email);

        if (!usuario) {
            return res.status(401).json({ error: "Correo electronico incorrectas" });
        }

        //comprobar contrasela con el hash

        const coincide = await bcrypt.compare(contrasena, usuario.contrasena);

        if (!coincide) {
            return res.status(401).json({ error: "Contraseña incorrecta" })
        }

        //crear el token
        const token = jwt.sign(
            { id_usuario: usuario.id_usuario},
            process.env.JWT_SECRET,
            { expiresIn: "24h"}
        );

        res.status(200).json({
            token,
            usuario: {id_usuario: usuario.id_usuario, nombre: usuario.nombre, es_admin: usuario.es_admin}
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al iniciar sesion"});
    }
}