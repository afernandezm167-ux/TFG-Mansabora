import { comprobarPermiso } from "../models/usuarios.model.js";

//devuelve un middleware que solo deja pasar si el socio es admin o tiene permiso

export function requierePermiso(permiso) {
    return async (req, res, next) => {
        try {
            const resultado = await comprobarPermiso(req.idUsuario, permiso);

            if (!resultado) {
                return res.status(401).json({ error: "El usuario no existe" });
            }

            if (resultado.es_admin || resultado.tiene_permiso) {
                return next(); //el admin pasa siempre el admin es todopoderoso
            }

            return res.status(403).json({ error: "No tienes los permisos necesarios para realizar esta accion"});
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Error al comprobar los permisos"});
        }
    };
}