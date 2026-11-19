# Guía para comprobar los datos con consultas SQL

## 1. Qué vas a hacer y para qué sirve

En este paso vas a escribir consultas para leer los datos que has introducido y comprobar que sus relaciones funcionan. Las guardarás en `bd/03-consultas.sql`.

No basta con ver cinco filas en cada tabla. También necesitas comprobar que una actividad está vinculada al tipo correcto, que una receta recupera sus ingredientes y que el stock corresponde a la prenda y talla adecuadas.

Estas consultas tienen dos utilidades:

- Ahora te ayudan a comprobar los datos y a entender tu modelo relacional.
- Después te servirán como base para las consultas que utilizará el backend al responder a la interfaz.

Esta guía te explica cómo construirlas, pero no incluye las soluciones SQL del TFG. Los ejemplos de código pertenecen a una biblioteca ficticia.

## 2. Qué necesitas antes de empezar

1. Tener las tablas creadas en la base de datos.
2. Haber ejecutado correctamente `bd/02-datos.sql`.
3. Tener a mano `bd/01-estructura.sql` para consultar nombres de columnas y claves.
4. Abrir `bd/03-consultas.sql` en tu editor.
5. Disponer de un editor SQL conectado a tu base de datos para ejecutar tus consultas.

Los resultados esperados de esta guía corresponden a los datos del archivo `02-datos.sql`, suponiendo que se hayan cargado una sola vez sobre tablas vacías y no se hayan modificado después.

No vuelvas a ejecutar el archivo de estructura para hacer estas comprobaciones: contiene instrucciones de borrado. Tampoco necesitas volver a insertar los datos.

## 3. Dónde escribir y dónde ejecutar

El archivo del proyecto conserva tu trabajo. El editor SQL conectado a la base de datos ejecuta las instrucciones.

Sigue este procedimiento con cada ejercicio:

1. Lee el objetivo y escribe en tus palabras qué información necesitas obtener.
2. Escribe tu consulta en `bd/03-consultas.sql`.
3. Añade encima un comentario que explique qué comprueba.
4. Ejecuta únicamente esa consulta en tu editor SQL conectado.
5. Compara el resultado con el esperado.
6. Si corriges algo al probar, lleva la corrección al archivo del proyecto.
7. Guarda el archivo antes de pasar al siguiente ejercicio.

Guardar un archivo SQL no ejecuta su contenido en la base de datos. Ejecutar una consulta en otro editor tampoco actualiza automáticamente el archivo de tu proyecto.

Para este paso trabajarás con consultas de lectura. No necesitas modificar ni borrar registros.

## 4. Conceptos básicos que vas a usar

### 4.1. SELECT y FROM: qué mostrar y de dónde obtenerlo

`SELECT` indica las columnas que quieres ver. `FROM` indica la tabla de partida.

Ejemplo ajeno al proyecto:

```sql
SELECT titulo, anio_publicacion
FROM libros;
```

La consulta devuelve el título y el año de cada libro. No cambia los datos almacenados.

Aunque `SELECT *` permite pedir todas las columnas, en estos ejercicios conviene escribir las columnas concretas. Así decides qué necesitas y evitas resultados difíciles de leer cuando unas varias tablas.

### 4.2. WHERE: elegir qué filas mostrar

`WHERE` filtra las filas según una condición.

```sql
SELECT titulo, anio_publicacion
FROM libros
WHERE anio_publicacion >= 2020;
```

Primero piensa qué propiedad debe cumplir una fila para aparecer. No confundas filtrar filas con elegir columnas: las columnas se eligen en `SELECT`.

Los textos se escriben entre comillas simples. Los números no las necesitan. Los booleanos se pueden escribir como `true` y `false`.

### 4.3. ORDER BY: ordenar el resultado

```sql
SELECT titulo
FROM libros
ORDER BY titulo ASC;
```

`ASC` indica orden ascendente y `DESC`, descendente. Si no escribes `ORDER BY`, no debes dar por hecho que las filas aparecerán siempre en un mismo orden.

