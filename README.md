# ☕ Café Arábica — Web Application

> Sistema web full-stack para una cafetería de especialidad: menú dinámico, reservaciones online y generación de logs, desplegado con Docker en AWS EC2.

---

## 📐 Arquitectura

```
Usuario (Navegador)
        │
        ▼
  [ EC2 – Puerto 8080 ]
        │
        ▼
  ┌─────────────┐
  │   Frontend  │  Nginx + HTML/CSS/JS
  └──────┬──────┘
         │  /api/*  (proxy interno)
         ▼
  ┌─────────────┐
  │   Backend   │  Flask (Python) – Puerto 5000
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐        ┌──────────────┐
  │  Base de    │        │  S3 Bucket   │
  │  datos MySQL│        │  (logs/statics)│
  └─────────────┘        └──────────────┘
```

---

## 🛠️ Tecnologías utilizadas

| Capa        | Tecnología                      |
|-------------|---------------------------------|
| Frontend    | HTML5, CSS3, Vanilla JS, Nginx  |
| Backend     | Python 3.11, Flask, Flask-CORS  |
| Base de datos | MySQL 8.0                     |
| Contenedores | Docker, Docker Compose         |
| Nube        | AWS EC2, AWS S3, CloudFormation |
| Automatización | Bash, cron                   |
| Versiones   | Git / GitHub                    |

---

## 📁 Estructura del proyecto

```
cafe-arabica/
├── backend/
│   ├── app.py              # API Flask
│   ├── requirements.txt
│   ├── Dockerfile
│   └── init.sql            # Schema + datos semilla MySQL
├── frontend/
│   ├── index.html          # Interfaz de usuario
│   ├── styles.css
│   ├── script.js
│   ├── nginx.conf
│   └── Dockerfile
├── cloudformation/
│   └── template.yaml       # IaC: EC2 + S3
├── docker-compose.yml
├── deploy.sh               # Despliegue completo
├── start_app.sh            # Arranque (cron: 07:00)
├── stop_app.sh             # Apagado  (cron: 22:30)
└── README.md
```

---

## 🚀 Ejecución local

### Pre-requisitos
- Docker Desktop instalado y corriendo
- Git

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/cafe-arabica.git
cd cafe-arabica

# 2. Levantar todos los servicios
docker-compose up --build -d

# 3. Verificar que estén corriendo
docker-compose ps
```

Abre tu navegador en: **http://localhost:8080**

La API estará disponible en: **http://localhost:5000**

### Detener la aplicación

```bash
docker-compose down
```

---

## ☁️ Despliegue en EC2 (AWS)

### 1. Crear la infraestructura con CloudFormation

```bash
aws cloudformation deploy \
  --template-file cloudformation/template.yaml \
  --stack-name cafe-arabica-stack \
  --parameter-overrides \
      KeyPairName=mi-llave \
      MyPublicIP=<TU_IP>/32 \
      RepoURL=https://github.com/tu-usuario/cafe-arabica.git \
      BucketName=cafe-arabica-mi-bucket \
  --capabilities CAPABILITY_NAMED_IAM
```

### 2. Conexión SSH a la instancia

```bash
ssh -i mi-llave.pem ec2-user@<IP_PUBLICA_EC2>
```

### 3. Despliegue manual (si no se usó UserData)

```bash
cd /opt/cafe-arabica
bash deploy.sh https://github.com/tu-usuario/cafe-arabica.git
```

La app estará en: **http://\<IP_PUBLICA_EC2\>:8080**

---

## 🔌 Puertos utilizados

| Puerto | Servicio          | Descripción                         |
|--------|-------------------|-------------------------------------|
| 8080   | Frontend (Nginx)  | Acceso principal al sitio web       |
| 5000   | Backend (Flask)   | API REST                            |
| 3306   | MySQL             | Solo interno en la red Docker       |

---

## 📋 API Endpoints

| Método | Ruta                  | Descripción                |
|--------|-----------------------|----------------------------|
| GET    | `/api/health`         | Estado del servicio        |
| GET    | `/api/menu`           | Lista el menú completo     |
| POST   | `/api/orders`         | Crea una nueva orden       |
| POST   | `/api/reservations`   | Crea una reservación       |
| GET    | `/api/reservations`   | Lista todas las reservaciones|
| GET    | `/api/logs`           | Últimas 100 líneas del log |

---

## 📝 Logs

Los logs se generan en `/app/logs/app.log` dentro del contenedor `backend`:

```
[2026-04-15 10:00:00] INFO: Servidor Café Arábica iniciado
[2026-04-15 10:01:23] INFO: Menú consultado – 16 productos devueltos
[2026-04-15 10:03:45] INFO: Reservación #1 creada – Ana García para 2026-04-20 19:00 (2 personas)
[2026-04-15 10:05:11] ERROR: Fallo en conexión a base de datos
```

Para verlos en tiempo real:

```bash
docker exec cafe_backend tail -f /app/logs/app.log
```

---

## ⏰ Cron Jobs (EC2)

```bash
# Editar crontab
crontab -e

# Agregar estas líneas:
0 7    * * * /opt/cafe-arabica/start_app.sh >> /var/log/cafe-cron.log 2>&1
30 22  * * * /opt/cafe-arabica/stop_app.sh  >> /var/log/cafe-cron.log 2>&1
```

---

## 🗄️ S3 – Almacenamiento

| Uso            | Ruta en S3              |
|----------------|-------------------------|
| Logs diarios   | `s3://BUCKET/logs/`     |
| Archivos estáticos | `s3://BUCKET/static/` |

Subir logs manualmente:

```bash
aws s3 cp /var/log/cafe-arabica-app.log s3://cafe-arabica-mi-bucket/logs/
```

---

## 🔒 Seguridad

- SSH restringido a la IP del administrador (no `0.0.0.0/0`)
- IAM Role con principio de mínimo privilegio (solo acceso al bucket propio)
- Variables sensibles inyectadas por Docker Compose (no hardcodeadas en código)
- S3 con `PublicAccessBlock` habilitado

---

## 👩‍💻 Autor

Proyecto académico – Fundamentos de DevOps · 2026
