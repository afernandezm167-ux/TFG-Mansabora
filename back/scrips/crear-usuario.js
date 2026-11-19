import "dotenv/config";
import bcrypt from "bcrypt";
import pool from "../config/db.js";
import { crearUsuario } from "../models/usuarios.model.js";

const [nombre, email, contrasena, admin] = process.argv.slice(2);

if (!nombre || !email || !contrasena){
    console.log('Uso: node scrips/crear-usuario.js "Nombre" email, contraseña [admin]');
    process.getMaxListeners(1);
}

try{
    const hash = await bcrypt.hash(contrasena, 10); //cifrado de contraseña
    const usuario = await crearUsuario(nombre, email, hash, admin === 'admin');
    console.log ('Usuario creado: ', usuario);
} catch (error) {
    console.error ('No se pudo crear el usuario:', error.message);
}finally {
    await pool.end();
}