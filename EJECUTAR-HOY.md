# 🚀 EJECUTAR HOY - GottaBot en local (Windows)

> **Objetivo**: en 60-90 minutos tienes el bot funcionando en tu PC, recibiendo mensajes reales de WhatsApp, agendando en Google Calendar, sin gastar un peso.

---

## 📋 LO QUE NECESITAS

✅ Una PC con Windows 10/11 y al menos **8 GB de RAM**  
✅ **15 GB libres** en disco  
✅ Una cuenta Google (Gmail) para Calendar/Sheets  
✅ Un teléfono con WhatsApp para escanear QR (puede ser el tuyo de pruebas)  
✅ 60-90 minutos de tiempo concentrado

**Costo: $0 USD.** No te van a pedir tarjeta en ningún paso.

---

# 🟢 FASE 1 — Instalar Docker Desktop (15 min)

Docker es lo que va a correr n8n y Evolution en tu PC como si fueran "mini-servidores".

### Paso 1.1
Abre tu navegador y entra a:  
👉 https://www.docker.com/products/docker-desktop/

### Paso 1.2
Clic en **"Download for Windows"** → descarga el `.exe` (~700 MB).

### Paso 1.3
Doble clic al instalador. Marca:
- ☑ Use WSL 2 instead of Hyper-V (recomendado)
- ☑ Add shortcut to desktop

Clic en **OK** y espera. **REINICIA la PC** cuando te lo pida.

### Paso 1.4
Después del reinicio, abre **Docker Desktop**. Verás un dashboard. Espera a que en la esquina inferior izquierda diga **"Engine running"** (puede tardar 1-2 minutos la primera vez).

> ⚠️ Si te pide instalar WSL 2, abre PowerShell como Administrador y ejecuta:
> ```
> wsl --install
> ```
> Reinicia y vuelve a abrir Docker Desktop.

---

# 🟢 FASE 2 — Levantar n8n y Evolution (5 min)

### Paso 2.1
Crea una carpeta en tu PC, por ejemplo: `C:\gottavital`

### Paso 2.2
Descarga estos archivos en esa carpeta (los tienes adjuntos arriba):
- `docker-compose.yml`
- `instalar.bat`
- `detener.bat`
- `.env.example`

### Paso 2.3 — Configurar variables de entorno
1. Copia `.env.example` y renómbralo a `.env`.
2. Ábrelo con el Bloc de notas y rellena los valores reales:
   - `EVOLUTION_API_KEY`: una clave aleatoria larga que tú inventas (ej. de un generador de contraseñas)
   - `POSTGRES_PASSWORD`: otra clave aleatoria larga
   - `GROQ_API_KEY`: la consigues en la Fase 4
   - `GOOGLE_SHEETS_ID`: lo consigues en la Fase 5
3. Guarda el archivo.

> ⚠️ El archivo `.env` NUNCA se sube a GitHub. Está en `.gitignore`.

### Paso 2.4
Doble clic en **`instalar.bat`**.

Verás algo así en una ventana negra:
```
[OK] Docker detectado.
[OK] Docker esta corriendo.
Levantando contenedores...
✓ Container gv-postgres   Started
✓ Container gv-redis      Started
✓ Container gv-evolution  Started
✓ Container gv-n8n        Started
LISTO!
```

La primera vez tarda **2-3 minutos** porque descarga las imágenes (~2 GB). Las próximas veces es de 10 segundos.

### Paso 2.4
Al final se abrirá automáticamente **http://localhost:5678** en tu navegador. Es n8n.

Te pedirá crear una cuenta (es solo local, no se guarda en internet):
- Email: el que quieras
- Password: el que quieras (anótalo)
- First name / Last name

✅ **Ya tienes n8n corriendo.**

---

# 🟢 FASE 3 — Conectar WhatsApp a Evolution (10 min)

### Paso 3.1
Abre en el navegador:  
👉 http://localhost:8080/manager

### Paso 3.2
Te pide la API key. Pega:
```
TU_EVOLUTION_API_KEY (la del .env)
```

### Paso 3.3
Clic en **"+ Instance"** (crear instancia). Llénalo así:
- **Name**: `gottavital`
- **Integration**: `WHATSAPP-BAILEYS`
- Deja el resto por defecto
- Clic en **"Save"**

### Paso 3.4
La instancia aparece en la lista. Clic en ella → verás un **código QR**.

