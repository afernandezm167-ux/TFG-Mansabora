import jwt from "jsonwebtoken";

//comprueba que el token es valido

export function autenticar(req, res, next) {
    const cabecera = req.headers.authorization;

    if (!cabecera || !cabecera.startsWith("Bearer ")){
        return res.sttus(401).json({ error: "No has iniciado sesion" });
    }

    const token = cabecera.split (" ")[1];

    try{
        const datos = jwt.verify(token, process.env.JWT_SECRET);
        req.idUsuario = datos.id_usuario;
        next(); //todo ok; pasa al siguiente
    }catch{
        return res.status(401).json({ error: "Token no valido o caducado" });
    }
}