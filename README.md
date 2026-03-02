# 🚀 Sistema de Gestión de Inventario

**Aplicación ASP.NET Core 8.0 MVC con arquitectura de capas para gestión de movimientos de inventario**

## 📋 Descripción

Sistema profesional de gestión de inventario que permite realizar operaciones CRUD completas:
- ✅ **Consultar (READ)** - Ver y buscar movimientos existentes
- ✅ **Crear (CREATE)** - Registrar nuevo movimiento
- ✅ **Actualizar (UPDATE)** - Modificar movimiento existente
- ✅ **Eliminar (DELETE)** - Remover movimiento de la BD

## 🛠️ Requisitos Previos

Antes de ejecutar la aplicación, asegúrate de tener instalado:

| Componente | Versión | Función |
|-----------|---------|---------|
| **.NET SDK** | 8.0 o superior | Compilar y ejecutar la aplicación |
| **SQL Server Express** | Cualquier versión | Base de datos |
| **PowerShell** | 5.1+ | Ejecutar scripts |

### Verificar Instalación

```powershell
# Verificar .NET
dotnet --version

# Verificar SQL Server
sqlcmd -S localhost\SQLEXPRESS -Q "SELECT @@VERSION"
```

## 🚀 Instrucciones de Ejecución

### Opción 1: Ejecución Completa (Recomendado)

```powershell
# 1. Abre PowerShell como Administrador
# 2. Navega a la carpeta del proyecto
cd "C:\Users\User\OneDrive\Desktop\Crud de Inventarios con ASP.NET MVC"

# 3. Ejecuta los scripts SQL (en orden)
sqlcmd -S localhost\SQLEXPRESS -i "Base de Datos\01_Inventario.sql"
sqlcmd -S localhost\SQLEXPRESS -i "Base de Datos\02_MOV_INVENTARIO.sql"
sqlcmd -S localhost\SQLEXPRESS -d inventario -i "Base de Datos\03_CRUD_MOV_INVENTARIO.sql"

# 4. Restaura dependencias NuGet
dotnet restore

# 5. Compila el proyecto
dotnet build

# 6. Ejecuta la aplicación
cd InventarioMVC.Presentation
dotnet run
```

### Opción 2: Ejecución Rápida (Scripts ya ejecutados)

```powershell
# Si los scripts SQL ya fueron ejecutados anteriormente:
cd "C:\Users\User\OneDrive\Desktop\Crud de Inventarios con ASP.NET MVC"
dotnet restore
dotnet build
cd InventarioMVC.Presentation
dotnet run
```

### Opción 3: Compilación y Ejecución Directa

```powershell
cd "C:\Users\User\OneDrive\Desktop\Crud de Inventarios con ASP.NET MVC"
dotnet clean
dotnet build
cd InventarioMVC.Presentation
dotnet run
```

### Opción 4: Ejecución desde Visual Studio 2022

#### Paso 1: Abrir el Proyecto

1. Abre **Visual Studio 2022**
2. Selecciona **File → Open → Project/Solution**
3. Navega a: `C:\Users\User\OneDrive\Desktop\Crud de Inventarios con ASP.NET MVC`
4. Abre el archivo `InventarioMVC.sln`

#### Paso 2: Restaurar Dependencias (Automático)

Una vez abierto el proyecto, Visual Studio restaurará automáticamente los paquetes NuGet:
- Verás un mensaje: **"Show package restore notification"**
- Visual Studio descargará todas las dependencias automáticamente

Si no aparece, usa el Gestor de Paquetes:
- **Tools → NuGet Package Manager → Manage NuGet Packages for Solution**
- Click en **Restore**

#### Paso 3: Configurar Proyecto de Inicio

1. En el **Explorador de Soluciones** (lado izquierdo)
2. Click derecho en el proyecto **InventarioMVC.Presentation**
3. Selecciona **Set as Startup Project**
4. Verás que el proyecto ahora aparece en **negrita**

#### Paso 4: Ejecutar la Aplicación

**Opción A: Usando F5 (Con Depuración)**
```
Presiona: F5
```

**Opción B: Sin Depuración (Más rápido)**
```
Presiona: Ctrl + F5
```

**Opción C: Usando el Botón de Reproducción**
1. En la barra de herramientas, busca el botón de reproducción verde
2. Asegúrate de que **InventarioMVC.Presentation** esté seleccionado en el dropdown
3. Click en el botón de reproducción

#### Paso 5: Esperar a que Cargue

La aplicación abrirá automáticamente en tu navegador en:
```
https://localhost:7227  (HTTPS - Depuración)
```
o
```
http://localhost:5000   (HTTP - Producción)
```

#### Usando Package Manager Console

Si prefieres ejecutar comandos directamente desde Visual Studio:

```powershell
# En Tools → NuGet Package Manager → Package Manager Console

# Restaurar paquetes
dotnet restore

# Compilar la solución
dotnet build

# Ejecutar el proyecto específico
dotnet run --project InventarioMVC.Presentation/InventarioMVC.Presentation.csproj
```

#### Atajos Útiles en Visual Studio

| Atajo | Función |
|-------|---------|
| **F5** | Ejecutar con depuración |
| **Ctrl + F5** | Ejecutar sin depuración |
| **Ctrl + Shift + B** | Compilar toda la solución |
| **Ctrl + K, Ctrl + C** | Comentar código |
| **Ctrl + K, Ctrl + U** | Descomentar código |
| **F7** | Ir a código behind de una vista |

