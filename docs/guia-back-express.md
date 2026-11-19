# Guía · Montar el back con Express y conectarlo a Supabase

Semana 3, partes A y B. Al terminar tendrás un servidor Express que arranca, se conecta a tu base de datos de Supabase y tiene una ruta que devuelve las secciones en JSON.

Como en las otras guías, los ejemplos usan la **biblioteca** (autores, libros, géneros). Tú haces lo mismo con tus tablas. Donde pone **Tú:**, te toca a ti.

Todos los comandos son para la **terminal de VS Code** (Ctrl + ñ) en Windows.

---

## Antes de empezar

Comprueba que tienes Node instalado. En la terminal:

```bash
node -v
npm -v
```

Si salen dos números de versión (por ejemplo `v24.…` y `11.…`), todo está bien. Si dice que no reconoce el comando, instala Node desde nodejs.org (versión LTS) y reinicia VS Code.

---

# PARTE A · Montar el proyecto

## Paso 1 · Entrar en la carpeta back

Abre en VS Code la carpeta **TFG-Mansabora** (la del repo entero, no solo `back`). Luego, en la terminal:

```bash
cd back
```

Fíjate en que la terminal ahora termina en `...\TFG-Mansabora\back>`. **Todos los comandos de npm de esta guía se ejecutan aquí**, nunca en la raíz del repo.

## Paso 2 · Crear el proyecto de Node

```bash
npm init -y
```

- `npm init` crea el archivo **package.json**: el DNI del proyecto (nombre, versión, dependencias, scripts).
- `-y` responde "sí" a todas las preguntas para no tener que contestarlas una a una.

Abre `package.json`. Verás algo así:

```json
{
  "name": "back",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
```

## Paso 3 · Activar import/export

Node tiene dos formas de traer código de otro archivo:

| Forma antigua (CommonJS) | Forma moderna (módulos ES) |
|---|---|
| `const express = require('express')` | `import express from 'express'` |

Vas a usar **la moderna**, que es la misma que en React. Para activarla, añade esta línea en `package.json`, por ejemplo debajo de `"main"`:

```json
  "main": "index.js",
  "type": "module",
```

⚠️ Ojo con las comas: cada línea lleva coma al final menos la última de su bloque.

A partir de ahora, **nunca uses `require`**. Y en los `import` de tus propios archivos escribe siempre la extensión: `'./config/db.js'`, no `'./config/db'`.

## Paso 4 · Instalar las dependencias

Una dependencia es código que ha escrito otra persona y que tu proyecto usa. Instálalas todas con un comando:

```bash
npm install express pg bcrypt jsonwebtoken dotenv cors
```

Y nodemon aparte, como dependencia **solo de desarrollo** (`-D`):

```bash
npm install -D nodemon
```

Qué es cada una (apúntatelo, porque te lo pueden preguntar):

| Paquete | Para qué sirve |
|---|---|
| **express** | Crear el servidor y las rutas (las URL de la API) |
| **pg** | Conectarse a PostgreSQL y lanzar consultas SQL desde Node |
| **bcrypt** | Cifrar contraseñas (hash) y comprobarlas en el login |
| **jsonwebtoken** | Crear y comprobar los tokens de sesión (JWT) |
| **dotenv** | Leer las variables del archivo `.env` |
| **cors** | Permitir que el front, que irá en otro puerto, llame a la API |
| **nodemon** | Reiniciar el servidor solo cada vez que guardas un archivo |

Después de instalar verás tres cosas nuevas:

