-- ================================================================================
-- STORE PROCEDURES: CRUD OPERATIONS PARA MOV_INVENTARIO (CONSOLIDADO)
-- ================================================================================
-- Descripción: Conjunto COMPLETO de operaciones CRUD para gestionar movimientos
-- Última actualización: 01/03/2026
-- ================================================================================

USE [inventario];
GO

SET NOCOUNT ON;
GO

-- ================================================================================
-- 1. DROP PROCEDURE IF EXISTS - LIMPIA PROCEDIMIENTOS ANTERIORES
-- ================================================================================
DROP PROCEDURE IF EXISTS dbo.sp_ConsultarMov_Inventario;
DROP PROCEDURE IF EXISTS dbo.sp_InsertarMovimiento;
DROP PROCEDURE IF EXISTS dbo.sp_ActualizarMovimiento;
DROP PROCEDURE IF EXISTS dbo.sp_EliminarMovimiento;
GO

-- ================================================================================
-- 2. STORE PROCEDURE: CONSULTAR MOVIMIENTOS
-- ================================================================================
-- Parámetros opcionales: @FechaInicio, @FechaFin, @TipoMovimiento, @NroDocumento
-- Ejemplo: EXEC sp_ConsultarMov_Inventario @TipoMovimiento = 'EN', @FechaInicio = '20260201'
-- ================================================================================

CREATE PROCEDURE dbo.sp_ConsultarMov_Inventario
    @FechaInicio VARCHAR(8) = NULL,
    @FechaFin VARCHAR(8) = NULL,
    @TipoMovimiento VARCHAR(2) = NULL,
    @NroDocumento VARCHAR(50) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FechaInicioDate DATE = NULL;
    DECLARE @FechaFinDate DATE = NULL;
    DECLARE @TotalRegistros INT;
    
    BEGIN TRY
        -- Convertir y validar fechas
        IF @FechaInicio IS NOT NULL AND LEN(@FechaInicio) = 8
            SET @FechaInicioDate = CONVERT(DATE, 
                SUBSTRING(@FechaInicio, 1, 4) + '-' + 
                SUBSTRING(@FechaInicio, 5, 2) + '-' + 
                SUBSTRING(@FechaInicio, 7, 2), 120);
        
        IF @FechaFin IS NOT NULL AND LEN(@FechaFin) = 8
            SET @FechaFinDate = CONVERT(DATE, 
                SUBSTRING(@FechaFin, 1, 4) + '-' + 
                SUBSTRING(@FechaFin, 5, 2) + '-' + 
                SUBSTRING(@FechaFin, 7, 2), 120);
        
        -- Validar rango de fechas
        IF @FechaInicioDate IS NOT NULL AND @FechaFinDate IS NOT NULL
            AND @FechaInicioDate > @FechaFinDate
            RAISERROR('FechaInicio no puede ser mayor que FechaFin', 16, 1);
        
        -- Contar total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM dbo.MOV_INVENTARIO
        WHERE 
            (@FechaInicioDate IS NULL OR FECHA_TRANSACCION >= @FechaInicioDate)
            AND (@FechaFinDate IS NULL OR FECHA_TRANSACCION <= @FechaFinDate)
            AND (@TipoMovimiento IS NULL OR TIPO_MOVIMIENTO = @TipoMovimiento)
            AND (@NroDocumento IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumento + '%');
        
        -- Retornar datos con filtros opcionales
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
            PROVEEDOR,
            ALMACEN_DESTINO,
            DOC_REF_1,
            DOC_REF_2,
            DOC_REF_3,
            DOC_REF_4,
            DOC_REF_5
        FROM dbo.MOV_INVENTARIO
        WHERE 
            (@FechaInicioDate IS NULL OR FECHA_TRANSACCION >= @FechaInicioDate)
            AND (@FechaFinDate IS NULL OR FECHA_TRANSACCION <= @FechaFinDate)
            AND (@TipoMovimiento IS NULL OR TIPO_MOVIMIENTO = @TipoMovimiento)
            AND (@NroDocumento IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumento + '%')
        ORDER BY FECHA_TRANSACCION DESC, NRO_DOCUMENTO DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
    END TRY
    BEGIN CATCH
        PRINT 'Error en sp_ConsultarMov_Inventario: ' + ERROR_MESSAGE();
        RETURN 1;
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN 0;
END
GO

-- ================================================================================
-- 3. STORE PROCEDURE: INSERTAR MOVIMIENTO
-- ================================================================================
-- Parámetros obligatorios: @COD_CIA, @COMPANIA_VENTA_3, @ALMACEN_VENTA, etc.
-- Ejemplo: EXEC sp_InsertarMovimiento @COD_CIA='01', @TipoMovimiento='EN', ...
-- ================================================================================

