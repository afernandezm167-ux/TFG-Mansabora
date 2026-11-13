-- Datos ficticios: cinco registros por tabla, para una base recien creada.
-- Ejecutar DESPUES de 01-estructura.sql, una sola vez.
-- No borra datos existentes. Si hay duplicados, la transaccion se revierte.
-- Los ID se resuelven por nombres; no se presupone que empiecen en 1.
-- Muestra minima: recetas sencillas y campamentos con programacion parcial.
-- Escultas y Clan son secciones de prueba, no altas reales del grupo.
-- Navidad es una categoria de prueba adicional a las cuatro estaciones.

BEGIN;

-- Supabase incluye pgcrypto habitualmente en el esquema extensions.
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;
SET LOCAL search_path TO public, extensions;

-- 1. Listas de cocina
INSERT INTO alergenos (nombre) VALUES
('Gluten'), ('Leche'), ('Huevo'), ('Soja'), ('Sesamo');

INSERT INTO momentos (nombre) VALUES
('Desayuno'), ('Media manana'), ('Comida'), ('Merienda'), ('Cena');

INSERT INTO ingredientes (nombre, apto_vegano, apto_vegetariano, perecedero) VALUES
('Arroz', true, true, false),
('Tomate', true, true, true),
('Huevo', false, true, true),
('Queso', false, true, true),
('Pan multisemillas', true, true, true);

-- Para la prueba se supone que el pan contiene gluten, soja y sesamo,
-- y que el queso es apto para vegetarianos. No son fichas de productos reales.
INSERT INTO ingrediente_alergeno (id_ingrediente, id_alergeno)
SELECT i.id_ingrediente, a.id_alergeno
FROM (VALUES
('Huevo', 'Huevo'),
('Queso', 'Leche'),
('Pan multisemillas', 'Gluten'),
('Pan multisemillas', 'Soja'),
('Pan multisemillas', 'Sesamo')
) AS datos(ingrediente, alergeno)
JOIN ingredientes i ON i.nombre = datos.ingrediente
JOIN alergenos a ON a.nombre = datos.alergeno;

INSERT INTO recetas (nombre, raciones, tipo_plato) VALUES
('Arroz blanco', 10, 'primero'),
('Tomate en rodajas', 10, 'primero'),
('Huevos cocidos', 10, 'segundo'),
('Queso en dados', 10, 'segundo'),
('Tostadas multisemillas', 10, 'unico');

INSERT INTO receta_ingrediente (id_receta, id_ingrediente, cantidad, unidad)
SELECT r.id_receta, i.id_ingrediente, datos.cantidad, datos.unidad
FROM (VALUES
('Arroz blanco', 'Arroz', 800, 'g'),
('Tomate en rodajas', 'Tomate', 1500, 'g'),
('Huevos cocidos', 'Huevo', 20, 'unidades'),
('Queso en dados', 'Queso', 500, 'g'),
('Tostadas multisemillas', 'Pan multisemillas', 20, 'rebanadas')
) AS datos(receta, ingrediente, cantidad, unidad)
JOIN recetas r ON r.nombre = datos.receta
JOIN ingredientes i ON i.nombre = datos.ingrediente;

INSERT INTO receta_momento (id_receta, id_momento)
SELECT r.id_receta, m.id_momento
FROM (VALUES
('Arroz blanco', 'Comida'),
('Tomate en rodajas', 'Cena'),
('Huevos cocidos', 'Cena'),
('Queso en dados', 'Media manana'),
('Tostadas multisemillas', 'Desayuno')
) AS datos(receta, momento)
JOIN recetas r ON r.nombre = datos.receta
JOIN momentos m ON m.nombre = datos.momento;

INSERT INTO rellenos (nombre, max_veces) VALUES
('Tomate triturado', 3),
('Queso en lonchas', 2),
('Tortilla francesa', 2),
('Huevo cocido picado', 2),
('Queso fundido', 1);