- **node_modules/**: el código de los paquetes. Pesa mucho y **no se sube a GitHub** (tu `.gitignore` ya lo excluye).
- **package-lock.json**: las versiones exactas instaladas. **Sí se sube.**
- En `package.json`, dos bloques nuevos: `dependencies` y `devDependencies`.

> Si alguien clona tu repo, solo tiene que ejecutar `npm install` dentro de `back` y se le descarga todo lo de `node_modules`.

### Si PowerShell da error al ejecutar npm

Si sale algo como *"la ejecución de scripts está deshabilitada en este sistema"*, abre el desplegable **+ ˅** de la terminal, elige **Command Prompt** y repite el comando allí.

## Paso 5 · Los scripts para arrancar

En `package.json`, sustituye el bloque `"scripts"` por este:

```json
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
```

- `npm run dev` → arranca con nodemon (el que usarás mientras programas).
- `npm start` → arranca normal (el que se usará al desplegar).

## Paso 6 · Las variables de entorno

Las variables de entorno son datos de configuración que **no van en el código**, sobre todo los secretos. Ya tienes un archivo `back/.env`. Ábrelo y comprueba que tiene estas tres variables (los nombres son un ejemplo; si ya usas otros, mantenlos y úsalos igual en todo el código):

```
DATABASE_URL=postgresql://postgres.xxxxxxxx:TU_CONTRASEÑA@aws-0-eu-west-3.pooler.supabase.com:5432/postgres
PORT=3000
JWT_SECRET=una_frase_larga_y_rara_que_solo_sepas_tu
```

Reglas del archivo `.env`:

- Una variable por línea, `NOMBRE=valor`.
- **Sin espacios** alrededor del `=` y **sin comillas**.
- Los nombres van en mayúsculas.

### De dónde sacar la cadena de conexión

1. Entra en tu proyecto de Supabase y pulsa el botón **Connect** (arriba).
2. En el desplegable de método elige **Session pooler** (no Direct connection, que no funciona en muchas redes de casa).
3. Copia la URI y cambia `[YOUR-PASSWORD]` por la contraseña de la base de datos (la que pusiste al crear el proyecto, **no** la de tu cuenta de Supabase).
4. Si la URI termina en `?sslmode=require` o algo parecido, **quita esa parte**: el SSL lo configurarás en el código (paso 10).

⚠️ Si tu contraseña tiene símbolos como `@`, `#`, `/` o `%`, la cadena se rompe. Lo más fácil: en Supabase, **Database → Settings → Reset database password**, y pon una con solo letras y números.

### El archivo de ejemplo

Crea `back/.env.example` con **los mismos nombres pero sin valores**:

```
DATABASE_URL=
PORT=3000
JWT_SECRET=
```

Este sí se sube a GitHub: sirve para que quien clone el repo sepa qué variables tiene que rellenar.

### Comprueba que el .env no se va a subir

En la terminal:

```bash
git status
```

Debe aparecer `.env.example` y **no** debe aparecer `.env`. Si aparece `.env`, para y revisa el `.gitignore` antes de hacer ningún commit.

## Paso 7 · Las carpetas

Dentro de `back`, crea estas carpetas (clic derecho → **Nueva carpeta**):

```
back/
├── config/        → la conexión a la base de datos
├── routes/        → qué URL existe y qué función la atiende
├── controllers/   → recibe la petición, decide qué hacer y responde
├── models/        → las consultas SQL
├── middlewares/   → comprobaciones antes del controlador (login, permisos)
├── index.js       → arranca el servidor
├── package.json
├── .env
└── .env.example
```

Piensa en un restaurante:

| Parte | En el restaurante | En tu API |
|---|---|---|
| **routes** | La carta: qué se puede pedir | `GET /api/secciones` |
| **controllers** | El camarero: toma el pedido y trae el plato | Recibe la petición y devuelve el JSON |
| **models** | La cocina: prepara lo que se pide | Hace la consulta SQL |
| **middlewares** | El portero: mira si puedes entrar | ¿Tiene token? ¿Tiene permiso? |

Git no sube carpetas vacías. Puedes meter un archivo vacío `.gitkeep` en cada una, como ya hiciste en `bd` y `docs`, o esperar a tener archivos dentro.

Ya puedes borrar `back/.gitkeep`: la carpeta ya no está vacía.

### Commit de la parte A

```bash
cd ..
git add back
git status
```

Revisa la lista: deben estar `package.json`, `package-lock.json` y `.env.example`, y **no** deben estar `.env` ni `node_modules`. Si está bien:

```bash
git commit -m "chore(back): inicia proyecto Express con dependencias y estructura"
cd back
```

---

# PARTE B · Primeras rutas

## Paso 8 · El servidor arranca

Crea `back/index.js`. Así sería en la biblioteca:

```js
import 'dotenv/config';
import express from 'express';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ mensaje: 'API de la biblioteca funcionando' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
```

Línea a línea:

- `import 'dotenv/config'` → lee el `.env`. **Tiene que ser la primera línea**, antes de usar cualquier variable.
- `express()` → crea la aplicación.
- `app.use(cors())` → deja que otras webs (tu front) llamen a la API.
- `app.use(express.json())` → permite leer el JSON que llega en las peticiones (lo necesitarás en el login).
- `app.get('/', …)` → una ruta: cuando alguien pide `GET /`, se ejecuta esa función.
  - `req` (request) es **lo que llega**; `res` (response) es **lo que devuelves**.
- `process.env.PORT` → la variable `PORT` del `.env`.
- `app.listen` → el servidor se queda esperando peticiones.

**Tú:** escribe tu `index.js` con un mensaje de la API del TFG.

Arranca:

```bash
npm run dev
```

Debe salir `Servidor escuchando en http://localhost:3000`. El servidor se queda corriendo: esa terminal ya no te deja escribir. Para pararlo, pulsa **Ctrl + C**. Para seguir usando comandos sin pararlo, abre otra terminal con el **+**.

Prueba: abre `http://localhost:3000` en el navegador. Tiene que salir tu mensaje en JSON.

Prueba nodemon: cambia el texto del mensaje, guarda (Ctrl + S) y recarga el navegador. Debe salir el texto nuevo sin haber reiniciado nada.

## Paso 9 · Instalar Thunder Client

El navegador solo sirve para peticiones GET. Para probar el login (POST) y las rutas protegidas necesitas un cliente de API.

1. VS Code → Extensiones → busca **Thunder Client** → Instalar.
2. Aparece un rayo ⚡ en la barra de la izquierda. Púlsalo.
3. **New Request** → deja **GET** → escribe `http://localhost:3000` → **Send**.
4. Abajo a la derecha verás `Status: 200 OK` y tu JSON.

Crea una **Collection** llamada "TFG Mansaborá" y guarda ahí cada petición (botón **Save**). Al final de la semana servirá para las capturas del documento.

## Paso 10 · La conexión a la base de datos

### Qué es un pool

Abrir una conexión a una base de datos es lento. Un **pool** es un grupo de conexiones que se abren una vez y se reutilizan: llega una petición, coge una conexión libre, hace la consulta y la devuelve al grupo. Es como el carrito del supermercado: no te fabrican uno cada vez que entras.

### El archivo de conexión

Crea `back/config/db.js`:

```js
import pg from 'pg';

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

export default pool;
```

- `connectionString` → la cadena del `.env`.
- `ssl` → Supabase solo acepta conexiones cifradas. `rejectUnauthorized: false` cifra la conexión sin pedirte instalar el certificado de Supabase en tu ordenador. Para el TFG vale; en la memoria puedes comentar que en producción se configuraría el certificado.
- `export default pool` → para poder importarlo desde los modelos.

### Comprobar al arrancar que conecta

En `index.js`, importa el pool y haz una consulta de prueba antes del `app.listen`:

```js
import pool from './config/db.js';

// …

try {
  const resultado = await pool.query('SELECT NOW()');
  console.log('Conectado a la base de datos:', resultado.rows[0].now);
} catch (error) {
  console.error('No se pudo conectar a la base de datos:', error.message);
}
```

- `SELECT NOW()` devuelve la hora del servidor. Si llega, la conexión funciona.
- `await` espera la respuesta. Se puede usar suelto en `index.js` gracias al `"type": "module"`.
- `try/catch` hace que, si falla, veas un mensaje claro en vez de un error enorme.

Guarda. En la terminal de nodemon debe salir `Conectado a la base de datos: …` con la fecha.

Si no conecta, mira la tabla de **Errores típicos** del final.

## Paso 11 · Primera ruta con datos reales

Este es **el patrón de todo el TFG**: ruta → controlador → modelo → respuesta. Lo harás igual para actividades, recetas, materiales…

Para la biblioteca, ruta `GET /api/generos`:

### 11.1 · El modelo (la cocina)

`back/models/generos.model.js`:

```js
import pool from '../config/db.js';

export async function obtenerGeneros() {
  const resultado = await pool.query(
    'SELECT id_genero, nombre FROM generos ORDER BY nombre'
  );
  return resultado.rows;
}
```

- `../` sube una carpeta: desde `models` vuelve a `back` y entra en `config`.
- **Ojo:** `pool.query` no devuelve las filas directamente, sino un objeto con mucha información. Las filas están en `resultado.rows`.

### 11.2 · El controlador (el camarero)

`back/controllers/generos.controller.js`:

```js
import { obtenerGeneros } from '../models/generos.model.js';

export async function listarGeneros(req, res) {
  try {
    const generos = await obtenerGeneros();
    res.status(200).json(generos);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener los géneros' });
  }
}
```

- Si todo va bien → código **200** y la lista en JSON.
- Si algo falla → código **500** (error del servidor). El detalle va a la consola, que solo ves tú; al cliente le llega un mensaje genérico.

### 11.3 · La ruta (la carta)

`back/routes/generos.routes.js`:

```js
import { Router } from 'express';
import { listarGeneros } from '../controllers/generos.controller.js';

const router = Router();

router.get('/', listarGeneros);

export default router;
```

### 11.4 · Conectarla en index.js

Debajo de los `app.use` del principio:

```js
import generosRoutes from './routes/generos.routes.js';

// …

app.use('/api/generos', generosRoutes);
```

La URL final se forma sumando las dos partes: `'/api/generos'` (index.js) + `'/'` (archivo de rutas) = `GET /api/generos`.

**Tú:** haz lo mismo para **secciones**, con los archivos `secciones.model.js`, `secciones.controller.js` y `secciones.routes.js`, y la ruta `GET /api/secciones`. Mira en `01-estructura.sql` los nombres exactos de las columnas.

### 11.5 · ¿Por qué RLS no lo bloquea?

Tienes RLS activado en todas las tablas y no has creado ninguna política, así que cualquiera que entre por la API pública de Supabase no ve nada. Tu back entra con el usuario `postgres` (el de la cadena de conexión), que es el dueño de las tablas y se salta RLS. Resultado: **solo tu API puede leer los datos**. Es buena respuesta para el tribunal.

### Probar

En Thunder Client: **GET** `http://localhost:3000/api/secciones` → **Send**. Debe salir `200 OK` y las cinco secciones de tus datos de prueba:

```json
[
  { "id_seccion": 1, "nombre": "Castores" },
  { "id_seccion": 5, "nombre": "Clan" },
  …
]
```

Guarda la petición en la colección. 🎉

## Paso 12 · Consultas seguras (léelo ahora, lo usarás en el login)

Cuando una consulta lleve un dato que viene del usuario (un email, un id de la URL…), **nunca** lo pegues dentro del texto del SQL:

```js
// ❌ MAL: inyección SQL
pool.query(`SELECT * FROM libros WHERE titulo = '${titulo}'`);
```

Si alguien escribe como título `' OR '1'='1`, la consulta devuelve todos los libros. Con otros textos podría incluso borrar tablas. Esto se llama **inyección SQL**.

Lo correcto es dejar **huecos** y pasar los valores aparte. En `pg` los huecos van **numerados** con `$`:

```js
// ✅ BIEN: consulta parametrizada
pool.query(
  'SELECT * FROM libros WHERE titulo = $1 AND id_autor = $2',
  [titulo, idAutor]
);
```

`$1` se rellena con el primer valor del array y `$2` con el segundo. La librería trata esos valores siempre como datos, nunca como SQL.

> En MySQL los huecos eran `?`. En PostgreSQL son `$1`, `$2`…

**Tú (opcional, para practicar):** haz `GET /api/secciones/:id`, que devuelva una sola sección. Pistas:
- El `:id` de la URL se lee con `req.params.id`.
- Si la consulta no devuelve filas (`rows.length === 0`), responde **404**.

### Commit de la parte B

```bash
git add back
git commit -m "feat(back): añade servidor Express, conexión a Supabase y ruta de secciones"
```

---

## Errores típicos

| Error | Causa | Solución |
|---|---|---|
| `Cannot use import statement outside a module` | Falta `"type": "module"` | Añádelo en `package.json` (paso 3) |
| `require is not defined in ES module scope` | Has usado `require` | Cámbialo por `import` |
| `Cannot find module '…/config/db'` | Falta el `.js` en el import, o la ruta está mal | Escribe `'../config/db.js'` y revisa los `../` |
| `Cannot find package 'express'` | No has instalado, o lo hiciste fuera de `back` | `cd back` y `npm install` |
| `EADDRINUSE: address already in use :::3000` | Ya tienes el servidor corriendo en otra terminal | Ciérralo con Ctrl + C o cierra esa terminal |
| `password authentication failed` | Contraseña mal en `DATABASE_URL` | Revisa la contraseña de la **base de datos**, no la de la cuenta |
| `getaddrinfo ENOTFOUND` | Cadena de conexión mal copiada, o has usado la Direct connection | Copia la del **Session pooler** |
| `self-signed certificate in certificate chain` | La cadena lleva `?sslmode=…` | Quítalo y deja solo el `ssl` del pool |
| `Tenant or user not found` | El usuario de la cadena está mal | En el pooler es `postgres.xxxxxxxx`, con el punto y el id del proyecto |
| `relation "secciones" does not exist` | Conectas a otro proyecto o no ejecutaste los scripts | Revisa la cadena y el Table Editor de Supabase |
| `undefined` donde debería estar el puerto o la cadena | El `.env` no se lee | `import 'dotenv/config'` como **primera** línea; `.env` dentro de `back`; sin espacios ni comillas |
| No conecta un día sin haber cambiado nada | El proyecto de Supabase está **pausado** | Panel de Supabase → **Restore project** |
| Thunder Client: `Connection was refused` | El servidor no está arrancado | `npm run dev` |

---

## Checklist

- [ ] `package.json` con `"type": "module"` y los scripts `start` y `dev`
- [ ] Dependencias instaladas, y sabes explicar para qué sirve cada una
- [ ] `.env` con las tres variables y **fuera de Git**; `.env.example` sin valores, dentro
- [ ] Carpetas `config`, `routes`, `controllers`, `models`, `middlewares`
- [ ] `npm run dev` arranca y dice que está conectado a la base de datos
- [ ] `GET /api/secciones` devuelve las secciones en Thunder Client
- [ ] Petición guardada en la colección "TFG Mansaborá"
- [ ] Sabes explicar qué es la inyección SQL y cómo la evitan `$1`, `$2`
- [ ] Commits: `chore(back): …` y `feat(back): …`

**Siguiente:** Parte C de la semana 3, usuarios y login con bcrypt y JWT.
