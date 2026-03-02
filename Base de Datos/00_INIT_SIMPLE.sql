-- ================================================================================
-- SCRIPT SIMPLE DE INICIALIZACIÓN
-- Descripción: Crea la base de datos y la tabla MOV_INVENTARIO con datos de prueba
-- Versión: 1.0 - SIMPLIFICADA
-- ================================================================================

-- Usar base de datos maestra
USE [master];
GO

-- Eliminar base de datos si existe
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'inventario')
BEGIN
    ALTER DATABASE [inventario] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [inventario];
END
GO

-- Crear la base de datos
CREATE DATABASE [inventario];
GO

-- Cambiar a la nueva base de datos
USE [inventario];
GO

-- ================================================================================
-- CREAR TABLA MOV_INVENTARIO
-- ================================================================================
CREATE TABLE [dbo].[MOV_INVENTARIO]
(
    [COD_CIA] NVARCHAR(3) NOT NULL,
    [CIA_VENTA_3] NVARCHAR(50) NOT NULL,
    [ALMACEN_VENTA] NVARCHAR(50) NOT NULL,
    [TIPO_MOVIMIENTO] VARCHAR(2) NOT NULL,
    [TIPO_DOCUMENTO] VARCHAR(5) NOT NULL,
    [NRO_DOCUMENTO] VARCHAR(20) NOT NULL,
    [COD_ITEM_2] VARCHAR(20) NOT NULL,
    [COMPRADOR] NVARCHAR(100),
    [DESCRIPCION] NVARCHAR(MAX),
    [CANTIDAD] DECIMAL(10, 2) NOT NULL,
    [PRECIO_UNITARIO] DECIMAL(10, 2) NOT NULL,
    [PRECIO_VENTA] DECIMAL(10, 2),
    [FECHA_MOVIMIENTO] DATE NOT NULL,
    [USUARIO] NVARCHAR(100) NOT NULL,
    [ESTADO] VARCHAR(1) NOT NULL DEFAULT 'A',
    [FECHA_REGISTRO] DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_MOV_INVENTARIO PRIMARY KEY (COD_CIA, CIA_VENTA_3, ALMACEN_VENTA, TIPO_MOVIMIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, COD_ITEM_2)
);
GO

-- ================================================================================
-- CREAR ÍNDICES
-- ================================================================================
CREATE INDEX [IX_MOV_INVENTARIO_FECHA] ON [dbo].[MOV_INVENTARIO] ([FECHA_MOVIMIENTO]);
CREATE INDEX [IX_MOV_INVENTARIO_TIPO] ON [dbo].[MOV_INVENTARIO] ([TIPO_MOVIMIENTO]);
CREATE INDEX [IX_MOV_INVENTARIO_DOCUMENTO] ON [dbo].[MOV_INVENTARIO] ([NRO_DOCUMENTO]);
GO

-- ================================================================================
-- CREAR STORED PROCEDURE: sp_ConsultarMov_Inventario
-- ================================================================================
CREATE PROCEDURE [dbo].[sp_ConsultarMov_Inventario]
    @TipoMovimiento VARCHAR(2) = NULL,
    @NroDocumento VARCHAR(50) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OffSet INT = (@PageNumber - 1) * @PageSize;
    
    -- Contar total de registros
    SELECT COUNT(*) AS TotalItems FROM [dbo].[MOV_INVENTARIO]
    WHERE 
        (@TipoMovimiento IS NULL OR TIPO_MOVIMIENTO = @TipoMovimiento)
        AND (@NroDocumento IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumento + '%')
        AND ESTADO = 'A';
    
    -- Obtener datos paginados
    SELECT 
        COD_CIA,
        CIA_VENTA_3,
        ALMACEN_VENTA,
        TIPO_MOVIMIENTO,
        TIPO_DOCUMENTO,
        NRO_DOCUMENTO,
        COD_ITEM_2,
        COMPRADOR,
        DESCRIPCION,
        CANTIDAD,
        PRECIO_UNITARIO,
        PRECIO_VENTA,
        FECHA_MOVIMIENTO,
        USUARIO,
        ESTADO,
        FECHA_REGISTRO
    FROM [dbo].[MOV_INVENTARIO]
    WHERE 
        (@TipoMovimiento IS NULL OR TIPO_MOVIMIENTO = @TipoMovimiento)
        AND (@NroDocumento IS NULL OR NRO_DOCUMENTO LIKE '%' + @NroDocumento + '%')
        AND ESTADO = 'A'
    ORDER BY FECHA_MOVIMIENTO DESC, NRO_DOCUMENTO DESC
    OFFSET @OffSet ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ================================================================================
