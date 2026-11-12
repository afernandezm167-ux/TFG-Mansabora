   -- =============================================
   -- TFG Mansaborá · Estructura de la base de datos
   -- =============================================

   -- 1. Borrar lo que exista
   DROP TABLE IF EXISTS alergenos, momentos, recetas, ingredientes, rellenos CASCADE;
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
      id_receta INTEGER REFERENCES recetas (id_receta) ON DELETE ON CASCADE,
      id_ingrediente INTEGER REFERENCES ingredientes (id_ingrediente) ON DELETE ON CASCADE
   );
   -- 4. Bloque Actividades
   -- 5. Bloque Usuarios
   -- 6. Bloque Uniformidad
   -- 7. Bloque Campamentos
   -- 8. Activar RLS