-- Cantidades para un bocadillo; el pan se contempla aparte del relleno.
INSERT INTO relleno_ingrediente (id_relleno, id_ingrediente, cantidad, unidad)
SELECT r.id_relleno, i.id_ingrediente, datos.cantidad, datos.unidad
FROM (VALUES
('Tomate triturado', 'Tomate', 80, 'g'),
('Queso en lonchas', 'Queso', 50, 'g'),
('Tortilla francesa', 'Huevo', 1, 'unidades'),
('Huevo cocido picado', 'Huevo', 1, 'unidades'),
('Queso fundido', 'Queso', 60, 'g')
) AS datos(relleno, ingrediente, cantidad, unidad)
JOIN rellenos r ON r.nombre = datos.relleno
JOIN ingredientes i ON i.nombre = datos.ingrediente;

-- 2. Actividades y materiales
INSERT INTO tipos_actividad (nombre) VALUES
('Juego'), ('Taller'), ('Velada'), ('Reflexion'), ('Tecnicas scout');

INSERT INTO secciones (nombre) VALUES
('Castores'), ('Manada'), ('Seccion Scout'), ('Escultas'), ('Clan');

INSERT INTO tematicas (nombre) VALUES
('La selva'), ('Exploradores'), ('Piratas'), ('Estrellas'), ('Servicio');

INSERT INTO epocas (nombre) VALUES
('Primavera'), ('Verano'), ('Otono'), ('Invierno'), ('Navidad');

INSERT INTO materiales (nombre, hay, siempre_preparar) VALUES
('Tarjetas de animales', true, false),
('Cuerdas', true, false),
('Mapas impresos', false, true),
('Linternas', true, false),
('Bolsas de recogida', false, false);

INSERT INTO actividades
(denominacion, duracion, descripcion, objetivos, metodo_evaluacion, observaciones, id_tipo)
SELECT datos.nombre, datos.duracion, datos.descripcion, datos.objetivos,
       datos.evaluacion, datos.observaciones, t.id_tipo
FROM (VALUES
('Huellas de la selva', 45, 'Relacionar tarjetas de animales con sus huellas por equipos.',
 'Cooperar y reconocer animales.', 'Ronda final de preguntas.', 'Preparar las tarjetas antes de empezar.', 'Juego'),
('Nudos de exploradores', 60, 'Practicar nudo llano y as de guia con cuerdas.',
 'Aprender nudos basicos.', 'Demostracion individual de los nudos.', 'Actividad de aprendizaje, sin cargas ni escalada.', 'Taller'),
('El mapa del tesoro', 90, 'Seguir un mapa con pistas hasta encontrar un tesoro simbolico.',
 'Practicar orientacion y trabajo en equipo.', 'Revisar el recorrido con cada equipo.', 'Imprimir un mapa por equipo.', 'Tecnicas scout'),
('Historias bajo las estrellas', 60, 'Compartir historias en una velada con linternas.',
 'Desarrollar expresion oral y escucha.', 'Cada participante comenta su momento favorito.', 'Sin fuego; delimitar la zona.', 'Velada'),
('Cuidamos nuestro entorno', 45, 'Reflexionar sobre los residuos y recoger una zona delimitada.',
 'Valorar el cuidado del entorno.', 'Puesta en comun de propuestas.', 'Recoger solo residuos ordinarios bajo supervision.', 'Reflexion')
) AS datos(nombre, duracion, descripcion, objetivos, evaluacion, observaciones, tipo)
JOIN tipos_actividad t ON t.nombre = datos.tipo;

INSERT INTO actividad_seccion (id_actividad, id_seccion)
SELECT a.id_actividad, s.id_seccion
FROM (VALUES
('Huellas de la selva', 'Castores'),
('Nudos de exploradores', 'Manada'),
('El mapa del tesoro', 'Seccion Scout'),
('Historias bajo las estrellas', 'Escultas'),
('Cuidamos nuestro entorno', 'Clan')
) AS datos(actividad, seccion)
JOIN actividades a ON a.denominacion = datos.actividad
JOIN secciones s ON s.nombre = datos.seccion;