-- CREAR STORED PROCEDURE: sp_InsertarMovimiento
-- ================================================================================
CREATE PROCEDURE [dbo].[sp_InsertarMovimiento]
    @COD_CIA NVARCHAR(3),
    @CIA_VENTA_3 NVARCHAR(50),
    @ALMACEN_VENTA NVARCHAR(50),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(5),
    @NRO_DOCUMENTO VARCHAR(20),
    @COD_ITEM_2 VARCHAR(20),
    @COMPRADOR NVARCHAR(100),
    @DESCRIPCION NVARCHAR(MAX),
    @CANTIDAD DECIMAL(10, 2),
    @PRECIO_UNITARIO DECIMAL(10, 2),
    @PRECIO_VENTA DECIMAL(10, 2),
    @FECHA_MOVIMIENTO DATE,
    @USUARIO NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO [dbo].[MOV_INVENTARIO]
        (COD_CIA, CIA_VENTA_3, ALMACEN_VENTA, TIPO_MOVIMIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, COD_ITEM_2,
         COMPRADOR, DESCRIPCION, CANTIDAD, PRECIO_UNITARIO, PRECIO_VENTA, FECHA_MOVIMIENTO, USUARIO, ESTADO)
        VALUES
        (@COD_CIA, @CIA_VENTA_3, @ALMACEN_VENTA, @TIPO_MOVIMIENTO, @TIPO_DOCUMENTO, @NRO_DOCUMENTO, @COD_ITEM_2,
         @COMPRADOR, @DESCRIPCION, @CANTIDAD, @PRECIO_UNITARIO, @PRECIO_VENTA, @FECHA_MOVIMIENTO, @USUARIO, 'A');
        
        SELECT 'OK' AS Resultado;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR: ' + ERROR_MESSAGE() AS Resultado;
    END CATCH
END
GO

-- ================================================================================
-- CREAR STORED PROCEDURE: sp_ActualizarMovimiento
-- ================================================================================
CREATE PROCEDURE [dbo].[sp_ActualizarMovimiento]
    @COD_CIA NVARCHAR(3),
    @CIA_VENTA_3 NVARCHAR(50),
    @ALMACEN_VENTA NVARCHAR(50),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(5),
    @NRO_DOCUMENTO VARCHAR(20),
    @COD_ITEM_2 VARCHAR(20),
    @COMPRADOR NVARCHAR(100),
    @DESCRIPCION NVARCHAR(MAX),
    @CANTIDAD DECIMAL(10, 2),
    @PRECIO_UNITARIO DECIMAL(10, 2),
    @PRECIO_VENTA DECIMAL(10, 2),
    @FECHA_MOVIMIENTO DATE,
    @USUARIO NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE [dbo].[MOV_INVENTARIO]
        SET COMPRADOR = @COMPRADOR,
            DESCRIPCION = @DESCRIPCION,
            CANTIDAD = @CANTIDAD,
            PRECIO_UNITARIO = @PRECIO_UNITARIO,
            PRECIO_VENTA = @PRECIO_VENTA,
            FECHA_MOVIMIENTO = @FECHA_MOVIMIENTO,
            USUARIO = @USUARIO
        WHERE COD_CIA = @COD_CIA
            AND CIA_VENTA_3 = @CIA_VENTA_3
            AND ALMACEN_VENTA = @ALMACEN_VENTA
            AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
            AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
            AND NRO_DOCUMENTO = @NRO_DOCUMENTO
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        SELECT 'OK' AS Resultado;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR: ' + ERROR_MESSAGE() AS Resultado;
    END CATCH
