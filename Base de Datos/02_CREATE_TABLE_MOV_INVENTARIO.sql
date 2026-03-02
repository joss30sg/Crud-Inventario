-- ================================================================================
-- BASE DE DATOS: INVENTARIO
-- Descripción: Script de creación de base de datos para sistema de inventarios
-- Versión: 1.0
-- Fecha de creación: 28/02/2026
-- Autor: Sistema de Gestión de Inventarios
-- ================================================================================
-- NOTAS DE MANTENIMIENTO:
-- - Este script es idempotente: puede ejecutarse varias veces sin problemas
-- - Advertencia: Se eliminará la BD anterior si existe
-- - Requisitos: SQL Server Express o superior
-- - Servidor recomendado: SQL Server 2019 o posterior
-- ================================================================================

USE [master];
GO

SET NOCOUNT ON;
GO

-- Verificar si la base de datos ya existe y eliminarla si es necesario
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'inventario')
BEGIN
    PRINT 'ADVERTENCIA: La base de datos "inventario" ya existe.'
    PRINT 'Se procedera a eliminar la base de datos existente...'
    
    ALTER DATABASE [inventario] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [inventario];
    
    PRINT 'Base de datos anterior eliminada exitosamente.'
    PRINT ''
END
GO

-- Crear la base de datos
PRINT '=== Iniciando creacion de Base de Datos ==='
PRINT 'Servidor: ' + @@SERVERNAME
PRINT 'Fecha: ' + CONVERT(VARCHAR(10), GETDATE(), 103)
PRINT 'Creando base de datos "inventario"...'
PRINT ''
GO

CREATE DATABASE [inventario]
CONTAINMENT = NONE
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

-- Configurar opciones de la base de datos
ALTER DATABASE [inventario] SET RECOVERY FULL;
ALTER DATABASE [inventario] SET AUTO_CLOSE OFF;
ALTER DATABASE [inventario] SET AUTO_SHRINK OFF;
GO

PRINT ''
PRINT '=== EXITO ==='
PRINT 'Base de datos "inventario" creada exitosamente.'
PRINT 'Estado: ONLINE'
PRINT 'Collation: SQL_Latin1_General_CP1_CI_AS'
PRINT 'Recovery Mode: FULL'
PRINT ''
GO

-- ================================================================================
-- CREACIÓN DE TABLAS
-- ================================================================================

USE [inventario];
GO

PRINT ''
PRINT '=== Creando tablas de la base de datos ==='
PRINT ''

-- Tabla: MOV_INVENTARIO
-- Descripción: Almacena los movimientos de inventario (entradas, salidas, traslados)
-- Clave Primaria: Compuesta por COD_CIA, COMPANIA_VENTA_3, ALMACEN_VENTA, 
--                 TIPO_MOVIMIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, COD_ITEM_2
PRINT 'Creando tabla MOV_INVENTARIO...'

CREATE TABLE dbo.MOV_INVENTARIO(
    COD_CIA varchar(5) NOT NULL,
    COMPANIA_VENTA_3 varchar(5) NOT NULL,
    ALMACEN_VENTA varchar(10) NOT NULL,
    TIPO_MOVIMIENTO varchar(2) NOT NULL,
    TIPO_DOCUMENTO varchar(2) NOT NULL,
    NRO_DOCUMENTO varchar(50) NOT NULL,
    COD_ITEM_2 varchar(50) NOT NULL,
    PROVEEDOR varchar(100) NULL,
    ALMACEN_DESTINO varchar(50) NULL,
    CANTIDAD int NULL,
    DOC_REF_1 varchar(50) NULL,
    DOC_REF_2 varchar(50) NULL,
    DOC_REF_3 varchar(50) NULL,
    DOC_REF_4 varchar(50) NULL,
    DOC_REF_5 varchar(50) NULL,
    FECHA_TRANSACCION DATE NULL,
    CONSTRAINT PK_MOV_INVENTARIO PRIMARY KEY CLUSTERED
    (
        COD_CIA ASC,
        COMPANIA_VENTA_3 ASC,
        ALMACEN_VENTA ASC,
        TIPO_MOVIMIENTO ASC,
        TIPO_DOCUMENTO ASC,
        NRO_DOCUMENTO ASC,
        COD_ITEM_2 ASC
    ) ON [PRIMARY]
);

GO

-- Crear índices adicionales para optimizar búsquedas frecuentes
PRINT 'Creando índices adicionales...'

-- Índice para búsquedas por fecha
CREATE NONCLUSTERED INDEX [IX_MOV_INVENTARIO_FECHA]
    ON dbo.MOV_INVENTARIO (FECHA_TRANSACCION DESC)
    INCLUDE (COD_CIA, COD_ITEM_2, CANTIDAD)
    WHERE FECHA_TRANSACCION IS NOT NULL;

-- Índice para búsquedas por item
CREATE NONCLUSTERED INDEX [IX_MOV_INVENTARIO_ITEM]
    ON dbo.MOV_INVENTARIO (COD_ITEM_2)
    INCLUDE (CANTIDAD, TIPO_MOVIMIENTO);

-- Índice para búsquedas por almacén
CREATE NONCLUSTERED INDEX [IX_MOV_INVENTARIO_ALMACEN]
    ON dbo.MOV_INVENTARIO (ALMACEN_VENTA)
    INCLUDE (TIPO_MOVIMIENTO, COD_ITEM_2);

GO

PRINT 'Tabla MOV_INVENTARIO creada exitosamente.'
PRINT ''
PRINT '=== Proceso completado ==='
PRINT ''

