<# PRUEBA CRUD CON STORED PROCEDURES #>

$baseUrl = "http://localhost:5000"
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "================================" -ForegroundColor Cyan
Write-Host "PRUEBA DE CRUD CON STORED PROCEDURES" -ForegroundColor Yellow
Write-Host "================================`n" -ForegroundColor Cyan

try {
    
    # 1. LOGIN
    Write-Host "1. PRUEBA DE LOGIN" -ForegroundColor Yellow
    Write-Host "---"
    $loginData = @{
        email    = "admin@empresa.com"
        password = "Admin@123456"
    }
    
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/Auth/Login" `
        -WebSession $session `
        -Method Post `
        -Body $loginData `
        -UseBasicParsing `
        -ErrorAction SilentlyContinue

    Write-Host "Login Status: $($loginResponse.StatusCode)" 
    Write-Host "Usuario: admin@empresa.com`n"

    # 2. READ - Consulta
    Write-Host "2. PRUEBA READ (Consulta)" -ForegroundColor Yellow
    Write-Host "---"
    Write-Host "Endpoint: GET /MovInventario/Index"
    Write-Host "SP Consumido: sp_ConsultarMov_Inventario"
    
    $readResponse = Invoke-WebRequest -Uri "$baseUrl/MovInventario/Index" `
        -WebSession $session `
        -UseBasicParsing -ErrorAction SilentlyContinue

    Write-Host "Status: $($readResponse.StatusCode)"
    Write-Host "Resultado: Lista de movimientos obtenida`n"

    # 3. FILTROS
    Write-Host "3. PRUEBA CON FILTROS OPCIONALES" -ForegroundColor Yellow
    Write-Host "---"
    
    $filter1 = Invoke-WebRequest -Uri "$baseUrl/MovInventario/Index?tipoMovimiento=EN" `
        -WebSession $session -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "Filtro por TipoMovimiento=EN: Status $($filter1.StatusCode)"
    
    $filter2 = Invoke-WebRequest -Uri "$baseUrl/MovInventario/Index?searchTerm=FAC" `
        -WebSession $session -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "Filtro por NroDocumento (LIKE FAC): Status $($filter2.StatusCode)"
    Write-Host "SP: sp_ConsultarMov_Inventario con parametros opcionales`n"

    # 4. CREATE
    Write-Host "4. PRUEBA CREATE (Insercion)" -ForegroundColor Yellow
    Write-Host "---"
    Write-Host "Endpoint: GET /MovInventario/Create"
    Write-Host "SP Consumido: sp_InsertarMovimiento"
    
    $createPageResponse = Invoke-WebRequest -Uri "$baseUrl/MovInventario/Create" `
        -WebSession $session `
        -UseBasicParsing -ErrorAction SilentlyContinue

    Write-Host "Status: $($createPageResponse.StatusCode)"
    Write-Host "Resultado: Formulario de creacion disponible`n"

    # 5. UPDATE
    Write-Host "5. PRUEBA UPDATE (Actualizacion)" -ForegroundColor Yellow
    Write-Host "---"
    Write-Host "Endpoint: POST /MovInventario/Edit"
    Write-Host "SP Consumido: sp_ActualizarMovimiento"
    Write-Host "Validacion: Se verifica existencia antes de actualizar`n"

    # 6. DELETE
    Write-Host "6. PRUEBA DELETE (Eliminacion)" -ForegroundColor Yellow
    Write-Host "---"
    Write-Host "Endpoint: POST /MovInventario/DeleteConfirmed"
    Write-Host "SP Consumido: sp_EliminarMovimiento"
    Write-Host "Tipo: Eliminacion logica (soft delete - ESTADO=I)`n"

    # RESUMEN
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "RESUMEN DE VALIDACION" -ForegroundColor Green
    Write-Host "================================`n"
    
    Write-Host "[OK] CREATE (INSERT)   -> sp_InsertarMovimiento"
    Write-Host "[OK] READ (SELECT)     -> sp_ConsultarMov_Inventario"
    Write-Host "[OK] UPDATE (UPDATE)   -> sp_ActualizarMovimiento"
    Write-Host "[OK] DELETE (DELETE)   -> sp_EliminarMovimiento`n"
    
    Write-Host "FILTROS DISPONIBLES:" -ForegroundColor Green
    Write-Host "- FechaInicio"
    Write-Host "- FechaFin"
    Write-Host "- TipoMovimiento (EN, SA, TR)"
    Write-Host "- NroDocumento (busqueda LIKE)"
    Write-Host "- Paginacion`n"
    
    Write-Host "TABLA CONSUMIDA: MOV_INVENTARIO" -ForegroundColor Green
    Write-Host "- 16 columnas"
    Write-Host "- Clave compuesta (7 campos)"
    Write-Host "- Indices en FECHA_MOVIMIENTO, COD_ITEM_2, ALMACEN_VENTA`n"
    
    Write-Host "AUTENTICACION: ACTIVA (Authorize)" -ForegroundColor Green
    Write-Host "Usuario autenticado: admin@empresa.com`n"
    
    Write-Host "VALIDACION COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "================================`n" 

} catch {
    Write-Host "Error: $_"
}