END
GO

-- ================================================================================
-- CREAR STORED PROCEDURE: sp_EliminarMovimiento
-- ================================================================================
CREATE PROCEDURE [dbo].[sp_EliminarMovimiento]
    @COD_CIA NVARCHAR(3),
    @CIA_VENTA_3 NVARCHAR(50),
    @ALMACEN_VENTA NVARCHAR(50),
    @TIPO_MOVIMIENTO VARCHAR(2),
    @TIPO_DOCUMENTO VARCHAR(5),
    @NRO_DOCUMENTO VARCHAR(20),
    @COD_ITEM_2 VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE [dbo].[MOV_INVENTARIO]
        SET ESTADO = 'I'
        WHERE COD_CIA = @COD_CIA
            AND CIA_VENTA_3 = @CIA_VENTA_3
            AND ALMACEN_VENTA = @ALMACEN_VENTA
            AND TIPO_MOVIMIENTO = @TIPO_MOVIMIENTO
            AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
            AND NRO_DOCUMENTO = @NRO_DOCUMENTO
            AND COD_ITEM_2 = @COD_ITEM_2;
        
        SELECT 'OK' AS Resultado;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR: ' + ERROR_MESSAGE() AS Resultado;
    END CATCH
END
GO

-- ================================================================================
-- INSERTAR DATOS DE PRUEBA
-- ================================================================================
INSERT INTO [dbo].[MOV_INVENTARIO] 
(COD_CIA, CIA_VENTA_3, ALMACEN_VENTA, TIPO_MOVIMIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, COD_ITEM_2, COMPRADOR, DESCRIPCION, CANTIDAD, PRECIO_UNITARIO, PRECIO_VENTA, FECHA_MOVIMIENTO, USUARIO, ESTADO)
VALUES
('001', 'Empresa A', 'Almacén Central', 'EN', 'FAC', 'FAC-001', 'ITEM001', 'Cliente 1', 'Entrada de mercancía', 100.00, 50.00, 75.00, CAST(GETDATE() AS DATE), 'ADMIN', 'A'),
('001', 'Empresa A', 'Almacén Central', 'SA', 'REM', 'REM-001', 'ITEM002', 'Cliente 2', 'Salida de producto', 50.00, 50.00, 75.00, CAST(GETDATE() - 1 AS DATE), 'ADMIN', 'A'),
('001', 'Empresa A', 'Almacén Central', 'TR', 'TRN', 'TRN-001', 'ITEM003', '', 'Traslado interno', 25.00, 50.00, NULL, CAST(GETDATE() - 2 AS DATE), 'ADMIN', 'A'),
('001', 'Empresa A', 'Almacén Central', 'EN', 'FAC', 'FAC-002', 'ITEM004', 'Cliente 3', 'Segunda entrada', 75.00, 40.00, 60.00, CAST(GETDATE() - 3 AS DATE), 'MANAGER', 'A'),
('001', 'Empresa A', 'Almacén Central', 'SA', 'REM', 'REM-002', 'ITEM005', 'Cliente 4', 'Segunda salida', 30.00, 40.00, 60.00, CAST(GETDATE() - 4 AS DATE), 'USER', 'A');
GO

-- ================================================================================
-- RESULTADO FINAL
-- ================================================================================
PRINT '======================================';
PRINT 'Base de datos inicializada exitosamente';
PRINT '======================================';
PRINT 'Base de datos: inventario';
PRINT 'Tabla: MOV_INVENTARIO (5 registros de prueba)';
PRINT 'Stored Procedures:';
PRINT '  - sp_ConsultarMov_Inventario';
PRINT '  - sp_InsertarMovimiento';
PRINT '  - sp_ActualizarMovimiento';
PRINT '  - sp_EliminarMovimiento';
PRINT '';

-- Verificar los datos
SELECT COUNT(*) AS 'Total de Registros' FROM [dbo].[MOV_INVENTARIO];
SELECT * FROM [dbo].[MOV_INVENTARIO] ORDER BY FECHA_MOVIMIENTO DESC;