GO

-- ================================================================================
-- DICCIONARIO DE DATOS - MOV_INVENTARIO
-- ================================================================================
-- Explicación de abreviaturas y campos:
-- 
-- COD_CIA           = Código de Compañía (ej: '00001')
-- COMPANIA_VENTA_3  = Compañía de Venta (tercer dígito de identificación)
-- ALMACEN_VENTA     = Almacén de origen del movimiento
-- TIPO_MOVIMIENTO   = EN (Entrada), SA (Salida), TR (Traslado), etc.
-- TIPO_DOCUMENTO    = Tipo doc: 01 (Factura), 02 (Nota Crédito), 03 (Remisión), etc.
-- NRO_DOCUMENTO     = Número secuencial del documento
-- COD_ITEM_2        = Código del producto/item (segunda codificación)
-- PROVEEDOR         = Nombre del proveedor (para entradas)
-- ALMACEN_DESTINO   = Almacén de destino (solo para traslados)
-- CANTIDAD          = Cantidad de unidades movidas
-- DOC_REF_1 a 5     = Referencias cruzadas a otros documentos relacionados
-- FECHA_TRANSACCION = Fecha en que se registró el movimiento
-- ================================================================================

-- Validación de tabla creada
PRINT ''
PRINT '=== VALIDACIÓN DE ESTRUCTURA ==='
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MOV_INVENTARIO')
BEGIN
    PRINT '✓ Tabla MOV_INVENTARIO creada correctamente'
    PRINT '✓ Columnas: ' + CAST((SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MOV_INVENTARIO') AS VARCHAR(5))
END
GO

-- ================================================================================
-- VISTA AUXILIAR PARA VALIDACIONES
-- ================================================================================
-- Esta vista facilita consultas comunes y mantenimiento
CREATE VIEW dbo.VW_MOV_INVENTARIO_INFO AS
SELECT 
    COD_CIA,
    COMPANIA_VENTA_3,
    ALMACEN_VENTA,
    TIPO_MOVIMIENTO,
    TIPO_DOCUMENTO,
    NRO_DOCUMENTO,
    COD_ITEM_2,
    CANTIDAD,
    FECHA_TRANSACCION,
    CASE 
        WHEN TIPO_MOVIMIENTO = 'EN' THEN 'ENTRADA'
        WHEN TIPO_MOVIMIENTO = 'SA' THEN 'SALIDA'
        WHEN TIPO_MOVIMIENTO = 'TR' THEN 'TRASLADO'
        ELSE 'OTRO'
    END AS TIPO_MOV_DESC
FROM dbo.MOV_INVENTARIO;
GO

PRINT '✓ Vista VW_MOV_INVENTARIO_INFO creada'

GO

-- ================================================================================
-- PROCEDIMIENTO PARA VERIFICAR INTEGRIDAD
-- ================================================================================
CREATE PROCEDURE dbo.sp_VerificarIntegridad
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT ''
    PRINT '=== VERIFICACIÓN DE INTEGRIDAD DE DATOS ==='
    PRINT ''
    
    -- Registros sin CANTIDAD
    IF EXISTS (SELECT 1 FROM dbo.MOV_INVENTARIO WHERE CANTIDAD IS NULL)
    BEGIN
        PRINT '⚠ ADVERTENCIA: Existen registros con CANTIDAD NULL'
        SELECT COUNT(*) as 'Registros con CANTIDAD NULL' FROM dbo.MOV_INVENTARIO WHERE CANTIDAD IS NULL
    END
    
    -- Registros sin FECHA_TRANSACCION
    IF EXISTS (SELECT 1 FROM dbo.MOV_INVENTARIO WHERE FECHA_TRANSACCION IS NULL)
    BEGIN
        PRINT '⚠ ADVERTENCIA: Existen registros sin FECHA_TRANSACCION'
        SELECT COUNT(*) as 'Registros sin FECHA_TRANSACCION' FROM dbo.MOV_INVENTARIO WHERE FECHA_TRANSACCION IS NULL
    END
    
    PRINT ''
    PRINT 'Total de registros en MOV_INVENTARIO: ' + CAST((SELECT COUNT(*) FROM dbo.MOV_INVENTARIO) AS VARCHAR(10))
    PRINT 'Verificación completada.'
END
GO

PRINT '✓ Procedimiento sp_VerificarIntegridad creado'
PRINT ''
PRINT '=== INFORMACIÓN ÚTIL PARA MANTENIMIENTO ==='
PRINT ''
PRINT 'Comandos útiles:'
PRINT '  - EXEC dbo.sp_VerificarIntegridad;  -- Verificar integridad de datos'
PRINT '  - SELECT * FROM dbo.VW_MOV_INVENTARIO_INFO;  -- Ver datos con descripción'
PRINT '  - EXEC dbo.sp_ConsultarMovimientos;  -- Consultar todos los movimientos'
PRINT ''
PRINT '=== ÍNDICES CREADOS ==='
PRINT '  - IX_MOV_INVENTARIO_FECHA   (Búsquedas por fecha)'
PRINT '  - IX_MOV_INVENTARIO_ITEM    (Búsquedas por producto)'
PRINT '  - IX_MOV_INVENTARIO_ALMACEN (Búsquedas por almacén)'
PRINT ''
PRINT '=== STORED PROCEDURES DISPONIBLES ==='
PRINT '  - sp_ConsultarMovimientos   (CONSULTA) Leer datos con filtros opcionales'
PRINT '  - sp_InsertarMovimiento     (INSERCIÓN) Agregar nuevos movimientos'
PRINT '  - sp_ActualizarMovimiento   (ACTUALIZACIÓN) Modificar movimientos existentes'
PRINT '  - sp_EliminarMovimiento     (ELIMINACIÓN) Borrar movimientos'
PRINT ''

GO

-- ================================================================================
-- STORE PROCEDURE: CONSULTAR MOVIMIENTOS
-- ================================================================================
-- Descripción: Permite consultar registros de MOV_INVENTARIO con filtros opcionales
-- Parámetros:
--   @FechaInicio        = Fecha de inicio (YYYYMMDD) - Opcional
--   @FechaFin           = Fecha de fin (YYYYMMDD) - Opcional
--   @TipoMovimiento     = Tipo de movimiento (EN, SA, TR, etc.) - Opcional
--   @NroDocumento       = Número de documento - Opcional
-- 
-- Ejemplos de uso:
--   EXEC dbo.sp_ConsultarMovimientos;
--   EXEC dbo.sp_ConsultarMovimientos @FechaInicio = '20260101'
--   EXEC dbo.sp_ConsultarMovimientos @TipoMovimiento = 'EN', @FechaFin = '20260228'
--   EXEC dbo.sp_ConsultarMovimientos @NroDocumento = 'FAC-001'
-- ================================================================================

CREATE PROCEDURE dbo.sp_ConsultarMovimientos
    @FechaInicio VARCHAR(8) = NULL,           -- Formato: YYYYMMDD (ej: 20260101)
    @FechaFin VARCHAR(8) = NULL,              -- Formato: YYYYMMDD (ej: 20260228)
    @TipoMovimiento VARCHAR(2) = NULL,        -- EN, SA, TR (se valida contra BD)
    @NroDocumento VARCHAR(50) = NULL,         -- Búsqueda parcial (LIKE)
    @PageNumber INT = 1,                      -- Página de resultados (default: 1)
    @PageSize INT = 100,                      -- Registros por página (default: 100, máx: 1000)
    @ReturnCode INT = 0 OUTPUT                -- Código de retorno (0=Éxito, 1=Error)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ================================================================
    -- DECLARACIÓN DE VARIABLES LOCALES
    -- ================================================================
    DECLARE @FechaInicioDate DATE;
    DECLARE @FechaFinDate DATE;
    DECLARE @TipoMovimientoLimpio VARCHAR(2);
    DECLARE @NroDocumentoLimpio VARCHAR(50);
    DECLARE @TotalRegistros INT = 0;
    DECLARE @TotalPaginas INT = 0;
    DECLARE @RegistroInicio INT = 0;
    DECLARE @RegistroFin INT = 0;
    DECLARE @ErrorMsg VARCHAR(500) = '';
    DECLARE @ExecutionStartTime DATETIME2 = GETDATE();
    
    -- ================================================================
    -- INICIALIZAR CÓDIGO DE RETORNO
    -- ================================================================
    SET @ReturnCode = 0;
    
    BEGIN TRY
        -- ================================================================
        -- FASE 1: LIMPIEZA Y VALIDACIÓN DE PARÁMETROS
        -- ================================================================
        
        -- Limpiar parámetros de entrada (LTRIM, RTRIM)
        SET @TipoMovimientoLimpio = LTRIM(RTRIM(ISNULL(@TipoMovimiento, '')));
        SET @NroDocumentoLimpio = LTRIM(RTRIM(ISNULL(@NroDocumento, '')));
        
        -- Si está vacío, convertir a NULL
        SET @TipoMovimientoLimpio = CASE WHEN @TipoMovimientoLimpio = '' THEN NULL ELSE @TipoMovimientoLimpio END;
        SET @NroDocumentoLimpio = CASE WHEN @NroDocumentoLimpio = '' THEN NULL ELSE @NroDocumentoLimpio END;
        
        -- Convertir FechaInicio a DATE
        IF @FechaInicio IS NOT NULL AND LEN(@FechaInicio) = 8
        BEGIN
            SET @FechaInicioDate = TRY_CONVERT(DATE, 
                SUBSTRING(@FechaInicio, 1, 4) + '-' + 
                SUBSTRING(@FechaInicio, 5, 2) + '-' + 
                SUBSTRING(@FechaInicio, 7, 2), 120);
            
            IF @FechaInicioDate IS NULL
            BEGIN
                SET @ErrorMsg = 'ERROR: FechaInicio con formato inválido. Esperado: YYYYMMDD (ej: 20260101)';
                RAISERROR(@ErrorMsg, 16, 1);
            END
        END
        
        -- Convertir FechaFin a DATE
        IF @FechaFin IS NOT NULL AND LEN(@FechaFin) = 8
        BEGIN
            SET @FechaFinDate = TRY_CONVERT(DATE, 
                SUBSTRING(@FechaFin, 1, 4) + '-' + 
                SUBSTRING(@FechaFin, 5, 2) + '-' + 
                SUBSTRING(@FechaFin, 7, 2), 120);
            
            IF @FechaFinDate IS NULL
            BEGIN
                SET @ErrorMsg = 'ERROR: FechaFin con formato inválido. Esperado: YYYYMMDD (ej: 20260228)';
                RAISERROR(@ErrorMsg, 16, 1);
            END
        END
        
        -- Validación: FechaInicio no puede ser MAYOR que FechaFin
        IF @FechaInicioDate IS NOT NULL AND @FechaFinDate IS NOT NULL
        BEGIN
            IF @FechaInicioDate > @FechaFinDate
            BEGIN
                SET @ErrorMsg = 'ERROR: FechaInicio (' + CONVERT(VARCHAR(10), @FechaInicioDate, 103) + 
                                ') no puede ser mayor que FechaFin (' + CONVERT(VARCHAR(10), @FechaFinDate, 103) + ')';
                RAISERROR(@ErrorMsg, 16, 1);
            END
        END
        
        -- Validación: TipoMovimiento si se proporciona, debe ser válido
        IF @TipoMovimientoLimpio IS NOT NULL
        BEGIN
            IF LEN(@TipoMovimientoLimpio) <> 2
            BEGIN
                SET @ErrorMsg = 'ERROR: TipoMovimiento debe tener 2 caracteres (ej: EN, SA, TR)';
                RAISERROR(@ErrorMsg, 16, 1);
            END
            
            -- Validar que exista en la tabla
            IF NOT EXISTS (SELECT 1 FROM dbo.MOV_INVENTARIO WHERE TIPO_MOVIMIENTO = @TipoMovimientoLimpio)
            BEGIN
                SET @ErrorMsg = 'ADVERTENCIA: TipoMovimiento "' + @TipoMovimientoLimpio + 
                                '" no existe en la base de datos. Se ejecutará la consulta sin este filtro.';
                PRINT @ErrorMsg;
                SET @TipoMovimientoLimpio = NULL;
            END
        END
        
        -- Validación: PageNumber
        IF @PageNumber < 1
        BEGIN
            SET @PageNumber = 1;
            PRINT 'ADVERTENCIA: PageNumber ajustado a 1 (valor mínimo)';
        END
        
        -- Validación: PageSize
        IF @PageSize < 1
        BEGIN
            SET @PageSize = 100;
            PRINT 'ADVERTENCIA: PageSize ajustado a 100 (valor mínimo)';
        END
        ELSE IF @PageSize > 1000
        BEGIN
            SET @PageSize = 1000;
            PRINT 'ADVERTENCIA: PageSize ajustado a 1000 (valor máximo)';
        END
        
        -- ================================================================
        -- FASE 2: MOSTRAR INFORMACIÓN DE EJECUCIÓN
        -- ================================================================
        PRINT '';
        PRINT '=================================================================';
        PRINT '  CONSULTA DE MOVIMIENTOS DE INVENTARIO';
        PRINT '=================================================================';
        PRINT 'Hora de ejecución: ' + CONVERT(VARCHAR(19), @ExecutionStartTime, 121);
        PRINT 'Servidor: ' + @@SERVERNAME;
        PRINT 'Base de datos: ' + DB_NAME();
        PRINT '';
        PRINT '--- FILTROS APLICADOS ---';
        PRINT '  Fecha Inicio:      ' + ISNULL(CONVERT(VARCHAR(10), @FechaInicioDate, 103), '[SIN FILTRO]');
        PRINT '  Fecha Fin:         ' + ISNULL(CONVERT(VARCHAR(10), @FechaFinDate, 103), '[SIN FILTRO]');
        PRINT '  Tipo Movimiento:   ' + ISNULL(@TipoMovimientoLimpio, '[SIN FILTRO]');
        PRINT '  Número Documento:  ' + ISNULL(@NroDocumentoLimpio, '[SIN FILTRO]');
        PRINT '';
        PRINT '--- PAGINACIÓN ---';
        PRINT '  Página:            ' + CAST(@PageNumber AS VARCHAR(5));
        PRINT '  Registros/Página:  ' + CAST(@PageSize AS VARCHAR(5));
        PRINT '';
        
        -- ================================================================
        -- FASE 3: CONTAR REGISTROS QUE COINCIDEN CON FILTROS
        -- ================================================================
        SELECT @TotalRegistros = COUNT(*)
        FROM dbo.MOV_INVENTARIO
        WHERE 
            (@FechaInicioDate IS NULL OR FECHA_TRANSACCION >= @FechaInicioDate)
            AND
            (@FechaFinDate IS NULL OR FECHA_TRANSACCION <= @FechaFinDate)
            AND
            (@TipoMovimientoLimpio IS NULL OR TIPO_MOVIMIENTO = @TipoMovimientoLimpio)
            AND
            (@NroDocumentoLimpio IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumentoLimpio + '%');
        
        -- ================================================================
        -- FASE 4: CALCULAR INFORMACIÓN DE PAGINACIÓN
        -- ================================================================
        SET @TotalPaginas = CASE 
            WHEN @TotalRegistros = 0 THEN 0
            ELSE CEILING(CAST(@TotalRegistros AS FLOAT) / @PageSize)
        END;
        
        SET @RegistroInicio = CASE 
            WHEN @TotalRegistros = 0 THEN 0
            WHEN @PageNumber > @TotalPaginas THEN 0
            ELSE ((@PageNumber - 1) * @PageSize) + 1
        END;
        
        SET @RegistroFin = CASE 
            WHEN @TotalRegistros = 0 THEN 0
            WHEN @PageNumber > @TotalPaginas THEN 0
            WHEN (@PageNumber * @PageSize) > @TotalRegistros THEN @TotalRegistros
            ELSE (@PageNumber * @PageSize)
        END;
        
        -- ================================================================
        -- FASE 5: EJECUTAR CONSULTA CON FILTROS OPCIONALES
        -- ================================================================
        SELECT 
            COD_CIA,
            COMPANIA_VENTA_3,
            ALMACEN_VENTA,
            TIPO_MOVIMIENTO,
            CASE 
                WHEN TIPO_MOVIMIENTO = 'EN' THEN 'ENTRADA'
                WHEN TIPO_MOVIMIENTO = 'SA' THEN 'SALIDA'
                WHEN TIPO_MOVIMIENTO = 'TR' THEN 'TRASLADO'
                ELSE 'OTRO'
            END AS TIPO_MOV_DESC,
            TIPO_DOCUMENTO,
            NRO_DOCUMENTO,
            COD_ITEM_2,
            PROVEEDOR,
            ALMACEN_DESTINO,
            CANTIDAD,
            DOC_REF_1,
            DOC_REF_2,
            DOC_REF_3,
            DOC_REF_4,
            DOC_REF_5,
            FECHA_TRANSACCION
        FROM dbo.MOV_INVENTARIO
        WHERE 
            -- FILTRO 1: Rango de fechas (opcional)
            (@FechaInicioDate IS NULL OR FECHA_TRANSACCION >= @FechaInicioDate)
            AND
            (@FechaFinDate IS NULL OR FECHA_TRANSACCION <= @FechaFinDate)
            AND
            -- FILTRO 2: Tipo de movimiento (opcional)
            (@TipoMovimientoLimpio IS NULL OR TIPO_MOVIMIENTO = @TipoMovimientoLimpio)
            AND
            -- FILTRO 3: Número de documento (búsqueda parcial, opcional)
            (@NroDocumentoLimpio IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumentoLimpio + '%')
        ORDER BY FECHA_TRANSACCION DESC, NRO_DOCUMENTO DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
        -- ================================================================
        -- FASE 6: MOSTRAR INFORMACIÓN DE RESULTADOS
        -- ================================================================
        PRINT '--- RESULTADOS ---';
        PRINT 'Total de registros encontrados: ' + CAST(@TotalRegistros AS VARCHAR(10));
        PRINT 'Total de páginas: ' + CAST(@TotalPaginas AS VARCHAR(10));
        PRINT 'Página actual: ' + CAST(@PageNumber AS VARCHAR(5)) + ' de ' + CAST(CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END AS VARCHAR(5));
        PRINT 'Registros mostrados: ' + CAST(@RegistroInicio AS VARCHAR(10)) + ' a ' + CAST(@RegistroFin AS VARCHAR(10));
        PRINT '';
        PRINT 'Tiempo de ejecución: ' + CAST(DATEDIFF(MILLISECOND, @ExecutionStartTime, GETDATE()) AS VARCHAR(10)) + ' ms';
        PRINT '=================================================================';
        PRINT '';
        
        -- ================================================================
        -- RETORNAR CÓDIGO DE ÉXITO
        -- ================================================================
        SET @ReturnCode = 0;
        
    END TRY
    BEGIN CATCH
        -- ================================================================
        -- MANEJO DE ERRORES
        -- ================================================================
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        
        SET @ReturnCode = 1;
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ERROR EN LA EJECUCIÓN';
        PRINT '=================================================================';
        PRINT 'Número de error: ' + CAST(@ErrorNumber AS VARCHAR(10));
        PRINT 'Severidad: ' + CAST(@ErrorSeverity AS VARCHAR(5));
        PRINT 'Línea: ' + CAST(@ErrorLine AS VARCHAR(10));
        PRINT 'Mensaje: ' + @ErrorMessage;
        PRINT '=================================================================';
        PRINT '';
        
        -- Retornar registros vacíos
        SELECT TOP 0
            COD_CIA,
            COMPANIA_VENTA_3,
            ALMACEN_VENTA,
            TIPO_MOVIMIENTO,
            '' AS TIPO_MOV_DESC,
            TIPO_DOCUMENTO,
            NRO_DOCUMENTO,
            COD_ITEM_2,
            PROVEEDOR,
            ALMACEN_DESTINO,
            CANTIDAD,
            DOC_REF_1,
            DOC_REF_2,
            DOC_REF_3,
            DOC_REF_4,
            DOC_REF_5,
            FECHA_TRANSACCION
        FROM dbo.MOV_INVENTARIO;
        
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN @ReturnCode;
END
GO

PRINT '✓ Procedimiento sp_ConsultarMovimientos creado exitosamente'
PRINT '  - Con manejo robusto de errores'
PRINT '  - Filtros opcionales validados'
PRINT '  - Código de retorno para integración'
PRINT ''

GO

-- ================================================================================
-- STORE PROCEDURE: INSERTAR MOVIMIENTO
-- ================================================================================
-- Descripción: Inserta un nuevo registro de movimiento de inventario
-- Parámetros:
--   @COD_CIA, @COMPANIA_VENTA_3, @ALMACEN_VENTA: Identificadores obligatorios
--   @TIPO_MOVIMIENTO, @TIPO_DOCUMENTO, @NRO_DOCUMENTO, @COD_ITEM_2: Datos obligatorios
--   @CANTIDAD: Cantidad (obligatoria)
--   @FECHA_TRANSACCION: Fecha (si no se proporciona, usa hoy)
--   @PROVEEDOR, @ALMACEN_DESTINO, @DOC_REF_1-5: Datos opcionales
--   @ReturnCode: 0=Éxito, 1=Error
-- ================================================================================

CREATE PROCEDURE dbo.sp_InsertarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NroDocumento VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50),
    @CANTIDAD NUMERIC(18,2),
    @FECHA_TRANSACCION DATE = NULL,
    @PROVEEDOR VARCHAR(100) = NULL,
    @ALMACEN_DESTINO VARCHAR(50) = NULL,
    @DOC_REF_1 VARCHAR(50) = NULL,
    @DOC_REF_2 VARCHAR(50) = NULL,
    @DOC_REF_3 VARCHAR(50) = NULL,
    @DOC_REF_4 VARCHAR(50) = NULL,
    @DOC_REF_5 VARCHAR(50) = NULL,
    @ReturnCode INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg VARCHAR(500) = '';
    DECLARE @ExecutionStartTime DATETIME2 = GETDATE();
    
    SET @ReturnCode = 0;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('ERROR: COD_CIA es obligatorio', 16, 1);
        
        IF @COMPANIA_VENTA_3 IS NULL OR LTRIM(RTRIM(@COMPANIA_VENTA_3)) = ''
            RAISERROR('ERROR: COMPANIA_VENTA_3 es obligatorio', 16, 1);
        
        IF @ALMACEN_VENTA IS NULL OR LTRIM(RTRIM(@ALMACEN_VENTA)) = ''
            RAISERROR('ERROR: ALMACEN_VENTA es obligatorio', 16, 1);
        
        IF @TIPO_MOVIMIENTO IS NULL OR LEN(LTRIM(RTRIM(@TIPO_MOVIMIENTO))) <> 2
            RAISERROR('ERROR: TIPO_MOVIMIENTO es obligatorio (2 caracteres)', 16, 1);
        
        IF @TIPO_DOCUMENTO IS NULL OR LEN(LTRIM(RTRIM(@TIPO_DOCUMENTO))) <> 2
            RAISERROR('ERROR: TIPO_DOCUMENTO es obligatorio (2 caracteres)', 16, 1);
        
        IF @NroDocumento IS NULL OR LTRIM(RTRIM(@NroDocumento)) = ''
            RAISERROR('ERROR: NroDocumento es obligatorio', 16, 1);
        
        IF @COD_ITEM_2 IS NULL OR LTRIM(RTRIM(@COD_ITEM_2)) = ''
            RAISERROR('ERROR: COD_ITEM_2 es obligatorio', 16, 1);
        
        IF @CANTIDAD IS NULL OR @CANTIDAD < 0
            RAISERROR('ERROR: CANTIDAD es obligatoria y debe ser >= 0', 16, 1);
        
        -- Validar que no exista duplicado exacto
        IF EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NroDocumento
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('ERROR: Este movimiento ya existe (duplicado)', 16, 1);
        END
        
        -- Asignar fecha actual si no se proporciona
        IF @FECHA_TRANSACCION IS NULL
            SET @FECHA_TRANSACCION = CAST(GETDATE() AS DATE);
        
        -- Insertar registro
        INSERT INTO dbo.MOV_INVENTARIO
        (
            COD_CIA, COMPANIA_VENTA_3, ALMACEN_VENTA,
            TIPO_MOVIMIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO,
            COD_ITEM_2, PROVEEDOR, ALMACEN_DESTINO,
            CANTIDAD, DOC_REF_1, DOC_REF_2, DOC_REF_3, DOC_REF_4, DOC_REF_5,
            FECHA_TRANSACCION
        )
        VALUES
        (
            @COD_CIA, @COMPANIA_VENTA_3, @ALMACEN_VENTA,
            @TIPO_MOVIMIENTO, @TIPO_DOCUMENTO, @NroDocumento,
            @COD_ITEM_2, @PROVEEDOR, @ALMACEN_DESTINO,
            @CANTIDAD, @DOC_REF_1, @DOC_REF_2, @DOC_REF_3, @DOC_REF_4, @DOC_REF_5,
            @FECHA_TRANSACCION
        );
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  INSERCIÓN DE MOVIMIENTO EXITOSA';
        PRINT '=================================================================';
        PRINT 'Documento: ' + @NroDocumento;
        PRINT 'Tipo Movimiento: ' + @TIPO_MOVIMIENTO;
        PRINT 'Item: ' + @COD_ITEM_2;
        PRINT 'Cantidad: ' + CAST(@CANTIDAD AS VARCHAR(10));
        PRINT 'Fecha: ' + CONVERT(VARCHAR(10), @FECHA_TRANSACCION, 103);
        PRINT 'Tiempo ejecución: ' + CAST(DATEDIFF(MILLISECOND, @ExecutionStartTime, GETDATE()) AS VARCHAR(10)) + ' ms';
        PRINT '=================================================================';
        PRINT '';
        
        SET @ReturnCode = 0;
        
    END TRY
    BEGIN CATCH
        SET @ReturnCode = 1;
        
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ERROR EN LA INSERCIÓN';
        PRINT '=================================================================';
        PRINT 'Error #' + CAST(@ErrorNumber AS VARCHAR(10));
        PRINT 'Mensaje: ' + @ErrorMessage;
        PRINT '=================================================================';
        PRINT '';
        
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN @ReturnCode;
END
GO

-- ================================================================================
-- STORE PROCEDURE: ACTUALIZAR MOVIMIENTO
-- ================================================================================
-- Descripción: Actualiza un registro existente de movimiento
-- Parámetros: Los mismos que inserción más los que identifican el registro a actualizar
-- ================================================================================

CREATE PROCEDURE dbo.sp_ActualizarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NroDocumento VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50),
    @CANTIDAD NUMERIC(18,2),
    @FECHA_TRANSACCION DATE = NULL,
    @PROVEEDOR VARCHAR(100) = NULL,
    @ALMACEN_DESTINO VARCHAR(50) = NULL,
    @DOC_REF_1 VARCHAR(50) = NULL,
    @DOC_REF_2 VARCHAR(50) = NULL,
    @DOC_REF_3 VARCHAR(50) = NULL,
    @DOC_REF_4 VARCHAR(50) = NULL,
    @DOC_REF_5 VARCHAR(50) = NULL,
    @ReturnCode INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg VARCHAR(500) = '';
    DECLARE @ExecutionStartTime DATETIME2 = GETDATE();
    DECLARE @RegistrosActualizados INT;
    
    SET @ReturnCode = 0;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('ERROR: COD_CIA es obligatorio', 16, 1);
        
        IF @CANTIDAD IS NULL OR @CANTIDAD < 0
            RAISERROR('ERROR: CANTIDAD es obligatoria y debe ser >= 0', 16, 1);
        
        -- Verificar que el registro existe
        IF NOT EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NroDocumento
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('ERROR: El registro a actualizar no existe', 16, 1);
        END
        
        -- Actualizar el registro
        UPDATE dbo.MOV_INVENTARIO
        SET
            CANTIDAD = @CANTIDAD,
            PROVEEDOR = ISNULL(@PROVEEDOR, PROVEEDOR),
            ALMACEN_DESTINO = ISNULL(@ALMACEN_DESTINO, ALMACEN_DESTINO),
            DOC_REF_1 = ISNULL(@DOC_REF_1, DOC_REF_1),
            DOC_REF_2 = ISNULL(@DOC_REF_2, DOC_REF_2),
            DOC_REF_3 = ISNULL(@DOC_REF_3, DOC_REF_3),
            DOC_REF_4 = ISNULL(@DOC_REF_4, DOC_REF_4),
            DOC_REF_5 = ISNULL(@DOC_REF_5, DOC_REF_5),
            FECHA_TRANSACCION = ISNULL(@FECHA_TRANSACCION, FECHA_TRANSACCION)
        WHERE
            COD_CIA = @COD_CIA
            AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
            AND ALMACEN_VENTA = @ALMACEN_VENTA
            AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
            AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
            AND NRO_DOCUMENTO = @NroDocumento
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        SET @RegistrosActualizados = @@ROWCOUNT;
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ACTUALIZACIÓN DE MOVIMIENTO EXITOSA';
        PRINT '=================================================================';
        PRINT 'Documento: ' + @NroDocumento;
        PRINT 'Item: ' + @COD_ITEM_2;
        PRINT 'Nueva Cantidad: ' + CAST(@CANTIDAD AS VARCHAR(10));
        PRINT 'Registros actualizados: ' + CAST(@RegistrosActualizados AS VARCHAR(5));
        PRINT 'Tiempo ejecución: ' + CAST(DATEDIFF(MILLISECOND, @ExecutionStartTime, GETDATE()) AS VARCHAR(10)) + ' ms';
        PRINT '=================================================================';
        PRINT '';
        
        SET @ReturnCode = 0;
        
    END TRY
    BEGIN CATCH
        SET @ReturnCode = 1;
        
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ERROR EN LA ACTUALIZACIÓN';
        PRINT '=================================================================';
        PRINT 'Error #' + CAST(@ErrorNumber AS VARCHAR(10));
        PRINT 'Mensaje: ' + @ErrorMessage;
        PRINT '=================================================================';
        PRINT '';
        
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN @ReturnCode;
END
GO