INSERT INTO actividad_tematica (id_actividad, id_tematica)
SELECT a.id_actividad, t.id_tematica
FROM (VALUES
('Huellas de la selva', 'La selva'),
('Nudos de exploradores', 'Exploradores'),
('El mapa del tesoro', 'Piratas'),
('Historias bajo las estrellas', 'Estrellas'),
('Cuidamos nuestro entorno', 'Servicio')
) AS datos(actividad, tematica)
JOIN actividades a ON a.denominacion = datos.actividad
JOIN tematicas t ON t.nombre = datos.tematica;

INSERT INTO actividad_epoca (id_actividad, id_epoca, obligatoria_diaria, franja)
SELECT a.id_actividad, e.id_epoca, datos.obligatoria, datos.franja::franja
FROM (VALUES
('Huellas de la selva', 'Primavera', false, 'manana_1'),
('Nudos de exploradores', 'Invierno', false, 'taller'),
('El mapa del tesoro', 'Otono', false, 'tarde'),
('Historias bajo las estrellas', 'Verano', false, 'velada'),
('Cuidamos nuestro entorno', 'Navidad', true, 'manana_2')
) AS datos(actividad, epoca, obligatoria, franja)
JOIN actividades a ON a.denominacion = datos.actividad
JOIN epocas e ON e.nombre = datos.epoca;

INSERT INTO actividad_material (id_actividad, id_material)
SELECT a.id_actividad, m.id_material
FROM (VALUES
('Huellas de la selva', 'Tarjetas de animales'),
('Nudos de exploradores', 'Cuerdas'),
('El mapa del tesoro', 'Mapas impresos'),
('Historias bajo las estrellas', 'Linternas'),
('Cuidamos nuestro entorno', 'Bolsas de recogida')
) AS datos(actividad, material)
JOIN actividades a ON a.denominacion = datos.actividad
JOIN materiales m ON m.nombre = datos.material;

-- 3. Usuarios ficticios y permisos
-- Clave compartida SOLO para estas cuentas de prueba: PruebaScout2026!
-- Cada llamada genera un hash bcrypt con una sal distinta.
INSERT INTO usuarios (nombre, email, contrasena, es_admin) VALUES
('Ana Prueba', 'ana@example.test', crypt('PruebaScout2026!', gen_salt('bf', 10)), true),
('Bruno Prueba', 'bruno@example.test', crypt('PruebaScout2026!', gen_salt('bf', 10)), false),
('Carla Prueba', 'carla@example.test', crypt('PruebaScout2026!', gen_salt('bf', 10)), false),
('Diego Prueba', 'diego@example.test', crypt('PruebaScout2026!', gen_salt('bf', 10)), false),
('Elena Prueba', 'elena@example.test', crypt('PruebaScout2026!', gen_salt('bf', 10)), false);

INSERT INTO cargos (nombre) VALUES
('Coordinacion general'), ('Coordinacion de campamento'),
('Material'), ('Uniformidad'), ('Scouter');

INSERT INTO permisos (nombre) VALUES
('gestionar_usuarios'), ('gestionar_campamentos'), ('gestionar_materiales'),
('gestionar_uniformidad'), ('gestionar_actividades');

INSERT INTO usuario_cargo (id_usuario, id_cargo)
SELECT u.id_usuario, c.id_cargo
FROM (VALUES
('ana@example.test', 'Coordinacion general'),
('bruno@example.test', 'Coordinacion de campamento'),
('carla@example.test', 'Material'),
('diego@example.test', 'Uniformidad'),
('elena@example.test', 'Scouter')
) AS datos(email, cargo)
JOIN usuarios u ON u.email = datos.email
JOIN cargos c ON c.nombre = datos.cargo;

