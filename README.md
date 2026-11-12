# TFG Mansaborá · Gestión de grupo scout

Aplicación web para gestionar el día a día del **Grupo Scout Mansaborá 738 (Cáceres)**: actividades, materiales, recetas, uniformidad, usuarios y un **generador automático de campamentos**.

> Trabajo Fin de Grado · CFGS Desarrollo de Aplicaciones Web (DAW) · Curso 2026/2027
> Autora: Alba Matilla

**Estado:** en desarrollo

---

## Índice

- [Qué problema resuelve](#qué-problema-resuelve)
- [Módulos](#módulos)
- [Generador de campamentos](#generador-de-campamentos)
- [Usuarios y permisos](#usuarios-y-permisos)
- [Tecnologías](#tecnologías)
- [Arquitectura](#arquitectura)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [Convenciones](#convenciones)
- [Planificación](#planificación)
- [Instalación y puesta en marcha](#instalación-y-puesta-en-marcha)

---

## Qué problema resuelve

Organizar un campamento scout implica preparar horarios, actividades, menús adaptados a alergias y dietas, listas de la compra y material. Hoy se hace a mano y lleva muchas horas.

La aplicación centraliza toda la información del grupo y, a partir de unos pocos datos, **genera un campamento completo** (horario, dossier de actividades, menú con cantidades y listas de la compra) que el coordinador puede revisar, modificar y descargar en PDF.

---

## Módulos

### Actividades

Fichas de actividad basadas en la hoja que ya usa el grupo:
denominación, secciones, duración, tipo, descripción, objetivos, recursos necesarios, método de evaluación, observaciones, época, temática y si es obligatoria diaria (por ejemplo, la piscina en verano).

- **Secciones** (selección múltiple): Castores, Manada, Sección Scout (Escultas a partir del próximo curso).
- **Tipos:** Taller, Juego, Velada, Dinámica, Reflexión, Técnicas scout, Otros.

### Materiales

Inventario del material del grupo con estado **hay / no hay**. Incluye elementos que siempre hay que preparar (como las impresiones). Las actividades enlazan con sus materiales.

### Recetas e ingredientes

- Cada receta indica para cuántas personas es y la cantidad de cada ingrediente; la app **escala** las cantidades al número de niños.
- Momento del día (desayuno, media mañana, comida, merienda, cena) y tipo de plato (primero, segundo o plato único).
- Los ingredientes llevan **alérgenos**, si son aptos para **veganos/vegetarianos** y si son **perecederos**.

### Uniformidad

Stock por prenda y talla (camiseta, sudadera y pañoleta), precios configurables y **registro completo de ventas**.

---

## Generador de campamentos

**Datos de entrada:** número de niños, días, lugar, época del año, temática y número de personas con cada alergia o dieta.

**Qué genera:**

1. **Horario diario** con la actividad de cada franja (respetando época, temática, secciones y duración).
2. **Dossier de actividades** con la ficha de cada una, en orden.
3. **Menú** con cantidades calculadas y **menús alternativos** para alergias y dietas.
4. **Lista de la compra:** compra inicial (no perecederos) + compra por día (perecederos).
5. **Lista de materiales que faltan.**

**Flujo:** formulario → pantalla de resumen editable (el coordinador puede cambiar actividades y platos) → descarga en PDF (actividades, cocina o completo). Los campamentos se guardan para consultarlos o reutilizarlos.

> **Privacidad:** la aplicación **no guarda datos personales de los niños**. Las alergias y dietas se indican solo como números en cada campamento.

---

## Usuarios y permisos

- Usuarios: los scouters del grupo + una cuenta de administración.
- Control de acceso **basado en cargos** (RBAC): cada cargo tiene unos permisos y una persona puede tener varios cargos (sus permisos se suman).
- El administrador crea y edita cargos y permisos desde la propia aplicación.

Cargos iniciales: coordinador general, vicecoordinador, coordinador de campamento, encargado de material, uniformidad y scouter.

---

## Tecnologías

| Parte                | Tecnología                                             |
| -------------------- | ------------------------------------------------------ |
| Back                 | Node.js + Express (API REST)                           |
| Base de datos        | PostgreSQL en Supabase (librería `pg` desde Express)   |
| Front                | HTML + JavaScript + Tailwind CSS (React en evaluación) |
| Seguridad            | bcrypt (contraseñas) + JWT (sesión), login propio      |
| Pruebas de API       | Thunder Client                                         |
| Control de versiones | Git + GitHub                                           |

---

## Arquitectura

Back y front **separados**. El front pide datos a la API y la API responde en JSON.

```
┌──────────────┐   petición HTTP   ┌───────────────┐   SQL   ┌──────────────┐
│    Front     │ ────────────────► │  API Express  │ ──────► │  PostgreSQL  │
│ (navegador)  │ ◄──────────────── │   (Node.js)   │ ◄────── │  (Supabase)  │
└──────────────┘    respuesta JSON └───────────────┘         └──────────────┘
```

Flujo de seguridad: login → token JWT → middleware de autenticación → middleware de permisos → controlador.

Supabase se usa **solo como base de datos** (PostgreSQL en la nube). El login es propio (bcrypt + JWT); no se usa Supabase Auth.

---

## Estructura del proyecto

```
TFG-Mansabora/
├── back/      → API con Node.js + Express
├── front/     → interfaz de usuario
├── bd/        → scripts SQL (estructura y datos de prueba)
├── docs/      → documentación, diagramas y capturas
└── README.md
```

Estructura prevista del back:

```
back/
├── config/        → conexión a la base de datos
├── routes/        → definición de las rutas de la API
├── controllers/   → lógica de cada petición
├── models/        → consultas SQL
├── middlewares/   → autenticación y permisos
└── (archivo principal del servidor)
```

---

## Base de datos

La base de datos se agrupa en cinco bloques:

| Bloque                   | Tablas principales                                                                  |
| ------------------------ | ----------------------------------------------------------------------------------- |
| Usuarios y permisos      | usuarios, cargos, permisos, usuario_cargo, cargo_permiso                            |
| Actividades y materiales | actividades, tipos_actividad, secciones, tematicas, materiales + tablas intermedias |
| Recetas                  | recetas, ingredientes, alergenos, rellenos + tablas intermedias                     |
| Uniformidad              | prendas, tallas, stock, ventas                                                      |
| Campamentos              | campamentos, campamento_dietas, campamento_actividades, campamento_comidas          |

Decisiones de diseño:

- Las listas (secciones, tipos, temáticas, tallas…) son **tablas ampliables**: se pueden añadir valores sin tocar código.
- Las relaciones muchos a muchos se resuelven con **tablas intermedias**.
- Las cantidades de cada ingrediente se guardan en la tabla intermedia receta–ingrediente.

El diagrama entidad-relación estará en `docs/` y el modelo relacional está en [`docs/modelo-relacional.md`](docs/modelo-relacional.md).

---

## Convenciones

**Base de datos**

- Nombres en minúsculas con guion bajo (`snake_case`), sin tildes ni ñ (`contrasena`, `num_ninos`).
- Tablas en plural (`recetas`, `ingredientes`).
- Tablas intermedias con los dos nombres en singular (`receta_ingrediente`).
- Clave primaria: `id_` + nombre en singular (`id_receta`).
- Cada clave foránea se llama igual que la clave primaria a la que apunta (`id_tipo` en `actividades`).
- Booleanos con prefijo `es_`, `apto_` o `hay` (`es_admin`, `apto_vegano`).

**Commits** · [Conventional Commits](https://www.conventionalcommits.org/es/)

| Tipo       | Uso                                              |
| ---------- | ------------------------------------------------ |
| `feat`     | Nueva funcionalidad                              |
| `fix`      | Corrección de errores                            |
| `docs`     | Documentación                                    |
| `chore`    | Configuración y tareas de mantenimiento          |
| `refactor` | Reorganizar código sin cambiar su comportamiento |
| `style`    | Formato                                          |
| `test`     | Pruebas                                          |

Ejemplo: `feat(back): añade login con JWT`

---

## Planificación

| Cuándo            | Qué                                                                         |
| ----------------- | --------------------------------------------------------------------------- |
| Noviembre 2026    | Entorno, diagrama E-R, base de datos, login en la API · **primera entrega** |
| Diciembre – enero | Usuarios, permisos y listas · aprendizaje de React en Navidad               |
| Enero             | Decisión: front con React o con JavaScript sin framework                    |
| Febrero – marzo   | Actividades, materiales, recetas y uniformidad                              |
| Abril – mayo      | Generador de campamentos y PDFs                                             |
| Mayo – junio 2027 | Pruebas con datos reales, despliegue y memoria · **entrega final**          |

---

## Instalación y puesta en marcha

> Se completará cuando el back esté funcionando.

Requisitos previstos:

- Node.js (versión LTS)
- Una cuenta de Supabase con un proyecto creado (la cadena de conexión va en el archivo de variables de entorno, que no se sube a Git)
- Git