### 4.4. Clave primaria y clave foránea

La clave primaria identifica una fila dentro de una tabla. Una clave foránea guarda una referencia a una fila de otra tabla.

En la biblioteca ficticia:

- Cada autor tiene una clave primaria llamada `id_autor`.
- Cada libro tiene su propia clave primaria, `id_libro`.
- El libro también guarda `id_autor`, que es la clave foránea hacia su autor.

Para unir un libro con su autor compararías la clave foránea del libro con la clave primaria del autor. No compararías los identificadores propios de libro y autor: que ambos tengan el número 3 no significa que estén relacionados.

### 4.5. JOIN y ON: reunir información relacionada

```sql
SELECT l.titulo, a.nombre AS autor
FROM libros AS l
JOIN autores AS a ON l.id_autor = a.id_autor;
```

Lee el ejemplo así:

1. Parte de los libros.
2. Busca el autor cuyo identificador coincide con el que guarda cada libro.
3. Muestra el título y el nombre de ese autor.

`JOIN`, sin otro calificativo, equivale a `INNER JOIN`: devuelve las combinaciones que tienen coincidencia en ambos lados.

`ON` define cómo se conectan las tablas. `WHERE` se utiliza para filtrar el resultado. Aunque algunas condiciones pueden expresarse de distintas maneras, para aprender mantén las relaciones en `ON` y los filtros en `WHERE`.

### 4.6. Alias: abreviar y evitar ambigüedades

En el ejemplo anterior, `l` es un nombre corto para `libros` y `a` para `autores`. Solo existen dentro de esa consulta.

Cuando varias tablas tienen una columna llamada `nombre`, escribir solo `nombre` puede resultar ambiguo. Escribe el alias de la tabla seguido de un punto y la columna para aclarar a cuál te refieres.

También puedes dar un alias a una columna del resultado mediante `AS`. Esto cambia su encabezado en la consulta, no el nombre de la columna almacenada.

### 4.7. Tablas intermedias: recorrer una relación muchos a muchos

Un libro puede tener varias categorías y una categoría puede contener varios libros. Una tabla intermedia guarda cada pareja libro-categoría.

```sql
SELECT l.titulo, c.nombre AS categoria
FROM libros AS l
JOIN libro_categoria AS lc ON lc.id_libro = l.id_libro
JOIN categorias AS c ON c.id_categoria = lc.id_categoria;
```

Necesitas dos uniones: de la tabla principal a la intermedia y de la intermedia a la otra tabla principal.

Una fila del resultado representa una pareja libro-categoría. Si un libro tiene tres categorías, su título aparecerá tres veces. Esa repetición es correcta.

### 4.8. Orden para pensar una consulta

Aunque escribas `SELECT` al principio, suele ser más fácil diseñar la consulta con estas preguntas:

1. ¿Qué representa una fila del resultado?
2. ¿De qué tabla parto?
3. ¿Qué otras tablas necesito?
4. ¿Qué claves conectan cada pareja de tablas?
5. ¿Qué columnas quiero mostrar?
6. ¿Necesito filtrar u ordenar?

Primero consigue que funcione la relación. Después añade filtros y ordenación.

## 5. Ejercicio 1: consultar las secciones

### Objetivo

Mostrar el identificador y el nombre de todas las secciones. Es la comprobación más sencilla: una tabla y ninguna unión.

### Pasos

1. Busca la definición de `secciones` en el archivo de estructura.
2. Identifica el nombre exacto de su clave primaria y de la columna del nombre.
3. Escribe una consulta que muestre esas dos columnas.
4. Ordena por nombre para que el resultado sea fácil de revisar.
5. Ejecútala y comprueba que aparecen las cinco secciones.

### Qué debe aparecer

- Castores.
- Manada.
- Seccion Scout.
- Escultas.
- Clan.

La lista anterior enumera el contenido, no el orden alfabético. Los identificadores pueden variar: no tienen por qué ser del 1 al 5.

Escultas y Clan están incluidos como datos de prueba; su presencia no significa que sean secciones activas del grupo.