### Paso 3.5
**En tu teléfono**:
1. Abre WhatsApp
2. Configuración → Dispositivos vinculados → Vincular un dispositivo
3. Escanea el QR que está en tu PC

El QR cambia a verde y dice **"Connected"** ✅

> 💡 Usa un número de pruebas si puedes (puede ser un WhatsApp gratuito en un celular viejo o un chip nuevo). Para producción luego conseguirás un número dedicado.

---

# 🟢 FASE 4 — Obtener API key de Groq (3 min, GRATIS)

### Paso 4.1
Abre:  
👉 https://console.groq.com

### Paso 4.2
Clic en **"Sign Up"** → entra con tu Gmail (no pide tarjeta).

### Paso 4.3
En el menú lateral: **"API Keys"** → **"+ Create API Key"** → ponle nombre `gottabot` → **Submit**.

### Paso 4.4
Copia la key que empieza con `gsk_...` y **guárdala en un bloc de notas**. No la vas a poder ver de nuevo.

✅ **Tienes 14.400 requests gratis por día** con Llama 3.3 70B. Más que suficiente.

---

# 🟢 FASE 5 — Configurar Google Sheets (5 min)

### Paso 5.1
Abre 👉 https://sheets.google.com → crea una hoja nueva.

### Paso 5.2
Renómbrala a **"GottaVital - Citas"**.

### Paso 5.3
En la primera fila (A1 hasta N1) pega exactamente estos encabezados:
```
fecha_creacion	fecha_cita	hora_cita	nombre	telefono	ciudad	barrio	direccion	sueros	total	notas	estado	fuente	gcal_event_id
```

### Paso 5.4
Copia el **ID** de la hoja, está en la URL:
```
https://docs.google.com/spreadsheets/d/AQUÍ_ESTÁ_EL_ID/edit
                                      └────────┬────────┘
                                      Cópialo entero
```
Guárdalo junto con la API key de Groq.

---

# 🟢 FASE 6 — Importar el workflow en n8n (10 min)