CREATE PROCEDURE dbo.sp_InsertarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NRO_DOCUMENTO VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50),
    @CANTIDAD NUMERIC(18,2),
    @FECHA_TRANSACCION DATE = NULL,
    @PROVEEDOR VARCHAR(100) = NULL,
    @ALMACEN_DESTINO VARCHAR(50) = NULL,
    @DOC_REF_1 VARCHAR(50) = NULL,
    @DOC_REF_2 VARCHAR(50) = NULL,
    @DOC_REF_3 VARCHAR(50) = NULL,
    @DOC_REF_4 VARCHAR(50) = NULL,
    @DOC_REF_5 VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('COD_CIA es obligatorio', 16, 1);
        
        IF @CANTIDAD IS NULL OR @CANTIDAD < 0
            RAISERROR('CANTIDAD debe ser >= 0', 16, 1);
        
        -- Asignar fecha actual si no se proporciona
        IF @FECHA_TRANSACCION IS NULL
            SET @FECHA_TRANSACCION = CAST(GETDATE() AS DATE);
        
        -- Validar que no exista duplicado
        IF EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NRO_DOCUMENTO
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('Este movimiento ya existe (duplicado)', 16, 1);
        END
        
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
            @TIPO_MOVIMIENTO, @TIPO_DOCUMENTO, @NRO_DOCUMENTO,
            @COD_ITEM_2, @PROVEEDOR, @ALMACEN_DESTINO,
            @CANTIDAD, @DOC_REF_1, @DOC_REF_2, @DOC_REF_3, @DOC_REF_4, @DOC_REF_5,
            @FECHA_TRANSACCION
        );
        
        PRINT 'Movimiento insertado: ' + @NRO_DOCUMENTO;
        
    END TRY
    BEGIN CATCH
        PRINT 'Error en sp_InsertarMovimiento: ' + ERROR_MESSAGE();
        RETURN 1;
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN 0;
END
GO

-- ================================================================================
-- 4. STORE PROCEDURE: ACTUALIZAR MOVIMIENTO
-- ================================================================================
-- Parámetros: Identificadores únicos + datos a actualizar
-- Ejemplo: EXEC sp_ActualizarMovimiento @COD_CIA='01', ..., @CANTIDAD=100
-- ================================================================================

CREATE PROCEDURE dbo.sp_ActualizarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NRO_DOCUMENTO VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50),
    @CANTIDAD NUMERIC(18,2),
    @FECHA_TRANSACCION DATE = NULL,
    @PROVEEDOR VARCHAR(100) = NULL,
    @ALMACEN_DESTINO VARCHAR(50) = NULL,
    @DOC_REF_1 VARCHAR(50) = NULL,
    @DOC_REF_2 VARCHAR(50) = NULL,
    @DOC_REF_3 VARCHAR(50) = NULL,
    @DOC_REF_4 VARCHAR(50) = NULL,
    @DOC_REF_5 VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('COD_CIA es obligatorio', 16, 1);
        
        IF @CANTIDAD IS NULL OR @CANTIDAD < 0
            RAISERROR('CANTIDAD debe ser >= 0', 16, 1);
        
        -- Verificar que el registro existe
        IF NOT EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NRO_DOCUMENTO
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('El registro a actualizar no existe', 16, 1);
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
            AND NRO_DOCUMENTO = @NRO_DOCUMENTO
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        PRINT 'Movimiento actualizado: ' + @NRO_DOCUMENTO;
        
    END TRY
    BEGIN CATCH
        PRINT 'Error en sp_ActualizarMovimiento: ' + ERROR_MESSAGE();
        RETURN 1;
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN 0;
END
GO

-- ================================================================================
-- 5. STORE PROCEDURE: ELIMINAR MOVIMIENTO
-- ================================================================================
-- Parámetros: Identificadores únicos del movimiento a eliminar
-- Ejemplo: EXEC sp_EliminarMovimiento @COD_CIA='01', @NRO_DOCUMENTO='FAC-001', ...
-- ================================================================================

CREATE PROCEDURE dbo.sp_EliminarMovimiento
    @COD_CIA VARCHAR(5),
    @COMPANIA_VENTA_3 VARCHAR(5),
    @ALMACEN_VENTA VARCHAR(10),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(2),
    @NRO_DOCUMENTO VARCHAR(50),
    @COD_ITEM_2 VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar parámetros obligatorios
        IF @COD_CIA IS NULL OR LTRIM(RTRIM(@COD_CIA)) = ''
            RAISERROR('COD_CIA es obligatorio', 16, 1);
        
        IF @NRO_DOCUMENTO IS NULL OR LTRIM(RTRIM(@NRO_DOCUMENTO)) = ''
            RAISERROR('NRO_DOCUMENTO es obligatorio', 16, 1);
        
        -- Verificar que el registro existe
        IF NOT EXISTS (
            SELECT 1 FROM dbo.MOV_INVENTARIO
            WHERE COD_CIA = @COD_CIA
              AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
              AND ALMACEN_VENTA = @ALMACEN_VENTA
              AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
              AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
              AND NRO_DOCUMENTO = @NRO_DOCUMENTO
              AND COD_ITEM_2 = @COD_ITEM_2
        )
        BEGIN
            RAISERROR('El registro a eliminar no existe', 16, 1);
        END
        
        -- Eliminar el registro
        DELETE FROM dbo.MOV_INVENTARIO
        WHERE
            COD_CIA = @COD_CIA
            AND COMPANIA_VENTA_3 = @COMPANIA_VENTA_3
            AND ALMACEN_VENTA = @ALMACEN_VENTA
            AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
            AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
            AND NRO_DOCUMENTO = @NRO_DOCUMENTO
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        PRINT 'Movimiento eliminado: ' + @NRO_DOCUMENTO;
        
    END TRY
    BEGIN CATCH
        PRINT 'Error en sp_EliminarMovimiento: ' + ERROR_MESSAGE();
        RETURN 1;
    END CATCH;
    
    SET NOCOUNT OFF;
    RETURN 0;
END
GO

SET NOCOUNT OFF;