### Antes de continuar

Debes poder explicar qué parte de tu consulta elige las columnas, cuál elige la tabla y cuál ordena las filas.

## 6. Ejercicio 2: actividades con su tipo

### Objetivo

Mostrar la denominación de cada actividad y el nombre de su tipo. Una fila debe representar una actividad con su tipo.

### Qué tablas necesitas

| Tabla | Información que aporta |
|---|---|
| `actividades` | Denominación y referencia al tipo |
| `tipos_actividad` | Nombre del tipo |

### Pasos

1. Consulta la estructura de ambas tablas.
2. Localiza la clave foránea del tipo dentro de `actividades`.
3. Localiza la clave primaria de `tipos_actividad`.
4. Parte de las actividades y añade una unión que compare esas dos columnas.
5. Selecciona la denominación de la actividad y el nombre del tipo.
6. Utiliza alias para que se vea de qué tabla sale cada columna.
7. Ordena por denominación y ejecuta.

### Resultado esperado

| Actividad | Tipo |
|---|---|
| Huellas de la selva | Juego |
| Nudos de exploradores | Taller |
| El mapa del tesoro | Tecnicas scout |
| Historias bajo las estrellas | Velada |
| Cuidamos nuestro entorno | Reflexion |

Debes obtener cinco filas. No necesitas una tabla intermedia porque cada actividad guarda directamente la referencia a su tipo.

### Ampliación pequeña

Cuando funcione, filtra para mostrar solo las actividades de tipo Taller. Con los datos actuales debería aparecer Nudos de exploradores.

Filtra por el nombre del tipo, sin dar por hecho qué identificador numérico le ha tocado.

## 7. Ejercicio 3: actividades con sus secciones

### Objetivo

Mostrar qué sección tiene asociada cada actividad. Una fila debe representar una relación actividad-sección.

### Qué tablas necesitas

| Tabla | Información que aporta |
|---|---|
| `actividades` | Denominación de la actividad |
| `actividad_seccion` | Parejas de identificadores que conectan actividad y sección |
| `secciones` | Nombre de la sección |

### Pasos

1. Comprueba que `actividades` no tiene una columna directa con la sección.
2. Revisa las dos claves de `actividad_seccion` y a qué tabla apunta cada una.
3. Parte de las actividades.
4. Une cada actividad con sus filas de la tabla intermedia usando la clave de actividad.
5. Une esas filas con las secciones usando la clave de sección.
6. Muestra la denominación y el nombre de la sección.
7. Ejecuta y comprueba las parejas.

### Resultado esperado

| Actividad | Sección |
|---|---|
| Huellas de la selva | Castores |
| Nudos de exploradores | Manada |
| El mapa del tesoro | Seccion Scout |
| Historias bajo las estrellas | Escultas |
| Cuidamos nuestro entorno | Clan |

Actualmente hay cinco parejas. El modelo permite que una actividad tenga varias secciones, aunque esta muestra solo vincula una sección a cada actividad.

### Qué debes entender

Si una actividad se asociase a dos secciones, aparecería en dos filas. No añadas `DISTINCT` para ocultarlo: primero comprueba qué representa cada fila y si la repetición corresponde a relaciones reales.

## 8. Ejercicio 4: recetas, ingredientes y cantidades

### Objetivo

Mostrar el nombre de cada receta, su ingrediente, la cantidad y la unidad. Una fila debe representar un ingrediente de una receta.

### Qué tablas necesitas

| Tabla | Información que aporta |
|---|---|
| `recetas` | Nombre de la receta y número de raciones |
| `receta_ingrediente` | Relación, cantidad y unidad |
| `ingredientes` | Nombre del ingrediente |

### Pasos

1. Revisa las claves de las tres tablas.
2. Identifica cómo conectar la receta con la tabla intermedia.
3. Identifica cómo conectar la tabla intermedia con el ingrediente.
4. Construye primero las dos uniones.
5. Selecciona los dos nombres, aclarando de qué tabla sale cada uno.
6. Añade cantidad y unidad desde la tabla intermedia.
7. Usa encabezados distintos para receta e ingrediente.
8. Ordena por receta e ingrediente y ejecuta.

