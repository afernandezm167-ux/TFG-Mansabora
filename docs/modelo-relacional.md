# Modelo relacional

Paso del diagrama entidad-relación a tablas.

**Cómo leerlo:** la clave primaria va en **negrita** (en Word, subrayarla). Las claves foráneas llevan `→ tabla` detrás.

## Reglas aplicadas

| En el E-R | En el modelo relacional | Ejemplo |
|---|---|---|
| Entidad | Una tabla | RECETA → `recetas` |
| Relación 1:N | La tabla del lado N recibe una clave foránea | `actividades` lleva `id_tipo` |
| Relación N:M | Tabla intermedia con las dos claves foráneas y los atributos de la relación | `receta_ingrediente` con `cantidad` y `unidad` |

## Bloque 1 · Recetas

- **recetas** (**id_receta**, nombre, raciones, tipo_plato)
- **ingredientes** (**id_ingrediente**, nombre, apto_vegano, apto_vegetariano, perecedero)
- **alergenos** (**id_alergeno**, nombre)
- **momentos** (**id_momento**, nombre)
- **rellenos** (**id_relleno**, nombre, max_veces)
- **receta_ingrediente** (**id_receta** → recetas, **id_ingrediente** → ingredientes, cantidad, unidad)
- **receta_momento** (**id_receta** → recetas, **id_momento** → momentos)
- **ingrediente_alergeno** (**id_ingrediente** → ingredientes, **id_alergeno** → alergenos)
- **relleno_ingrediente** (**id_relleno** → rellenos, **id_ingrediente** → ingredientes, cantidad, unidad)

## Bloque 2 · Actividades

- **tipos_actividad** (**id_tipo**, nombre)
- **actividades** (**id_actividad**, denominacion, duracion, descripcion, objetivos, metodo_evaluacion, observaciones, id_tipo → tipos_actividad)
- **secciones** (**id_seccion**, nombre)
- **tematicas** (**id_tematica**, nombre)
- **epocas** (**id_epoca**, nombre)
- **materiales** (**id_material**, nombre, hay, siempre_preparar)
- **actividad_seccion** (**id_actividad** → actividades, **id_seccion** → secciones)
- **actividad_tematica** (**id_actividad** → actividades, **id_tematica** → tematicas)
- **actividad_epoca** (**id_actividad** → actividades, **id_epoca** → epocas, obligatoria_diaria, franja)
- **actividad_material** (**id_actividad** → actividades, **id_material** → materiales)

## Bloque 3 · Usuarios

- **usuarios** (**id_usuario**, nombre, email, contrasena, es_admin). El email es único, porque el login busca por él.
- **cargos** (**id_cargo**, nombre)
- **permisos** (**id_permiso**, nombre)
- **usuario_cargo** (**id_usuario** → usuarios, **id_cargo** → cargos)
- **cargo_permiso** (**id_cargo** → cargos, **id_permiso** → permisos)

## Bloque 4 · Uniformidad

- **prendas** (**id_prenda**, nombre, precio)
- **tallas** (**id_talla**, nombre)
- **stock** (**id_prenda** → prendas, **id_talla** → tallas, cantidad)
- **ventas** (**id_venta**, fecha, precio, id_prenda → prendas, id_talla → tallas)

## Bloque 5 · Campamentos

- **campamentos** (**id_campamento**, lugar, num_ninos, num_dias, fecha_inicio, fecha_creacion, id_usuario → usuarios, id_epoca → epocas, id_tematica → tematicas)
- **dietas** (**id_dieta**, nombre)
- **dieta_alergeno** (**id_dieta** → dietas, **id_alergeno** → alergenos)
- **campamento_dieta** (**id_campamento** → campamentos, **id_dieta** → dietas, num_personas)
- **campamento_actividad** (**id_campamento_actividad**, id_campamento → campamentos, id_actividad → actividades, dia, franja)
- **campamento_receta** (**id_campamento_receta**, id_campamento → campamentos, id_receta → recetas, dia, id_momento → momentos, plato, id_dieta → dietas). Si id_dieta está vacío, es el menú normal.
- **campamento_relleno** (**id_campamento** → campamentos, **dia**, id_relleno → rellenos)

## Decisiones de diseño

1. **campamento_actividad y campamento_receta tienen un id propio.** La misma actividad puede salir dos veces en un campamento, en días distintos, y la misma receta puede aparecer como menú normal y como alternativa. Con la clave (id_campamento, id_actividad) no se podría repetir.
2. **El momento y la dieta de campamento_receta son claves foráneas**, no texto libre: así se usan los valores de las tablas momentos y dietas, y "cena" no puede escribirse de dos formas.
3. **campamento_relleno tiene la clave (id_campamento, dia)** porque cada día lleva un solo relleno de bocadillo.
4. **stock** no se llama prenda_talla (como diría la convención) porque el nombre explica mejor lo que guarda.
