# Tipos de datos de la base de datos

Propuesta de tipo y restricciones para cada columna (PostgreSQL). **Pendiente de revisar por Alba.**

- **PK** = clave primaria. Si una tabla tiene varias columnas con PK, la clave es compuesta.
- **FK → tabla** = clave foránea. Su tipo es el mismo que el de la clave primaria a la que apunta, pero sin identity.
- Las columnas que forman la clave primaria no hace falta marcarlas como NOT NULL: PRIMARY KEY ya lo incluye.
- Una columna sin NOT NULL puede quedarse vacía (NULL).

## Tipos ENUM

Se crean antes que las tablas que los usan.

| Nombre del tipo | Valores | Se usa en |
|---|---|---|
| tipo_plato | primero, segundo, unico | recetas.tipo_plato, campamento_receta.plato |
| franja | manana_1, manana_2, taller, tarde, velada | actividad_epoca.franja, campamento_actividad.franja |

## Bloque 1 · Recetas

### recetas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_receta | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |
| raciones |  | INTEGER | NOT NULL, CHECK (raciones > 0) |
| tipo_plato |  | tipo_plato (ENUM) | NOT NULL |

### ingredientes

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_ingrediente | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |
| apto_vegano |  | BOOLEAN | NOT NULL, DEFAULT false |
| apto_vegetariano |  | BOOLEAN | NOT NULL, DEFAULT false |
| perecedero |  | BOOLEAN | NOT NULL, DEFAULT false |

### alergenos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_alergeno | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |

### momentos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_momento | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |

### rellenos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_relleno | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |
| max_veces |  | INTEGER | CHECK (max_veces > 0). Vacío = sin límite |

### receta_ingrediente

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_receta | PK, FK → recetas | INTEGER | NOT NULL |
| id_ingrediente | PK, FK → ingredientes | INTEGER | NOT NULL |
| cantidad |  | NUMERIC(8,3) | NOT NULL, CHECK (cantidad > 0) |
| unidad |  | VARCHAR(20) | NOT NULL. Texto libre: g, kg, ml, l, unidad, cucharada, lata… |

### receta_momento

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_receta | PK, FK → recetas | INTEGER | NOT NULL |
| id_momento | PK, FK → momentos | INTEGER | NOT NULL |

### ingrediente_alergeno

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_ingrediente | PK, FK → ingredientes | INTEGER | NOT NULL |
| id_alergeno | PK, FK → alergenos | INTEGER | NOT NULL |

### relleno_ingrediente

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_relleno | PK, FK → rellenos | INTEGER | NOT NULL |
| id_ingrediente | PK, FK → ingredientes | INTEGER | NOT NULL |
| cantidad |  | NUMERIC(8,3) | NOT NULL, CHECK (cantidad > 0) |
| unidad |  | VARCHAR(20) | NOT NULL. Texto libre: g, kg, ml, l, unidad, cucharada, lata… |

## Bloque 2 · Actividades

### tipos_actividad

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_tipo | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |

### actividades

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_actividad | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| denominacion |  | VARCHAR(150) | NOT NULL |
| duracion |  | INTEGER | NOT NULL, CHECK (duracion > 0). En minutos |
| descripcion |  | TEXT | NOT NULL |
| objetivos |  | TEXT |  |
| metodo_evaluacion |  | TEXT |  |
| observaciones |  | TEXT |  |
| id_tipo | FK → tipos_actividad | INTEGER | NOT NULL |

### secciones

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_seccion | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |

### tematicas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_tematica | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |

### epocas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_epoca | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(20) | NOT NULL, UNIQUE |

### materiales

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_material | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |
| hay |  | BOOLEAN | NOT NULL, DEFAULT true |
| siempre_preparar |  | BOOLEAN | NOT NULL, DEFAULT false |

### actividad_seccion

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_actividad | PK, FK → actividades | INTEGER | NOT NULL |
| id_seccion | PK, FK → secciones | INTEGER | NOT NULL |

### actividad_tematica

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_actividad | PK, FK → actividades | INTEGER | NOT NULL |
| id_tematica | PK, FK → tematicas | INTEGER | NOT NULL |

### actividad_epoca

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_actividad | PK, FK → actividades | INTEGER | NOT NULL |
| id_epoca | PK, FK → epocas | INTEGER | NOT NULL |
| obligatoria_diaria |  | BOOLEAN | NOT NULL, DEFAULT false |
| franja |  | franja (ENUM) | Vacío si no es obligatoria diaria (ver restricciones de tabla) |

### actividad_material

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_actividad | PK, FK → actividades | INTEGER | NOT NULL |
| id_material | PK, FK → materiales | INTEGER | NOT NULL |