### Resultado esperado

| Receta | Ingrediente | Cantidad | Unidad |
|---|---|---|---|
| Arroz blanco | Arroz | 800 | g |
| Tomate en rodajas | Tomate | 1500 | g |
| Huevos cocidos | Huevo | 20 | unidades |
| Queso en dados | Queso | 500 | g |
| Tostadas multisemillas | Pan multisemillas | 20 | rebanadas |

Es normal que una cantidad aparezca con decimales, por ejemplo `800.000`, por el tipo de dato de la columna.

### Cómo interpretar las cantidades

Las cantidades corresponden a las raciones de la receta. Las cinco recetas de prueba están definidas para diez raciones. Por tanto, los 800 g de arroz corresponden a diez raciones, no a una.

Puedes añadir el número de raciones al resultado para comprobarlo. Todavía no necesitas calcular cantidades para campamentos de otros tamaños.

### Por qué la cantidad está en la tabla intermedia

Un mismo ingrediente puede usarse en cantidades diferentes en cada receta. Por eso la cantidad pertenece a la relación entre receta e ingrediente.

Esta muestra tiene un ingrediente por receta para mantener exactamente cinco registros en cada tabla. No representa recetas completas ni comprueba todavía el caso de varios ingredientes por receta.

## 9. Ejercicio 5: prendas, tallas y stock

### Objetivo

Mostrar el nombre de la prenda, su talla y la cantidad disponible. Una fila debe representar una combinación de prenda y talla registrada en el stock.

### Qué tablas necesitas

| Tabla | Información que aporta |
|---|---|
| `prendas` | Nombre de la prenda |
| `stock` | Relación prenda-talla y cantidad |
| `tallas` | Nombre de la talla |

### Pasos

1. Localiza las claves de prenda y talla dentro de `stock`.
2. Elige `stock` como tabla de partida para pensar en las combinaciones existentes.
3. Une cada registro con su prenda.
4. Únelo también con su talla.
5. Selecciona nombre de prenda, nombre de talla y cantidad.
6. Ejecuta y compara los datos.

### Resultado esperado

| Prenda | Talla | Cantidad |
|---|---|---|
| Camiseta infantil | 8 | 15 |
| Camiseta adulta | M | 10 |
| Sudadera infantil | 12 | 0 |
| Sudadera adulta | L | 6 |
| Panoleta | Unica | 30 |

### Ampliación pequeña

Filtra las combinaciones cuya cantidad sea cero. Debe aparecer Sudadera infantil, talla 12.

Una cantidad cero significa que la combinación existe en `stock`, pero está agotada. Que una combinación no tenga registro en `stock` es un caso diferente.

Las ventas de prueba son históricas y el stock ya representa cantidades restantes de muestra. No restes de nuevo esas ventas para comprobar este resultado.

## 10. Dos comprobaciones opcionales

Hazlas cuando entiendas los cinco ejercicios anteriores. No son necesarias para empezar con las relaciones.

### 10.1. Contar registros con COUNT

Ejemplo de biblioteca:

```sql
SELECT COUNT(*) AS total_libros
FROM libros;
```

`COUNT(*)` devuelve el número de filas del resultado. Para comprobar una tabla de tus datos iniciales, cuenta sus filas antes de añadir uniones: deberían ser cinco.

Contar filas después de una unión mide el resultado de esa unión, que puede tener más o menos filas que la tabla de partida.

Cinco filas no demuestran por sí solas que los datos sean correctos. También debes revisar el contenido y las relaciones.

### 10.2. Entender LEFT JOIN

```sql
SELECT l.titulo, a.nombre AS autor
FROM libros AS l
LEFT JOIN autores AS a ON l.id_autor = a.id_autor;
```

Esta consulta conserva todos los libros, incluso si alguno no tiene autor relacionado. En ese caso, las columnas del autor aparecen como `NULL`.

La diferencia principal es:

