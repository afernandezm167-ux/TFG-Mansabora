   -- =============================================
   -- TFG Mansaborá · Estructura de la base de datos
   -- =============================================

   -- 1. Borrar lo que exista
   DROP TABLE IF EXISTS
      campamento_relleno, campamento_receta, campamento_actividad, campamento_dieta,
      dieta_alergeno, campamentos, dietas,
      ventas, stock, tallas, prendas,
      cargo_permiso, usuario_cargo, permisos, cargos, usuarios,
      actividad_material, actividad_epoca, actividad_tematica, actividad_seccion,
      materiales, epocas, tematicas, secciones, actividades, tipos_actividad,
      relleno_ingrediente, ingrediente_alergeno, receta_momento, receta_ingrediente,
      rellenos, ingredientes, recetas, momentos, alergenos
   CASCADE;
   DROP TYPE IF EXISTS tipo_plato, franja;

   -- 2. Tipos ENUM
   CREATE TYPE tipo_plato AS ENUM ('primero', 'segundo', 'unico');
   CREATE TYPE franja AS ENUM ('manana_1', 'manana_2', 'taller', 'tarde', 'velada');

   -- 3. Bloque Recetas
   CREATE TABLE alergenos (
      id_alergeno INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE
   );

   CREATE TABLE momentos (
      id_momento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE
   );

   CREATE TABLE recetas (
      id_receta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE,
      raciones INTEGER NOT NULL CHECK (raciones > 0),
      tipo_plato tipo_plato NOT NULL
   );

   CREATE TABLE ingredientes (
      id_ingrediente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE,
      apto_vegano BOOLEAN NOT NULL DEFAULT false,
      apto_vegetariano BOOLEAN NOT NULL DEFAULT false,
      perecedero BOOLEAN NOT NULL DEFAULT false
   );

   CREATE TABLE rellenos (
      id_relleno INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE,
      max_veces INTEGER CHECK (max_veces > 0)
   );

   CREATE TABLE receta_ingrediente (
      id_receta INTEGER REFERENCES recetas (id_receta) ON DELETE CASCADE,
      id_ingrediente INTEGER REFERENCES ingredientes (id_ingrediente) ON DELETE RESTRICT,
      cantidad NUMERIC(8,3) NOT NULL CHECK (cantidad > 0),
      unidad VARCHAR(20) NOT NULL,
      PRIMARY KEY (id_receta, id_ingrediente)
   );

   CREATE TABLE receta_momento (
      id_receta INTEGER REFERENCES recetas (id_receta) ON DELETE CASCADE,
      id_momento INTEGER REFERENCES momentos (id_momento) ON DELETE RESTRICT,
      PRIMARY KEY (id_receta, id_momento)
   );

   CREATE TABLE ingrediente_alergeno (
      id_ingrediente INTEGER REFERENCES ingredientes (id_ingrediente) ON DELETE CASCADE,
      id_alergeno INTEGER REFERENCES alergenos (id_alergeno) ON DELETE RESTRICT,
      PRIMARY KEY (id_ingrediente, id_alergeno)
   );

   CREATE TABLE relleno_ingrediente (
      id_relleno INTEGER REFERENCES rellenos (id_relleno) ON DELETE CASCADE,
      id_ingrediente INTEGER REFERENCES ingredientes (id_ingrediente) ON DELETE RESTRICT,
      cantidad NUMERIC(8,3) NOT NULL CHECK (cantidad > 0),
      unidad VARCHAR(20) NOT NULL,
      PRIMARY KEY (id_relleno, id_ingrediente)
   );

   -- 4. Bloque Actividades
   CREATE TABLE tipos_actividad (
      id_tipo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE
   );

   CREATE TABLE actividades (
      id_actividad INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      denominacion VARCHAR(150) NOT NULL,
      duracion INTEGER NOT NULL CHECK (duracion > 0),
      descripcion TEXT NOT NULL,
      objetivos TEXT,
      metodo_evaluacion TEXT,
      observaciones TEXT,
      id_tipo INTEGER NOT NULL REFERENCES tipos_actividad (id_tipo) ON DELETE RESTRICT
   );

   CREATE TABLE secciones (
      id_seccion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE
   );

   CREATE TABLE tematicas (
      id_tematica INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE
   );

   CREATE TABLE epocas (
      id_epoca INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(20) NOT NULL UNIQUE
   );

   CREATE TABLE materiales (
      id_material INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE,
      hay BOOLEAN NOT NULL DEFAULT true,
      siempre_preparar BOOLEAN NOT NULL DEFAULT false
   );

   CREATE TABLE actividad_seccion (
      id_actividad INTEGER REFERENCES actividades (id_actividad) ON DELETE CASCADE,
      id_seccion INTEGER REFERENCES secciones (id_seccion) ON DELETE RESTRICT,
      PRIMARY KEY (id_actividad, id_seccion)
   );

   CREATE TABLE actividad_tematica (
      id_actividad INTEGER REFERENCES actividades (id_actividad) ON DELETE CASCADE,
      id_tematica INTEGER REFERENCES tematicas (id_tematica) ON DELETE RESTRICT,
      PRIMARY KEY (id_actividad, id_tematica)
   );

   CREATE TABLE actividad_epoca (
      id_actividad INTEGER REFERENCES actividades (id_actividad) ON DELETE CASCADE,
      id_epoca INTEGER REFERENCES epocas (id_epoca) ON DELETE RESTRICT,
      obligatoria_diaria BOOLEAN NOT NULL DEFAULT false,
      franja franja,
      PRIMARY KEY (id_actividad, id_epoca),
      CHECK (obligatoria_diaria = false OR franja IS NOT NULL)
   );

   CREATE TABLE actividad_material (
      id_actividad INTEGER REFERENCES actividades (id_actividad) ON DELETE CASCADE,
      id_material INTEGER REFERENCES materiales (id_material) ON DELETE RESTRICT,
      PRIMARY KEY (id_actividad, id_material)
   );

   -- 5. Bloque Usuarios
   CREATE TABLE usuarios (
      id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL,
      email VARCHAR(255) NOT NULL UNIQUE,
      contrasena CHAR(60) NOT NULL,
      es_admin BOOLEAN NOT NULL DEFAULT false
   );

   CREATE TABLE cargos (
      id_cargo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE
   );

   CREATE TABLE permisos (
      id_permiso INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL UNIQUE
   );

   CREATE TABLE usuario_cargo (
      id_usuario INTEGER REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
      id_cargo INTEGER REFERENCES cargos (id_cargo) ON DELETE CASCADE,
      PRIMARY KEY (id_usuario, id_cargo)
   );

   CREATE TABLE cargo_permiso (
      id_cargo INTEGER REFERENCES cargos (id_cargo) ON DELETE CASCADE,
      id_permiso INTEGER REFERENCES permisos (id_permiso) ON DELETE RESTRICT,
      PRIMARY KEY (id_cargo, id_permiso)
   );

   -- 6. Bloque Uniformidad
   CREATE TABLE prendas (
      id_prenda INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE,
      precio NUMERIC(6,2) NOT NULL CHECK (precio >= 0)
   );

   CREATE TABLE tallas (
      id_talla INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(20) NOT NULL UNIQUE
   );

   CREATE TABLE stock (
      id_prenda INTEGER REFERENCES prendas (id_prenda) ON DELETE CASCADE,
      id_talla INTEGER REFERENCES tallas (id_talla) ON DELETE RESTRICT,
      cantidad INTEGER NOT NULL DEFAULT 0 CHECK (cantidad >= 0),
      PRIMARY KEY (id_prenda, id_talla)
   );

   CREATE TABLE ventas (
      id_venta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      fecha DATE NOT NULL DEFAULT CURRENT_DATE,
      precio NUMERIC(6,2) NOT NULL CHECK (precio >= 0),
      id_prenda INTEGER NOT NULL REFERENCES prendas (id_prenda) ON DELETE RESTRICT,
      id_talla INTEGER NOT NULL REFERENCES tallas (id_talla) ON DELETE RESTRICT
   );

   -- 7. Bloque Campamentos
   CREATE TABLE dietas (
      id_dieta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      nombre VARCHAR(50) NOT NULL UNIQUE
   );

   CREATE TABLE campamentos (
      id_campamento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      lugar VARCHAR(150) NOT NULL,
      num_ninos INTEGER NOT NULL CHECK (num_ninos > 0),
      num_dias INTEGER NOT NULL CHECK (num_dias > 0),
      fecha_inicio DATE NOT NULL,
      fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      creado_por VARCHAR(100) NOT NULL,
      id_usuario INTEGER REFERENCES usuarios (id_usuario) ON DELETE SET NULL,
      id_epoca INTEGER NOT NULL REFERENCES epocas (id_epoca) ON DELETE RESTRICT,
      id_tematica INTEGER NOT NULL REFERENCES tematicas (id_tematica) ON DELETE RESTRICT
   );

   CREATE TABLE dieta_alergeno (
      id_dieta INTEGER REFERENCES dietas (id_dieta) ON DELETE CASCADE,
      id_alergeno INTEGER REFERENCES alergenos (id_alergeno) ON DELETE RESTRICT,
      PRIMARY KEY (id_dieta, id_alergeno)
   );

   CREATE TABLE campamento_dieta (
      id_campamento INTEGER REFERENCES campamentos (id_campamento) ON DELETE CASCADE,
      id_dieta INTEGER REFERENCES dietas (id_dieta) ON DELETE RESTRICT,
      num_personas INTEGER NOT NULL CHECK (num_personas > 0),
      PRIMARY KEY (id_campamento, id_dieta)
   );

   CREATE TABLE campamento_actividad (
      id_campamento_actividad INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      id_campamento INTEGER NOT NULL REFERENCES campamentos (id_campamento) ON DELETE CASCADE,
      id_actividad INTEGER NOT NULL REFERENCES actividades (id_actividad) ON DELETE RESTRICT,
      dia INTEGER NOT NULL CHECK (dia >= 1),
      franja franja NOT NULL
   );

   CREATE TABLE campamento_receta (
      id_campamento_receta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      id_campamento INTEGER NOT NULL REFERENCES campamentos (id_campamento) ON DELETE CASCADE,
      id_receta INTEGER NOT NULL REFERENCES recetas (id_receta) ON DELETE RESTRICT,
      dia INTEGER NOT NULL CHECK (dia >= 1),
      id_momento INTEGER NOT NULL REFERENCES momentos (id_momento) ON DELETE RESTRICT,
      plato tipo_plato NOT NULL,
      id_dieta INTEGER REFERENCES dietas (id_dieta) ON DELETE RESTRICT
   );

   CREATE TABLE campamento_relleno (
      id_campamento INTEGER REFERENCES campamentos (id_campamento) ON DELETE CASCADE,
      dia INTEGER CHECK (dia >= 1),
      id_relleno INTEGER NOT NULL REFERENCES rellenos (id_relleno) ON DELETE RESTRICT,
      PRIMARY KEY (id_campamento, dia)
   );

   -- 8. Activar RLS
   ALTER TABLE alergenos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE momentos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE recetas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE ingredientes ENABLE ROW LEVEL SECURITY;
   ALTER TABLE rellenos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE receta_ingrediente ENABLE ROW LEVEL SECURITY;
   ALTER TABLE receta_momento ENABLE ROW LEVEL SECURITY;
   ALTER TABLE ingrediente_alergeno ENABLE ROW LEVEL SECURITY;
   ALTER TABLE relleno_ingrediente ENABLE ROW LEVEL SECURITY;

   ALTER TABLE tipos_actividad ENABLE ROW LEVEL SECURITY;
   ALTER TABLE actividades ENABLE ROW LEVEL SECURITY;
   ALTER TABLE secciones ENABLE ROW LEVEL SECURITY;
   ALTER TABLE tematicas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE epocas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE materiales ENABLE ROW LEVEL SECURITY;
   ALTER TABLE actividad_seccion ENABLE ROW LEVEL SECURITY;
   ALTER TABLE actividad_tematica ENABLE ROW LEVEL SECURITY;
   ALTER TABLE actividad_epoca ENABLE ROW LEVEL SECURITY;
   ALTER TABLE actividad_material ENABLE ROW LEVEL SECURITY;

   ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
   ALTER TABLE cargos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE permisos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE usuario_cargo ENABLE ROW LEVEL SECURITY;
   ALTER TABLE cargo_permiso ENABLE ROW LEVEL SECURITY;

   ALTER TABLE prendas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE tallas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE stock ENABLE ROW LEVEL SECURITY;
   ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;

   ALTER TABLE dietas ENABLE ROW LEVEL SECURITY;
   ALTER TABLE campamentos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE dieta_alergeno ENABLE ROW LEVEL SECURITY;
   ALTER TABLE campamento_dieta ENABLE ROW LEVEL SECURITY;
   ALTER TABLE campamento_actividad ENABLE ROW LEVEL SECURITY;
   ALTER TABLE campamento_receta ENABLE ROW LEVEL SECURITY;
   ALTER TABLE campamento_relleno ENABLE ROW LEVEL SECURITY;
