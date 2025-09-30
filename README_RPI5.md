# HPOExplorer - Raspberry Pi 5 Installation with Docker

> 🇬🇧 **English** | 🇪🇸 [Español](#instalación-en-español)

This document provides detailed instructions for installing and running HPOExplorer on a Raspberry Pi 5 using Docker.

## Quick Start

```bash
# Download and run the setup script
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/setup-rpi5.sh
chmod +x setup-rpi5.sh
./setup-rpi5.sh
```

## Prerequisites

### Hardware
- Raspberry Pi 5 (4GB or 8GB RAM recommended)
- microSD card (minimum 32GB, 64GB+ recommended)
- Appropriate power supply for RPi 5

### Software
- Raspberry Pi OS (64-bit) - Bookworm or later
- Docker and Docker Compose installed

## Installation

### Method 1: Using docker-compose (Recommended)

```bash
# Create directory and download files
mkdir -p ~/hpoexplorer
cd ~/hpoexplorer
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/Dockerfile
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/docker-compose.yml

# Build and run
docker compose build
docker compose up -d
```

Access RStudio at `http://<your_rpi_ip>:8900` with:
- Username: `rstudio`
- Password: `hpoexplorer` (or as configured)

For detailed instructions, see the [Spanish section below](#instalación-en-español).

---

# Instalación en Español

Este documento proporciona instrucciones detalladas para instalar y ejecutar HPOExplorer en una Raspberry Pi 5 utilizando Docker.

## Requisitos Previos

### Hardware
- Raspberry Pi 5 (recomendado 4GB o 8GB RAM)
- Tarjeta microSD (mínimo 32GB, recomendado 64GB+)
- Fuente de alimentación adecuada para RPi 5

### Software
- Raspberry Pi OS (64-bit) - Bookworm o posterior
- Docker y Docker Compose instalados

## Instalación de Docker en Raspberry Pi 5

Si aún no tienes Docker instalado en tu Raspberry Pi 5, sigue estos pasos:

```bash
# Actualizar el sistema
sudo apt-get update
sudo apt-get upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Añadir tu usuario al grupo docker (para evitar usar sudo)
sudo usermod -aG docker $USER

# Reiniciar para aplicar los cambios de grupo
# O simplemente cerrar sesión y volver a iniciarla
```

### Instalar Docker Compose

```bash
# Instalar Docker Compose
sudo apt-get install docker-compose-plugin -y

# Verificar la instalación
docker compose version
```

## Método 1: Usando docker-compose (Recomendado)

Este es el método más sencillo para ejecutar HPOExplorer en tu Raspberry Pi 5.

### Paso 1: Clonar el repositorio

```bash
# Crear un directorio para el proyecto
mkdir -p ~/hpoexplorer
cd ~/hpoexplorer

# Descargar los archivos necesarios
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/Dockerfile
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/docker-compose.yml
```

### Paso 2: (Opcional) Personalizar la configuración

Edita el archivo `docker-compose.yml` para cambiar:
- La contraseña (por defecto es "hpoexplorer")
- El puerto (por defecto es 8900)
- Las rutas de volúmenes montados

```bash
nano docker-compose.yml
```

### Paso 3: Construir e iniciar el contenedor

```bash
# Construir la imagen (esto puede tardar 30-60 minutos en RPi 5)
docker compose build

# Iniciar el contenedor en segundo plano
docker compose up -d
```

### Paso 4: Acceder a RStudio

Una vez que el contenedor esté en ejecución:

1. Abre un navegador web en cualquier dispositivo en tu red local
2. Ve a: `http://<IP_de_tu_RPi5>:8900`
   - Si estás en la misma RPi, usa: `http://localhost:8900`
3. Inicia sesión con:
   - Usuario: `rstudio`
   - Contraseña: `hpoexplorer` (o la que configuraste)

## Método 2: Usando Docker directamente

Si prefieres no usar docker-compose:

### Paso 1: Construir la imagen

```bash
# Descargar el Dockerfile
mkdir -p ~/hpoexplorer
cd ~/hpoexplorer
wget https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master/Dockerfile

# Construir la imagen
docker build -t hpoexplorer:latest .
```

### Paso 2: Ejecutar el contenedor

```bash
docker run -d \
  --name hpoexplorer-rstudio \
  -e ROOT=true \
  -e PASSWORD="tu_contraseña_segura" \
  -p 8900:8787 \
  -v ~/hpoexplorer/data:/home/rstudio/data \
  -v ~/hpoexplorer/projects:/home/rstudio/projects \
  --restart unless-stopped \
  hpoexplorer:latest
```

## Método 3: Usar la imagen pre-construida (si está disponible)

Si hay una imagen pre-construida disponible para ARM64:

```bash
# Descargar la imagen
docker pull ghcr.io/neurogenomics/hpoexplorer:latest

# Ejecutar el contenedor
docker run -d \
  --name hpoexplorer-rstudio \
  -e ROOT=true \
  -e PASSWORD="tu_contraseña_segura" \
  -p 8900:8787 \
  -v ~/data:/home/rstudio/data \
  --restart unless-stopped \
  ghcr.io/neurogenomics/hpoexplorer:latest
```

## Gestión del Contenedor

### Comandos útiles

```bash
# Ver contenedores en ejecución
docker ps

# Ver logs del contenedor
docker logs hpoexplorer-rstudio

# Detener el contenedor
docker compose down
# o
docker stop hpoexplorer-rstudio

# Reiniciar el contenedor
docker compose restart
# o
docker restart hpoexplorer-rstudio

# Eliminar el contenedor
docker compose down
docker rm hpoexplorer-rstudio

# Eliminar la imagen
docker rmi hpoexplorer:latest
```

### Actualizar HPOExplorer

Para actualizar a la última versión:

```bash
# Detener y eliminar el contenedor actual
docker compose down

# Reconstruir la imagen
docker compose build --no-cache

# Iniciar el nuevo contenedor
docker compose up -d
```

## Optimizaciones para Raspberry Pi 5

### 1. Aumentar el espacio de swap

Si tienes problemas de memoria durante la construcción:

```bash
# Aumentar swap a 2GB
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Cambiar CONF_SWAPSIZE=100 a CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### 2. Usar una unidad SSD USB

Para mejor rendimiento, considera usar una SSD externa conectada por USB 3.0:

```bash
# Montar el SSD
sudo mkdir /mnt/ssd
sudo mount /dev/sda1 /mnt/ssd

# Usar el SSD para Docker
sudo systemctl stop docker
sudo mv /var/lib/docker /mnt/ssd/docker
sudo ln -s /mnt/ssd/docker /var/lib/docker
sudo systemctl start docker
```

### 3. Limitar recursos del contenedor

El archivo `docker-compose.yml` incluye límites de memoria apropiados para RPi 5. Ajústalos según tu modelo:

- RPi 5 con 4GB RAM: límite de 2-3GB
- RPi 5 con 8GB RAM: límite de 4-6GB

## Solución de Problemas

### El contenedor no inicia

```bash
# Ver los logs detallados
docker logs hpoexplorer-rstudio

# Verificar que el puerto no esté en uso
sudo lsof -i :8900
```

### Error de memoria durante la construcción

- Aumenta el espacio de swap (ver arriba)
- Cierra otras aplicaciones
- Considera construir la imagen en una máquina más potente y transferirla

### No puedo acceder a RStudio

1. Verifica que el contenedor esté ejecutándose: `docker ps`
2. Verifica el firewall: `sudo ufw status`
3. Asegúrate de usar la IP correcta de tu RPi 5
4. Prueba con `http://localhost:8900` desde la propia RPi

### Rendimiento lento

1. Usa una tarjeta microSD de clase A2 o superior
2. Considera usar un SSD USB 3.0
3. Aumenta el espacio de swap
4. Limita los recursos del contenedor en docker-compose.yml

## Persistencia de Datos

Los directorios montados en el contenedor permiten persistir:
- `/home/rstudio/data`: Para tus datos de análisis
- `/home/rstudio/projects`: Para tus proyectos de R

Estos datos permanecerán incluso si eliminas y recreas el contenedor.

## Seguridad

**Importante:** 
- Cambia la contraseña por defecto en `docker-compose.yml`
- Si expones el puerto a Internet, usa un proxy inverso con HTTPS (nginx, Caddy)
- Considera usar Docker secrets para credenciales sensibles
- Mantén tu sistema y Docker actualizados

## Soporte

Para problemas específicos de HPOExplorer, visita:
- [Issues de GitHub](https://github.com/neurogenomics/HPOExplorer/issues)
- [Documentación oficial](https://neurogenomics.github.io/HPOExplorer/)

Para problemas específicos de Docker en Raspberry Pi:
- [Docker en Raspberry Pi](https://docs.docker.com/engine/install/raspberry-pi-os/)
- [Foros de Raspberry Pi](https://forums.raspberrypi.com/)