INSERT INTO cargo_permiso (id_cargo, id_permiso)
SELECT c.id_cargo, p.id_permiso
FROM (VALUES
('Coordinacion general', 'gestionar_usuarios'),
('Coordinacion de campamento', 'gestionar_campamentos'),
('Material', 'gestionar_materiales'),
('Uniformidad', 'gestionar_uniformidad'),
('Scouter', 'gestionar_actividades')
) AS datos(cargo, permiso)
JOIN cargos c ON c.nombre = datos.cargo
JOIN permisos p ON p.nombre = datos.permiso;

-- 4. Uniformidad: variantes ficticias para disponer de cinco prendas.
INSERT INTO prendas (nombre, precio) VALUES
('Camiseta infantil', 10.00), ('Camiseta adulta', 12.00),
('Sudadera infantil', 20.00), ('Sudadera adulta', 25.00), ('Panoleta', 8.00);

INSERT INTO tallas (nombre) VALUES
('8'), ('12'), ('M'), ('L'), ('Unica');

-- Stock restante de prueba; las ventas de abajo son historicas.
INSERT INTO stock (id_prenda, id_talla, cantidad)
SELECT p.id_prenda, t.id_talla, datos.cantidad
FROM (VALUES
('Camiseta infantil', '8', 15),
('Camiseta adulta', 'M', 10),
('Sudadera infantil', '12', 0),
('Sudadera adulta', 'L', 6),
('Panoleta', 'Unica', 30)
) AS datos(prenda, talla, cantidad)
JOIN prendas p ON p.nombre = datos.prenda
JOIN tallas t ON t.nombre = datos.talla;

INSERT INTO ventas (fecha, precio, id_prenda, id_talla)
SELECT datos.fecha::date, datos.precio, p.id_prenda, t.id_talla
FROM (VALUES
('2026-11-01', 10.00, 'Camiseta infantil', '8'),
('2026-11-02', 12.00, 'Camiseta adulta', 'M'),
('2026-11-03', 20.00, 'Sudadera infantil', '12'),
('2026-11-04', 25.00, 'Sudadera adulta', 'L'),
('2026-11-05', 8.00, 'Panoleta', 'Unica')
) AS datos(fecha, precio, prenda, talla)
JOIN prendas p ON p.nombre = datos.prenda
JOIN tallas t ON t.nombre = datos.talla;

-- 5. Campamentos y dietas
INSERT INTO dietas (nombre) VALUES
('Sin gluten'), ('Sin leche'), ('Sin huevo'), ('Sin soja'), ('Sin sesamo');

-- Esta relacion representa el alergeno que debe excluir cada dieta.
INSERT INTO dieta_alergeno (id_dieta, id_alergeno)
SELECT d.id_dieta, a.id_alergeno
FROM (VALUES
('Sin gluten', 'Gluten'), ('Sin leche', 'Leche'), ('Sin huevo', 'Huevo'),
('Sin soja', 'Soja'), ('Sin sesamo', 'Sesamo')
) AS datos(dieta, alergeno)
JOIN dietas d ON d.nombre = datos.dieta
JOIN alergenos a ON a.nombre = datos.alergeno;

-- Lugares ficticios y nombres de usuario conservados como copia historica.
-- fecha_creacion usa el valor por defecto de la base de datos.
INSERT INTO campamentos
(lugar, num_ninos, num_dias, fecha_inicio, creado_por, id_usuario, id_epoca, id_tematica)
SELECT datos.lugar, datos.ninos, datos.dias, datos.inicio::date,
       u.nombre, u.id_usuario, e.id_epoca, t.id_tematica
FROM (VALUES
('Pradera de la Selva', 20, 2, '2027-04-10', 'ana@example.test', 'Primavera', 'La selva'),
('Refugio del Explorador', 25, 3, '2027-02-12', 'bruno@example.test', 'Invierno', 'Exploradores'),
('Dehesa del Tesoro', 30, 2, '2027-10-16', 'carla@example.test', 'Otono', 'Piratas'),
('Pinar de las Estrellas', 35, 5, '2027-07-12', 'diego@example.test', 'Verano', 'Estrellas'),
('Albergue del Servicio', 15, 1, '2026-12-28', 'elena@example.test', 'Navidad', 'Servicio')
) AS datos(lugar, ninos, dias, inicio, email, epoca, tematica)
JOIN usuarios u ON u.email = datos.email
JOIN epocas e ON e.nombre = datos.epoca
JOIN tematicas t ON t.nombre = datos.tematica;