-- ================================================================================
-- STORE PROCEDURE: ELIMINAR MOVIMIENTO
-- ================================================================================
-- Descripción: Elimina un registro de movimiento completamente
-- Parámetros: Los identificadores únicos del movimiento a eliminar
-- ================================================================================

CREATE PROCEDURE dbo.sp_EliminarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NroDocumento VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50),
    @ReturnCode INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg VARCHAR(500) = '';
    DECLARE @ExecutionStartTime DATETIME2 = GETDATE();
    DECLARE @RegistrosEliminados INT;
    
    SET @ReturnCode = 0;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('ERROR: COD_CIA es obligatorio', 16, 1);
        
        IF @NroDocumento IS NULL OR LTRIM(RTRIM(@NroDocumento)) = ''
            RAISERROR('ERROR: NroDocumento es obligatorio', 16, 1);
        
        IF @COD_ITEM_2 IS NULL OR LTRIM(RTRIM(@COD_ITEM_2)) = ''
            RAISERROR('ERROR: COD_ITEM_2 es obligatorio', 16, 1);
        
        -- Verificar que el registro existe
        IF NOT EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NroDocumento
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('ERROR: El registro a eliminar no existe', 16, 1);
        END
        
        -- Eliminar el registro
        DELETE FROM dbo.MOV_INVENTARIO
        WHERE
            COD_CIA = @COD_CIA
            AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
            AND ALMACEN_VENTA = @ALMACEN_VENTA
            AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
            AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
            AND NRO_DOCUMENTO = @NroDocumento
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        SET @RegistrosEliminados = @@ROWCOUNT;
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ELIMINACIÓN DE MOVIMIENTO EXITOSA';
        PRINT '=================================================================';
        PRINT 'Documento: ' + @NroDocumento;
        PRINT 'Item: ' + @COD_ITEM_2;
        PRINT 'Registros eliminados: ' + CAST(@RegistrosEliminados AS VARCHAR(5));
        PRINT 'ADVERTENCIA: El registro ha sido eliminado de la base de datos';
        PRINT 'Tiempo ejecución: ' + CAST(DATEDIFF(MILLISECOND, @ExecutionStartTime, GETDATE()) AS VARCHAR(10)) + ' ms';
        PRINT '=================================================================';
        PRINT '';
        
        SET @ReturnCode = 0;
        
    END TRY
    BEGIN CATCH
        SET @ReturnCode = 1;
        
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        
        PRINT '';
        PRINT '=================================================================';
        PRINT '  ERROR EN LA ELIMINACIÓN';
        PRINT '=================================================================';
        PRINT 'Error #' + CAST(@ErrorNumber AS VARCHAR(10));
        PRINT 'Mensaje: ' + @ErrorMessage;
        PRINT '=================================================================';
        PRINT '';
        
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN @ReturnCode;
END
GO