### Paso 6.1
Vuelve a n8n (http://localhost:5678).

### Paso 6.2
Arriba a la derecha clic en los **3 puntos** → **"Import from File"** → selecciona `workflow-groq.json`.

Aparece el workflow con todos los nodos conectados.

### Paso 6.3 — Configurar Groq
1. Doble clic en el nodo **"Groq Llama 3.3"**.
2. En la sección **Headers**, busca el header `Authorization`.
3. Cambia `Bearer TU_GROQ_API_KEY_AQUI` por:
   ```
   Bearer gsk_tu_key_real_aquí
   ```
4. Clic en **Execute Node** para probarla. Debe responder algo.
5. Cierra el nodo.

### Paso 6.4 — Configurar Google Calendar
1. Doble clic en **"GCal: Verificar"**.
2. En **Credential to connect with** clic en el dropdown → **"+ Create New Credential"**.
3. Se abre una ventana → clic en **"Sign in with Google"** → autoriza con tu cuenta.
4. Vuelve a n8n. La credencial queda guardada.
5. Haz lo mismo (o reutiliza la credencial) en el nodo **"GCal: Crear cita"**.

### Paso 6.5 — Configurar Google Sheets
1. Doble clic en **"Sheets: Registrar"**.
2. **Credential** → **"+ Create New"** → autoriza con Google.
3. En el campo **Document ID**, pega el ID de tu hoja (el que guardaste).
4. En **Sheet Name** deja `Citas` (o el nombre de la pestaña, por defecto es `Hoja 1` → cámbiale el nombre a `Citas` en la hoja).

### Paso 6.6 — Activar
Arriba a la derecha, mueve el toggle de **"Inactive" a "Active"** (verde).

✅ **El bot está vivo.**

---

# 🟢 FASE 7 — Conectar Evolution con n8n (3 min)

Evolution necesita saber a qué URL mandar los mensajes entrantes.

### Paso 7.1
En n8n, abre el nodo **"Webhook Entrada"** y copia la **Production URL**. Será algo como:
```
http://localhost:5678/webhook/gottavital-wa
```

> ⚠️ Como Evolution corre en Docker y n8n también, NO uses `localhost` para que Evolution lo encuentre. Usa este URL:
> ```
> http://n8n:5678/webhook/gottavital-wa
> ```

### Paso 7.2
Vuelve a Evolution: http://localhost:8080/manager → entra a tu instancia `gottavital`.

### Paso 7.3
Busca la pestaña **"Webhook"** o **"Events"** → configura:
- **URL**: `http://n8n:5678/webhook/gottavital-wa`
- **Webhook by events**: OFF
- **Events**: marca solo `MESSAGES_UPSERT`
- Guarda.

> Si no encuentras la opción visual, puedes hacerlo con un comando. Abre PowerShell y ejecuta:
> ```powershell
> $headers = @{ "apikey" = "TU_EVOLUTION_API_KEY (la del .env)"; "Content-Type" = "application/json" }
> $body = '{"url":"http://n8n:5678/webhook/gottavital-wa","webhook_by_events":false,"events":["MESSAGES_UPSERT"]}'
> Invoke-RestMethod -Uri "http://localhost:8080/webhook/set/gottavital" -Method POST -Headers $headers -Body $body
> ```

---

# 🎉 FASE 8 — PROBAR

### Prueba 1: Saludo
Desde **OTRO** WhatsApp (no el que conectaste), escribe al número conectado:
```
hola
```

Debe responder en 3-5 segundos algo como:
> ¡Hola! 💧 Soy GottaBot de *GottaVital*...

### Prueba 2: Pregunta precio
```
cuánto vale el de energía
```

### Prueba 3: Agendar
```
quiero agendar mañana a las 10am en El Poblado
```

El bot te pedirá los datos uno por uno. Cuando confirmes, mira:
- 📅 Tu **Google Calendar** → debe aparecer el evento
- 📊 Tu **Google Sheet** → debe aparecer una nueva fila

### Si algo falla
1. En n8n, ve a **"Executions"** (menú izquierdo).
2. Verás cada ejecución. Las rojas tienen error → clic para ver dónde se rompió.

---

# 🛠 PROBLEMAS COMUNES

### "Docker no inicia"
- Verifica que la virtualización está activa en la BIOS (busca "Intel VT-x" o "AMD-V").
- Reinstala WSL: `wsl --install` en PowerShell admin.

### "El QR de Evolution no aparece"
- Espera 30 segundos más, a veces tarda.
- Borra la instancia y créala de nuevo.

### "Groq dice 401"
- La API key está mal copiada. Verifica que pusiste `Bearer ` (con espacio) antes de la key.

### "El bot no responde nada"
- Revisa **Executions** en n8n. Busca el último intento.
- Si no aparece ninguna ejecución → Evolution no está llamando a n8n. Revisa el webhook.

### "Calendar dice no autorizado"
- Vuelve al nodo Calendar, borra la credencial y crea una nueva.

---

# 📦 DESPUÉS DE PROBAR

### Para detener todo (sin perder datos):
Doble clic en **`detener.bat`**. Todo se apaga, los datos se guardan.

### Para volver a levantar:
Doble clic en **`instalar.bat`**. Tarda 10 segundos.

### Para mover a producción (cuando estés listo):
1. Renta un VPS por $5/mes (Hetzner, Contabo, DigitalOcean).
2. Copia los mismos archivos al VPS.
3. Configura un dominio + HTTPS con Nginx + Let's Encrypt.
4. Cambia `http://localhost:5678` por `https://tu-dominio.com`.

El workflow no cambia, solo las URLs.

---

# 🎁 EXTRA: Enlazar con la página web

Una vez tengas el bot funcionando, puedes pegar el widget de chat de `04-widget-chat-web.html` (del paquete anterior) en `gottavital.html`. Reemplaza la URL del webhook por:

**Local (para probar):**
```js
const WEBHOOK_URL = 'http://localhost:5678/webhook/gottavital-wa';
```

**Producción:**
```js
const WEBHOOK_URL = 'https://tu-dominio.com/webhook/gottavital-wa';
```

---

## ⏱ Tiempo total estimado

| Fase | Tiempo |
|---|---|
| Docker Desktop | 15 min |
| Levantar contenedores | 5 min |
| Conectar WhatsApp | 10 min |
| Groq API key | 3 min |
| Google Sheets | 5 min |
| Importar workflow | 10 min |
| Conectar webhook | 3 min |
| Pruebas | 10 min |
| **Total** | **~60 min** |

---

¿Listo? Empieza por la **FASE 1**. Si te trabas en algún paso, dime exactamente en qué fase y qué mensaje de error te aparece, y te ayudo a salir.