- `INNER JOIN` conserva las combinaciones con coincidencia.
- `LEFT JOIN` conserva todas las filas de la izquierda, aunque no encuentren coincidencia a la derecha.

En tu proyecto hay un caso útil para practicarlo: mostrar las recetas programadas en campamentos con su dieta opcional. El conjunto de prueba tiene cuatro programaciones sin dieta específica y una con la dieta Sin leche.

Para conservar las cinco programaciones, la unión con las dietas debe permitir que no haya coincidencia. Con una unión interna a dietas solo se conservaría la programación que tiene una dieta vinculada.

Para comprobar valores nulos se utiliza `IS NULL` o `IS NOT NULL`, no una comparación con el signo igual. Además, un filtro posterior sobre una columna de la derecha puede eliminar las filas sin coincidencia de un `LEFT JOIN`.

## 11. Qué hacer si el resultado no coincide

| Problema | Qué revisar primero |
|---|---|
| La tabla no existe | Nombre exacto, base de datos y esquema en el que estás ejecutando |
| Una columna no existe | Nombre de la columna en `01-estructura.sql` y alias utilizado |
| Una columna es ambigua | Si varias tablas tienen el mismo nombre de columna; añade el alias |
| No sale ninguna fila | Que haya datos, que las claves del `ON` sean correctas y que el filtro no excluya todo |
| Aparecen muchas combinaciones inesperadas | Cada condición de unión; puede faltar una condición o comparar claves incorrectas |
| Una actividad aparece varias veces | Si tiene varias relaciones válidas o si la unión está mal construida |
| Faltan filas al unir tablas | Si la unión interna está descartando registros sin relación |
| El orden cambia | Que hayas indicado `ORDER BY` |
| Sale un error de sintaxis | Comas, comillas, palabras clave y punto y coma final |

Cuando algo falle, simplifica:

1. Consulta solo la tabla de partida.
2. Añade la primera unión y comprueba el resultado.
3. Añade la siguiente unión, si la hay.
4. Añade los filtros al final.

No cambies los datos para que encajen con una consulta hasta comprobar que la consulta está bien. Si necesitas ayuda, conserva la consulta que falla y el mensaje de error completo.

## 12. Cómo organizar tu archivo de consultas

Guarda las consultas en este orden:

1. Listado de secciones.
2. Actividades con su tipo.
3. Actividades filtradas por tipo Taller.
4. Actividades con sus secciones.
5. Recetas con ingredientes, cantidades y unidades.
6. Stock por prenda y talla.
7. Combinaciones agotadas.
8. Comprobaciones opcionales, si las haces.

Encima de cada consulta escribe un comentario SQL que indique su objetivo. Puedes usar `--` para un comentario de una línea. Cierra cada consulta con punto y coma y deja una línea en blanco entre ellas.

Mantén la explicación extensa en esta guía y el archivo SQL centrado en consultas con comentarios breves. No incluyas contraseñas ni cadenas de conexión en él.

## 13. Cuándo puedes dar este paso por terminado

- Has escrito y ejecutado los cinco ejercicios principales.
- Las parejas y cantidades coinciden con los datos de prueba.
- Entiendes qué representa una fila en cada resultado.
- Sabes localizar las claves que utiliza cada unión.
- Puedes explicar por qué algunas relaciones necesitan una tabla intermedia.
- Has guardado en `bd/03-consultas.sql` las consultas que realmente has probado.

No necesitas consultar las 35 tablas ni construir todavía un campamento completo. Esta muestra sirve para practicar las relaciones principales. Las comprobaciones de casos más amplios, como actividades con varias secciones o recetas con varios ingredientes, requerirán ampliar los datos de prueba después.

Cuando termines y hayas revisado los cambios, un mensaje de commit adecuado será: `test(bd): añade consultas de comprobación de datos`.

## 14. Por dónde empezar ahora

Haz únicamente el ejercicio 1. Escribe el listado de secciones, ejecútalo y comprueba las cinco filas. Cuando entiendas ese resultado, pasa a la primera unión del ejercicio 2.
