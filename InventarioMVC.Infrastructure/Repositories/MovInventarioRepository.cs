using InventarioMVC.Domain.Entities;
using InventarioMVC.Domain.Interfaces;
using InventarioMVC.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace InventarioMVC.Infrastructure.Repositories
{
    /// <summary>
    /// Repositorio para la entidad MovInventario.
    /// Implementa el patrón Repository con Store Procedures.
    /// Consume procedimientos almacenados SQL Server para todas las operaciones CRUD.
    /// </summary>
    public class MovInventarioRepository : IMovInventarioRepository
    {
        private readonly InventarioDbContext _context;
        private readonly ILogger<MovInventarioRepository> _logger;

        public MovInventarioRepository(InventarioDbContext context, ILogger<MovInventarioRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Obtiene todos los movimientos de inventario usando Store Procedure.
        /// </summary>
        public async Task<IEnumerable<MovInventario>> ObtenerTodosAsync()
        {
            try
            {
                _logger.LogInformation("Obteniendo todos los movimientos usando sp_ConsultarMov_Inventario");
                
                // Llamar al Store Procedure sin parámetros (retorna todos)
                var movimientos = await _context.MovInventario
                    .FromSqlInterpolated($"EXEC dbo.sp_ConsultarMov_Inventario")
                    .ToListAsync();

                _logger.LogInformation("Se obtuvieron {Count} movimientos", movimientos.Count);
                return movimientos;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener todos los movimientos desde sp_ConsultarMov_Inventario");
                throw;
            }
        }

        /// <summary>
        /// Obtiene un movimiento específico por su clave primaria compuesta.
        /// </summary>
        public async Task<MovInventario?> ObtenerPorIdAsync(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Buscando movimiento: {NroDocumento}", nroDocumento);

                // Usar Store Procedure con filtro de Número de Documento
                var movimientos = await _context.MovInventario
                    .FromSqlInterpolated($"EXEC dbo.sp_ConsultarMov_Inventario @NroDocumento = {nroDocumento}")
                    .ToListAsync();

                // Filtrar en memoria con todas las claves primarias
                var movimiento = movimientos.FirstOrDefault(m =>
                    m.CodCia == codCia &&
                    m.CompaniaVenta3 == companiaVenta3 &&
                    m.AlmacenVenta == almacenVenta &&
                    m.TipoMovimiento == tipoMovimiento &&
                    m.TipoDocumento == tipoDocumento &&
                    m.NroDocumento == nroDocumento &&
                    m.CodItem2 == codItem2);

                if (movimiento != null)
                {
                    _logger.LogInformation("Movimiento encontrado: {NroDocumento}", nroDocumento);
                }
                else
                {
                    _logger.LogWarning("Movimiento no encontrado: {NroDocumento}", nroDocumento);
                }

                return movimiento;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimiento por ID desde Store Procedure");
                throw;
            }
        }

        /// <summary>
        /// Obtiene movimientos con paginación, búsqueda y filtros usando Store Procedure.
        /// </summary>
        public async Task<(IEnumerable<MovInventario> Items, int Total)> ObtenerConPaginacionAsync(
            int pageNumber, int pageSize, string? searchTerm = null, string? filterTipo = null)
        {
            try
            {
                _logger.LogInformation(
                    "Obteniendo movimientos con paginación - Página: {Page}, Tamaño: {Size}, Búsqueda: {Search}, Tipo: {Tipo}",
                    pageNumber, pageSize, searchTerm, filterTipo);

                // Convertir pageNumber a 1 si es menor
                if (pageNumber < 1) pageNumber = 1;
                
                // Limitar pageSize entre 1 y 1000
                if (pageSize < 1) pageSize = 10;
                if (pageSize > 1000) pageSize = 1000;

                // Primero, obtener el total sin paginación
                var allItems = await _context.MovInventario
                    .FromSqlInterpolated($@"
                        EXEC dbo.sp_ConsultarMov_Inventario 
                            @FechaInicio = NULL,
                            @FechaFin = NULL,
                            @TipoMovimiento = {filterTipo},
                            @NroDocumento = {searchTerm},
                            @PageNumber = 1,
                            @PageSize = 1000
                    ")
                    .ToListAsync();

                int totalItems = allItems.Count;

                // Aplicar paginación en memoria si es necesario
                var items = allItems
                    .Skip((pageNumber - 1) * pageSize)
                    .Take(pageSize)
                    .ToList();

                _logger.LogInformation("Se obtuvieron {Count} movimientos de un total de {Total}", items.Count, totalItems);

                return (items, totalItems);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos con paginación desde Store Procedure");
                throw;
            }
        }

        /// <summary>
        /// Crea un nuevo movimiento usando Store Procedure sp_InsertarMovimiento.
        /// </summary>
        public async Task<MovInventario> CrearAsync(MovInventario movimiento)
        {
            try
            {
                _logger.LogInformation("Creando nuevo movimiento con NroDocumento: {NroDocumento}", movimiento.NroDocumento);

                // Ejecutar Store Procedure de inserción con parámetros correctos
                var resultado = await _context.Database.ExecuteSqlInterpolatedAsync($@"
                    EXEC dbo.sp_InsertarMovimiento
                        @COD_CIA = {movimiento.CodCia},
                        @COMPANIA_VENTA_3 = {movimiento.CompaniaVenta3},
                        @ALMACEN_VENTA = {movimiento.AlmacenVenta},
                        @TIPO_MOVIMIENTO = {movimiento.TipoMovimiento},
                        @TIPO_DOCUMENTO = {movimiento.TipoDocumento},
                        @NRO_DOCUMENTO = {movimiento.NroDocumento},
                        @COD_ITEM_2 = {movimiento.CodItem2},
                        @CANTIDAD = {movimiento.Cantidad},
                        @FECHA_TRANSACCION = {movimiento.FechaTransaccion},
                        @PROVEEDOR = {movimiento.Proveedor},
                        @ALMACEN_DESTINO = {movimiento.AlmacenDestino},
                        @DOC_REF_1 = {movimiento.DocRef1},
                        @DOC_REF_2 = {movimiento.DocRef2},
                        @DOC_REF_3 = {movimiento.DocRef3},
                        @DOC_REF_4 = {movimiento.DocRef4},
                        @DOC_REF_5 = {movimiento.DocRef5}
                ");

                _logger.LogInformation("Movimiento creado exitosamente: {NroDocumento}", movimiento.NroDocumento);

                return movimiento;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear movimiento usando sp_InsertarMovimiento");
                throw;
            }
        }

        /// <summary>
        /// Actualiza un movimiento existente usando Store Procedure sp_ActualizarMovimiento.
        /// </summary>
        public async Task<MovInventario> ActualizarAsync(MovInventario movimiento)
        {
            try
            {
                _logger.LogInformation("Actualizando movimiento NroDocumento: {NroDocumento}", movimiento.NroDocumento);

                // Verificar que existe antes de actualizar
                var entidadExistente = await ObtenerPorIdAsync(
                    movimiento.CodCia, movimiento.CompaniaVenta3, movimiento.AlmacenVenta,
                    movimiento.TipoMovimiento, movimiento.TipoDocumento,
                    movimiento.NroDocumento, movimiento.CodItem2);

                if (entidadExistente == null)
                {
                    throw new KeyNotFoundException($"Movimiento {movimiento.NroDocumento} no encontrado");
                }

                // Ejecutar Store Procedure de actualización con parámetros correctos
                var resultado = await _context.Database.ExecuteSqlInterpolatedAsync($@"
                    EXEC dbo.sp_ActualizarMovimiento
                        @COD_CIA = {movimiento.CodCia},
                        @COMPANIA_VENTA_3 = {movimiento.CompaniaVenta3},
                        @ALMACEN_VENTA = {movimiento.AlmacenVenta},
                        @TIPO_MOVIMIENTO = {movimiento.TipoMovimiento},
                        @TIPO_DOCUMENTO = {movimiento.TipoDocumento},
                        @NRO_DOCUMENTO = {movimiento.NroDocumento},
                        @COD_ITEM_2 = {movimiento.CodItem2},
                        @CANTIDAD = {movimiento.Cantidad},
                        @FECHA_TRANSACCION = {movimiento.FechaTransaccion},
                        @PROVEEDOR = {movimiento.Proveedor},
                        @ALMACEN_DESTINO = {movimiento.AlmacenDestino},
                        @DOC_REF_1 = {movimiento.DocRef1},
                        @DOC_REF_2 = {movimiento.DocRef2},
                        @DOC_REF_3 = {movimiento.DocRef3},
                        @DOC_REF_4 = {movimiento.DocRef4},
                        @DOC_REF_5 = {movimiento.DocRef5}
                ");

                _logger.LogInformation("Movimiento actualizado exitosamente: {NroDocumento}", movimiento.NroDocumento);

                return movimiento;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar movimiento usando sp_ActualizarMovimiento");
                throw;
            }
        }

        /// <summary>
        /// Elimina un movimiento usando Store Procedure sp_EliminarMovimiento.
        /// </summary>
        public async Task EliminarAsync(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Eliminando movimiento NroDocumento: {NroDocumento}", nroDocumento);

                // Verificar que existe antes de eliminar
                var movimiento = await ObtenerPorIdAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                if (movimiento == null)
                {
                    throw new KeyNotFoundException($"Movimiento {nroDocumento} no encontrado");
                }

                // Ejecutar Store Procedure de eliminación
                var resultado = await _context.Database.ExecuteSqlInterpolatedAsync($@"
                    EXEC dbo.sp_EliminarMovimiento
                        @COD_CIA = {codCia},
                        @COMPANIA_VENTA_3 = {companiaVenta3},
                        @ALMACEN_VENTA = {almacenVenta},
                        @TIPO_MOVIMIENTO = {tipoMovimiento},
                        @TIPO_DOCUMENTO = {tipoDocumento},
                        @NRO_DOCUMENTO = {nroDocumento},
                        @COD_ITEM_2 = {codItem2}
                ");

                _logger.LogInformation("Movimiento eliminado exitosamente: {NroDocumento}", nroDocumento);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar movimiento usando sp_EliminarMovimiento");
                throw;
            }
        }

        /// <summary>
        /// Obtiene movimientos por tipo de movimiento usando Store Procedure.
        /// </summary>
        public async Task<IEnumerable<MovInventario>> ObtenerPorTipoMovimientoAsync(string tipoMovimiento)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimientos por tipo: {Tipo}", tipoMovimiento);

                var movimientos = await _context.MovInventario
                    .FromSqlInterpolated($"EXEC dbo.sp_ConsultarMov_Inventario @TipoMovimiento = {tipoMovimiento}")
                    .ToListAsync();

                _logger.LogInformation("Se obtuvieron {Count} movimientos del tipo {Tipo}", movimientos.Count, tipoMovimiento);

                return movimientos;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos por tipo desde Store Procedure");
                throw;
            }
        }

        /// <summary>
        /// Obtiene movimientos por almacén usando Store Procedure.
        /// </summary>
        public async Task<IEnumerable<MovInventario>> ObtenerPorAlmacenAsync(string almacen)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimientos por almacén: {Almacen}", almacen);

                // El Store Procedure no tiene parámetro directo para almacén, 
                // así que obtenemos todos y filtramos en memoria
                var movimientos = await _context.MovInventario
                    .FromSqlInterpolated($"EXEC dbo.sp_ConsultarMov_Inventario")
                    .Where(x => x.AlmacenVenta == almacen)
                    .OrderByDescending(x => x.FechaTransaccion)
                    .ToListAsync();

                _logger.LogInformation("Se obtuvieron {Count} movimientos del almacén {Almacen}", movimientos.Count, almacen);

                return movimientos;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos por almacén desde Store Procedure");
                throw;
            }
        }
    }
}