INSERT INTO campamento_dieta (id_campamento, id_dieta, num_personas)
SELECT c.id_campamento, d.id_dieta, datos.personas
FROM (VALUES
('Pradera de la Selva', 'Sin gluten', 2),
('Refugio del Explorador', 'Sin leche', 3),
('Dehesa del Tesoro', 'Sin huevo', 1),
('Pinar de las Estrellas', 'Sin soja', 2),
('Albergue del Servicio', 'Sin sesamo', 1)
) AS datos(lugar, dieta, personas)
JOIN campamentos c ON c.lugar = datos.lugar
JOIN dietas d ON d.nombre = datos.dieta;

INSERT INTO campamento_actividad (id_campamento, id_actividad, dia, franja)
SELECT c.id_campamento, a.id_actividad, datos.dia, datos.franja::franja
FROM (VALUES
('Pradera de la Selva', 'Huellas de la selva', 1, 'manana_1'),
('Refugio del Explorador', 'Nudos de exploradores', 2, 'taller'),
('Dehesa del Tesoro', 'El mapa del tesoro', 1, 'tarde'),
('Pinar de las Estrellas', 'Historias bajo las estrellas', 3, 'velada'),
('Albergue del Servicio', 'Cuidamos nuestro entorno', 1, 'manana_2')
) AS datos(lugar, actividad, dia, franja)
JOIN campamentos c ON c.lugar = datos.lugar
JOIN actividades a ON a.denominacion = datos.actividad;

-- Cuatro platos para menu general y una alternativa sin leche.
-- No son menus completos. El pan del ultimo campamento va en el menu
-- general; su alternativa sin sesamo no esta programada en esta muestra.
INSERT INTO campamento_receta
(id_campamento, id_receta, dia, id_momento, plato, id_dieta)
SELECT c.id_campamento, r.id_receta, datos.dia, m.id_momento,
       datos.plato::tipo_plato, d.id_dieta
FROM (VALUES
('Pradera de la Selva', 'Arroz blanco', 1, 'Comida', 'primero', NULL),
('Refugio del Explorador', 'Tomate en rodajas', 2, 'Cena', 'primero', 'Sin leche'),
('Dehesa del Tesoro', 'Huevos cocidos', 1, 'Cena', 'segundo', NULL),
('Pinar de las Estrellas', 'Queso en dados', 3, 'Media manana', 'segundo', NULL),
('Albergue del Servicio', 'Tostadas multisemillas', 1, 'Desayuno', 'unico', NULL)
) AS datos(lugar, receta, dia, momento, plato, dieta)
JOIN campamentos c ON c.lugar = datos.lugar
JOIN recetas r ON r.nombre = datos.receta
JOIN momentos m ON m.nombre = datos.momento
LEFT JOIN dietas d ON d.nombre = datos.dieta;

INSERT INTO campamento_relleno (id_campamento, dia, id_relleno)
SELECT c.id_campamento, datos.dia, r.id_relleno
FROM (VALUES
('Pradera de la Selva', 1, 'Tomate triturado'),
('Refugio del Explorador', 2, 'Tortilla francesa'),
('Dehesa del Tesoro', 1, 'Queso en lonchas'),
('Pinar de las Estrellas', 3, 'Huevo cocido picado'),
('Albergue del Servicio', 1, 'Queso fundido')
) AS datos(lugar, dia, relleno)
JOIN campamentos c ON c.lugar = datos.lugar
JOIN rellenos r ON r.nombre = datos.relleno;

COMMIT;
