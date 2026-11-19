-- =============================================
-- TFG Mansaborá · Consultas de comprobación de datos
-- Ejecutar después de 01-estructura.sql y 02-datos.sql
-- Guía: docs/guia-comprobacion-datos.md
-- =============================================

-- 1. Listado de secciones (5 filas)
SELECT s.id_seccion, s.nombre
FROM secciones AS s
ORDER BY s.nombre;

-- 2. Actividades con su tipo (5 filas, relación 1:N sin tabla intermedia)
SELECT a.denominacion AS actividad,
       t.nombre AS tipo
FROM actividades AS a
JOIN tipos_actividad AS t ON a.id_tipo = t.id_tipo
ORDER BY a.denominacion;

-- 3. Actividades de tipo Taller (debe salir Nudos de exploradores)
SELECT a.denominacion AS actividad,
       t.nombre AS tipo
FROM actividades AS a
JOIN tipos_actividad AS t ON a.id_tipo = t.id_tipo
WHERE t.nombre = 'Taller'
ORDER BY a.denominacion;

-- 4. Actividades con sus secciones (5 parejas, N:M por actividad_seccion)
SELECT a.denominacion AS actividad,
       s.nombre AS seccion
FROM actividades AS a
JOIN actividad_seccion AS acs ON a.id_actividad = acs.id_actividad
JOIN secciones AS s ON acs.id_seccion = s.id_seccion
ORDER BY a.denominacion, s.nombre;

-- 5. Recetas con ingredientes, cantidades y unidades (para sus raciones base)
SELECT r.nombre AS receta,
       i.nombre AS ingrediente,
       ri.cantidad,
       ri.unidad,
       r.raciones
FROM recetas AS r
JOIN receta_ingrediente AS ri ON r.id_receta = ri.id_receta
JOIN ingredientes AS i ON ri.id_ingrediente = i.id_ingrediente
ORDER BY r.nombre, i.nombre;

-- 6. Stock por prenda y talla (5 filas)
SELECT p.nombre AS prenda,
       t.nombre AS talla,
       st.cantidad
FROM stock AS st
JOIN prendas AS p ON st.id_prenda = p.id_prenda
JOIN tallas AS t ON st.id_talla = t.id_talla
ORDER BY p.nombre, t.nombre;

-- 7. Combinaciones agotadas (debe salir Sudadera infantil, talla 12)
SELECT p.nombre AS prenda,
       t.nombre AS talla,
       st.cantidad
FROM stock AS st
JOIN prendas AS p ON st.id_prenda = p.id_prenda
JOIN tallas AS t ON st.id_talla = t.id_talla
WHERE st.cantidad = 0
ORDER BY p.nombre, t.nombre;

-- 8. Comprobaciones opcionales

-- 8.1. Contar registros de una tabla (deberían ser 5)
SELECT COUNT(*) AS total_actividades
FROM actividades;

-- 8.2. Recetas programadas en campamentos con su dieta opcional
-- LEFT JOIN para conservar las 5 programaciones: 4 sin dieta (NULL) y 1 Sin leche
SELECT c.lugar AS campamento,
       cr.dia,
       m.nombre AS momento,
       r.nombre AS receta,
       d.nombre AS dieta
FROM campamento_receta AS cr
JOIN campamentos AS c ON cr.id_campamento = c.id_campamento
JOIN recetas AS r ON cr.id_receta = r.id_receta
JOIN momentos AS m ON cr.id_momento = m.id_momento
LEFT JOIN dietas AS d ON cr.id_dieta = d.id_dieta
ORDER BY c.lugar, cr.dia;