PRINT '✓ Procedimiento sp_InsertarMovimiento creado exitosamente'
PRINT '✓ Procedimiento sp_ActualizarMovimiento creado exitosamente'
PRINT '✓ Procedimiento sp_EliminarMovimiento creado exitosamente'
PRINT ''

GO

-- ================================================================================
-- SCRIPT DE VALIDACIÓN Y PRUEBAS DEL SP_CONSULTARMOVIMIENTOS
-- ================================================================================
-- Este script valida que el Store Procedure funciona correctamente
-- con todos, algunos o ninguno de los filtros opcionales
-- ================================================================================

PRINT ''
PRINT '==================================================================='
PRINT '  VALIDACIÓN DE STORE PROCEDURE: sp_ConsultarMovimientos'
PRINT '==================================================================='
PRINT ''

-- PRUEBA 1: Sin filtros (debe retornar todos los registros)
PRINT ''
PRINT '--- PRUEBA 1: Ejecución sin filtros ---'
PRINT 'Descripción: Debe retornar TODOS los movimientos'
DECLARE @ReturnCode1 INT;
EXEC dbo.sp_ConsultarMovimientos @ReturnCode = @ReturnCode1 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode1 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 2: Solo FechaInicio
PRINT ''
PRINT '--- PRUEBA 2: Solo con FechaInicio ---'
PRINT 'Descripción: Movimientos desde el 01/02/2026 en adelante'
DECLARE @ReturnCode2 INT;
EXEC dbo.sp_ConsultarMovimientos @FechaInicio = '20260201', @ReturnCode = @ReturnCode2 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode2 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 3: Solo FechaFin
PRINT ''
PRINT '--- PRUEBA 3: Solo con FechaFin ---'
PRINT 'Descripción: Movimientos hasta el 28/02/2026'
DECLARE @ReturnCode3 INT;
EXEC dbo.sp_ConsultarMovimientos @FechaFin = '20260228', @ReturnCode = @ReturnCode3 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode3 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 4: Rango de fechas
PRINT ''
PRINT '--- PRUEBA 4: Con rango de fechas ---'
PRINT 'Descripción: Movimientos entre 01/02 y 28/02/2026'
DECLARE @ReturnCode4 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @FechaInicio = '20260201', 
    @FechaFin = '20260228', 
    @ReturnCode = @ReturnCode4 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode4 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 5: Solo TipoMovimiento