#### Solución de Problemas en Visual Studio

**"El puerto ya está en uso"**
- Cierra la aplicación anterior: `Ctrl + Alt + Delete → Procesos → dotnet.exe`
- O ejecuta en diferente puerto en `appsettings.json`

**"No se puede compilar la solución"**
- **Build → Clean Solution**
- **Build → Rebuild Solution**
- Cierra y reabre Visual Studio

**"Paquetes no se restauraron"**
- **Tools → NuGet Package Manager → Restore NuGet Packages**
- O ejecuta: `dotnet restore` en Package Manager Console

## 🌐 Acceder a la Aplicación

Una vez ejecutada, la aplicación estará disponible en:

```
http://localhost:5000
```

### Credenciales de Prueba

| Rol | Usuario | Contraseña |
|-----|---------|-----------|
| **Administrador** | `admin@empresa.com` | `Admin@123456` |
| **Gerente** | `manager@empresa.com` | `Manager@123456` |
| **Usuario** | `user@empresa.com` | `User@123456` |

## 📊 Operaciones Disponibles

### 1️⃣ Consultar (READ)
- Ver lista completa de movimientos
- Buscar por número de documento
- Filtrar por tipo de movimiento (Entrada, Salida, Traslado)
- Paginación de resultados

### 2️⃣ Crear (CREATE)
- Registrar nuevo movimiento
- Validación automática de datos
- Mensajes de confirmación

### 3️⃣ Actualizar (UPDATE)
- Editar movimiento existente
- Cambiar cantidad, fechas y referencias
- Confirmación antes de guardar

### 4️⃣ Eliminar (DELETE)
- Remover movimiento de la BD
- Confirmación de eliminación
- Historial en logs

## 🏗️ Estructura del Proyecto

```
Crud de Inventarios con ASP.NET MVC/
│
├── 📁 InventarioMVC.Domain/          # Entidades y contratos
├── 📁 InventarioMVC.Application/     # Servicios y lógica de negocio
├── 📁 InventarioMVC.Infrastructure/  # Acceso a datos (Repositories)
├── 📁 InventarioMVC.Presentation/    # Controladores y Vistas
├── 📁 InventarioMVC.Common/          # Utilidades compartidas
├── 📁 Base de Datos/                 # Scripts SQL
│   ├── 01_Inventario.sql
│   ├── 02_MOV_INVENTARIO.sql
│   └── 03_CRUD_MOV_INVENTARIO.sql
├── README.md                         # Este archivo
└── ...
```

## 🔧 Tecnologías Utilizadas

- **Framework**: ASP.NET Core 8.0 MVC
- **Lenguaje**: C# (.NET 8.0)
- **ORM**: Entity Framework Core 8.0
- **Base de Datos**: SQL Server Express
- **Validación**: FluentValidation 11.8.0
- **Logging**: Serilog 8.0.0
- **Frontend**: Razor Views con Bootstrap 5.3.0

## 📝 Características

✅ Arquitectura de capas (5 capas)  
✅ Patrones de diseño (Repository, Unit of Work, Service Layer, DTO, Mapper)  
✅ Principios SOLID implementados  
✅ Validación robusta con FluentValidation  
✅ Logging estructurado con Serilog  
✅ Interfaz profesional con Bootstrap 5  
✅ Protección contra SQL Injection  
✅ Autenticación y autorización basada en roles  
✅ Paginación y búsqueda avanzada  

## ❌ Solución de Problemas

### "El puerto 5000 ya está en uso"
```powershell
# Ver qué está usando el puerto
Get-NetTCPConnection -LocalPort 5000

# Detener el proceso (si es necesario)
Stop-Process -Name "dotnet" -Force

# Ejecutar en Puerto diferente
dotnet run --urls "http://localhost:5001"
```

### "No se puede conectar a la BD"
```powershell
# Verificar que SQL Server está ejecutándose
Get-Service -Name "MSSQLSERVER" | Start-Service

# Verificar que la BD existe
sqlcmd -S localhost\SQLEXPRESS -Q "SELECT name FROM sys.databases WHERE name='inventario'"
```

### "Archivo en uso - No se puede compilar"
```powershell
# Detener todos los procesos dotnet
Stop-Process -Name "dotnet" -Force

# Limpiar y recompilar
dotnet clean
dotnet build
```

## 📚 Archivos Importantes

- **[Program.cs](InventarioMVC.Presentation/Program.cs)** - Configuración de la aplicación
- **[appsettings.json](InventarioMVC.Presentation/appsettings.json)** - Configuración de BD y logging
- **[MovInventarioController.cs](InventarioMVC.Presentation/Controllers/MovInventarioController.cs)** - Controlador principal
- **[Index.cshtml](InventarioMVC.Presentation/Views/MovInventario/Index.cshtml)** - Vista principal

## 🔐 Seguridad

- ✅ Validación en cliente y servidor
- ✅ Protección CSRF en formularios
- ✅ Consultas parametrizadas (sin SQL Injection)
- ✅ Manejo seguro de excepciones
- ✅ Logging de operaciones

## 📞 Contacto y Soporte

**Versión:** 1.0.0  
**Fecha:** 1 de marzo de 2026  
**Empresa:** Sistema de Gestión de Inventario

---

© 2026 Sistema de Gestión de Inventario