## Bloque 3 · Usuarios

### usuarios

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_usuario | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL |
| email |  | VARCHAR(255) | NOT NULL, UNIQUE |
| contrasena |  | CHAR(60) | NOT NULL. El hash de bcrypt siempre mide 60 |
| es_admin |  | BOOLEAN | NOT NULL, DEFAULT false |

### cargos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_cargo | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |

### permisos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_permiso | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(100) | NOT NULL, UNIQUE |

### usuario_cargo

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_usuario | PK, FK → usuarios | INTEGER | NOT NULL |
| id_cargo | PK, FK → cargos | INTEGER | NOT NULL |

### cargo_permiso

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_cargo | PK, FK → cargos | INTEGER | NOT NULL |
| id_permiso | PK, FK → permisos | INTEGER | NOT NULL |

## Bloque 4 · Uniformidad

### prendas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_prenda | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |
| precio |  | NUMERIC(6,2) | NOT NULL, CHECK (precio >= 0) |

### tallas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_talla | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(20) | NOT NULL, UNIQUE |

### stock

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_prenda | PK, FK → prendas | INTEGER | NOT NULL |
| id_talla | PK, FK → tallas | INTEGER | NOT NULL |
| cantidad |  | INTEGER | NOT NULL, DEFAULT 0, CHECK (cantidad >= 0) |

### ventas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_venta | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| fecha |  | DATE | NOT NULL, DEFAULT CURRENT_DATE |
| precio |  | NUMERIC(6,2) | NOT NULL, CHECK (precio >= 0) |
| id_prenda | FK → prendas | INTEGER | NOT NULL |
| id_talla | FK → tallas | INTEGER | NOT NULL |

## Bloque 5 · Campamentos

### campamentos

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_campamento | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| lugar |  | VARCHAR(150) | NOT NULL |
| num_ninos |  | INTEGER | NOT NULL, CHECK (num_ninos > 0) |
| num_dias |  | INTEGER | NOT NULL, CHECK (num_dias > 0) |
| fecha_inicio |  | DATE | NOT NULL |
| fecha_creacion |  | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| id_usuario | FK → usuarios | INTEGER | NOT NULL |
| id_epoca | FK → epocas | INTEGER | NOT NULL |
| id_tematica | FK → tematicas | INTEGER | NOT NULL |

### dietas

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_dieta | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| nombre |  | VARCHAR(50) | NOT NULL, UNIQUE |

### dieta_alergeno

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_dieta | PK, FK → dietas | INTEGER | NOT NULL |
| id_alergeno | PK, FK → alergenos | INTEGER | NOT NULL |

### campamento_dieta

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_campamento | PK, FK → campamentos | INTEGER | NOT NULL |
| id_dieta | PK, FK → dietas | INTEGER | NOT NULL |
| num_personas |  | INTEGER | NOT NULL, CHECK (num_personas > 0) |

### campamento_actividad

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_campamento_actividad | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| id_campamento | FK → campamentos | INTEGER | NOT NULL |
| id_actividad | FK → actividades | INTEGER | NOT NULL |
| dia |  | INTEGER | NOT NULL, CHECK (dia >= 1) |
| franja |  | franja (ENUM) | NOT NULL |

### campamento_receta

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_campamento_receta | PK | INTEGER GENERATED ALWAYS AS IDENTITY | PRIMARY KEY |
| id_campamento | FK → campamentos | INTEGER | NOT NULL |
| id_receta | FK → recetas | INTEGER | NOT NULL |
| dia |  | INTEGER | NOT NULL, CHECK (dia >= 1) |
| id_momento | FK → momentos | INTEGER | NOT NULL |
| plato |  | tipo_plato (ENUM) | NOT NULL |
| id_dieta | FK → dietas | INTEGER | Puede ir vacío: vacío = menú normal |

### campamento_relleno

| Columna | Clave | Tipo | Restricciones |
|---|---|---|---|
| id_campamento | PK, FK → campamentos | INTEGER | NOT NULL |
| dia | PK | INTEGER | NOT NULL, CHECK (dia >= 1) |
| id_relleno | FK → rellenos | INTEGER | NOT NULL |

## Restricciones de tabla

Afectan a varias columnas a la vez, así que se escriben al final de la tabla.

| Tabla | Restricción | Para qué |
|---|---|---|
| actividad_epoca | CHECK (obligatoria_diaria = false OR franja IS NOT NULL) | Si una actividad es obligatoria diaria, tiene que decir en qué franja va |
| todas las intermedias y stock | PRIMARY KEY (columna1, columna2) | Clave primaria compuesta |
| campamento_relleno | PRIMARY KEY (id_campamento, dia) | Un solo relleno por día |