PRINT ''
PRINT '--- PRUEBA 5: Solo con TipoMovimiento ---'
PRINT 'Descripción: Todos los movimientos de tipo ENTRADA (EN)'
DECLARE @ReturnCode5 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @TipoMovimiento = 'EN', 
    @ReturnCode = @ReturnCode5 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode5 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 6: Solo NroDocumento
PRINT ''
PRINT '--- PRUEBA 6: Solo con NroDocumento (búsqueda parcial) ---'
PRINT 'Descripción: Documentos que contengan "FAC"'
DECLARE @ReturnCode6 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @NroDocumento = 'FAC', 
    @ReturnCode = @ReturnCode6 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode6 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 7: Combinación de múltiples filtros
PRINT ''
PRINT '--- PRUEBA 7: Combinación de filtros ---'
PRINT 'Descripción: Entradas (EN) en febrero que contengan "FAC"'
DECLARE @ReturnCode7 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @FechaInicio = '20260201',
    @FechaFin = '20260228',
    @TipoMovimiento = 'EN',
    @NroDocumento = 'FAC',
    @ReturnCode = @ReturnCode7 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode7 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 8: Con paginación
PRINT ''
PRINT '--- PRUEBA 8: Con paginación ---'
PRINT 'Descripción: Primera página con 10 registros'
DECLARE @ReturnCode8 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @PageNumber = 1,
    @PageSize = 10,
    @ReturnCode = @ReturnCode8 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode8 AS VARCHAR(5)) + ' (0=Éxito)';
PRINT ''

-- PRUEBA 9: Validación de error - FechaInicio > FechaFin
PRINT ''
PRINT '--- PRUEBA 9: Validación de error (FechaInicio > FechaFin) ---'
PRINT 'Descripción: Debe fallar porque inicio > fin'
DECLARE @ReturnCode9 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @FechaInicio = '20260228',
    @FechaFin = '20260201',
    @ReturnCode = @ReturnCode9 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode9 AS VARCHAR(5)) + ' (1=Error)';
PRINT ''

-- PRUEBA 10: Validación de error - Formato de fecha inválido
PRINT ''
PRINT '--- PRUEBA 10: Validación de error (Formato inválido) ---'
PRINT 'Descripción: Debe fallar porque fecha no tiene 8 caracteres'
DECLARE @ReturnCode10 INT;
EXEC dbo.sp_ConsultarMovimientos 
    @FechaInicio = '2026-02-01',
    @ReturnCode = @ReturnCode10 OUTPUT;
PRINT 'Código de retorno: ' + CAST(@ReturnCode10 AS VARCHAR(5)) + ' (1=Error o ajustado automáticamente)';
PRINT ''

GO
SET NOCOUNT OFF;
