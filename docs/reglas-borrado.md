# Qué pasa al borrar (reglas ON DELETE)

- **CASCADE** → si se borra la fila padre, se borran también sus filas hijas.
- **RESTRICT** → si la fila padre tiene filas hijas, no deja borrarla (da error).
- **SET NULL** → si se borra la fila padre, la clave foránea de las hijas se queda vacía y las filas hijas se conservan.

## Bloque 1 · Recetas

| Tabla | Clave foránea | Apunta a | Al borrar | Por qué |
|---|---|---|---|---|
| receta_ingrediente | id_receta | recetas | CASCADE | Sin la receta, sus ingredientes no sirven |
| receta_ingrediente | id_ingrediente | ingredientes | RESTRICT | No se puede borrar un ingrediente que usan recetas |
| receta_momento | id_receta | recetas | CASCADE | Sin la receta, sus momentos no sirven |
| receta_momento | id_momento | momentos | RESTRICT | Hay recetas asignadas a ese momento |
| ingrediente_alergeno | id_ingrediente | ingredientes | CASCADE | Si el ingrediente se borra, sus alérgenos asociados también |
| ingrediente_alergeno | id_alergeno | alergenos | RESTRICT | Borrar un alérgeno haría que ingredientes con gluten parezcan aptos para celíacos |
| relleno_ingrediente | id_relleno | rellenos | CASCADE | Sin el relleno, sus ingredientes no sirven |
| relleno_ingrediente | id_ingrediente | ingredientes | RESTRICT | No se puede borrar un ingrediente que usan rellenos |

## Bloque 2 · Actividades

| Tabla | Clave foránea | Apunta a | Al borrar | Por qué |
|---|---|---|---|---|
| actividades | id_tipo | tipos_actividad | RESTRICT | Hay actividades de ese tipo |
| actividad_seccion | id_actividad | actividades | CASCADE | Sin la actividad, sus secciones no sirven |
| actividad_seccion | id_seccion | secciones | RESTRICT | Hay actividades para esa sección |
| actividad_tematica | id_actividad | actividades | CASCADE | Sin la actividad, sus temáticas no sirven |
| actividad_tematica | id_tematica | tematicas | RESTRICT | Hay actividades de esa temática |
| actividad_epoca | id_actividad | actividades | CASCADE | Sin la actividad, sus épocas no sirven |
| actividad_epoca | id_epoca | epocas | RESTRICT | Hay actividades de esa época |
| actividad_material | id_actividad | actividades | CASCADE | Sin la actividad, su lista de materiales no sirve |
| actividad_material | id_material | materiales | RESTRICT | Hay actividades que necesitan ese material |

## Bloque 3 · Usuarios

| Tabla | Clave foránea | Apunta a | Al borrar | Por qué |
|---|---|---|---|---|
| usuario_cargo | id_usuario | usuarios | CASCADE | Si se borra el usuario, sus cargos asignados también |
| usuario_cargo | id_cargo | cargos | CASCADE | Si el admin borra un cargo, las personas simplemente dejan de tenerlo |
| cargo_permiso | id_cargo | cargos | CASCADE | Sin el cargo, sus permisos asignados no sirven |
| cargo_permiso | id_permiso | permisos | RESTRICT | Los permisos los comprueba el código: borrar uno rompería el middleware |

## Bloque 4 · Uniformidad

| Tabla | Clave foránea | Apunta a | Al borrar | Por qué |
|---|---|---|---|---|
| stock | id_prenda | prendas | CASCADE | Si se borra la prenda, su stock también |
| stock | id_talla | tallas | RESTRICT | Hay stock de esa talla |
| ventas | id_prenda | prendas | RESTRICT | No se pierde el historial de ventas |
| ventas | id_talla | tallas | RESTRICT | No se pierde el historial de ventas |

## Bloque 5 · Campamentos

| Tabla | Clave foránea | Apunta a | Al borrar | Por qué |
|---|---|---|---|---|
| campamentos | id_usuario | usuarios | SET NULL | Un usuario se puede borrar siempre. El campamento se conserva y el nombre de quien lo creó queda en creado_por |
| campamentos | id_epoca | epocas | RESTRICT | Hay campamentos guardados de esa época |
| campamentos | id_tematica | tematicas | RESTRICT | Hay campamentos guardados con esa temática |
| dieta_alergeno | id_dieta | dietas | CASCADE | Sin la dieta, sus alérgenos asociados no sirven |
| dieta_alergeno | id_alergeno | alergenos | RESTRICT | Una dieta dejaría de excluir ese alérgeno sin avisar |
| campamento_dieta | id_campamento | campamentos | CASCADE | Sin el campamento, sus dietas no sirven |
| campamento_dieta | id_dieta | dietas | RESTRICT | Hay campamentos con personas de esa dieta |
| campamento_actividad | id_campamento | campamentos | CASCADE | Sin el campamento, su horario no sirve |
| campamento_actividad | id_actividad | actividades | RESTRICT | El horario de un campamento guardado quedaría con huecos |
| campamento_receta | id_campamento | campamentos | CASCADE | Sin el campamento, su menú no sirve |
| campamento_receta | id_receta | recetas | RESTRICT | El menú de un campamento guardado quedaría con huecos |
| campamento_receta | id_momento | momentos | RESTRICT | Hay platos de campamentos en ese momento |
| campamento_receta | id_dieta | dietas | RESTRICT | Hay menús alternativos para esa dieta |
| campamento_relleno | id_campamento | campamentos | CASCADE | Sin el campamento, sus rellenos no sirven |
| campamento_relleno | id_relleno | rellenos | RESTRICT | Hay campamentos guardados que usan ese relleno |
