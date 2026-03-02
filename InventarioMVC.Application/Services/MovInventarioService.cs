using InventarioMVC.Application.DTOs;
using InventarioMVC.Application.Interfaces;
using InventarioMVC.Application.Mappers;
using InventarioMVC.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace InventarioMVC.Application.Services
{
    /// <summary>
    /// Implementación del servicio de aplicación para MovInventario.
    /// Contiene la lógica de negocio de la aplicación.
    /// </summary>
    public class MovInventarioService : IMovInventarioService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<MovInventarioService> _logger;

        public MovInventarioService(IUnitOfWork unitOfWork, ILogger<MovInventarioService> logger)
        {
            _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<PaginatedDTO<MostrarMovInventarioDTO>> ObtenerTodosAsync(
            int pageNumber = 1, int pageSize = 10, string? searchTerm = null, string? filterTipo = null)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimientos paginados - Página: {Page}, Tamaño: {Size}", pageNumber, pageSize);

                var (items, total) = await _unitOfWork.MovInventarioRepository.ObtenerConPaginacionAsync(
                    pageNumber, pageSize, searchTerm, filterTipo);

                var totalPages = (int)Math.Ceiling((double)total / pageSize);

                return new PaginatedDTO<MostrarMovInventarioDTO>
                {
                    Items = items.ToDto().ToList(),
                    TotalItems = total,
                    CurrentPage = pageNumber,
                    TotalPages = totalPages,
                    PageSize = pageSize
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos paginados");
                throw;
            }
        }

        public async Task<MostrarMovInventarioDTO?> ObtenerPorIdAsync(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimiento: {NroDocumento}", nroDocumento);

                var movimiento = await _unitOfWork.MovInventarioRepository.ObtenerPorIdAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                if (movimiento == null)
                {
                    _logger.LogWarning("Movimiento no encontrado: {NroDocumento}", nroDocumento);
                    return null;
                }

                return movimiento.ToDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimiento por ID");
                throw;
            }
        }

        public async Task<MostrarMovInventarioDTO> CrearAsync(CrearMovInventarioDTO dto)
        {
            try
            {
                _logger.LogInformation("Creando nuevo movimiento: {NroDocumento}", dto.NroDocumento);

                var entity = dto.ToEntity();
                var movimientoCreado = await _unitOfWork.MovInventarioRepository.CrearAsync(entity);
                await _unitOfWork.GuardarCambiosAsync();

                _logger.LogInformation("Movimiento creado exitosamente: {NroDocumento}", dto.NroDocumento);
                return movimientoCreado.ToDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear movimiento");
                throw;
            }
        }

        public async Task<MostrarMovInventarioDTO> ActualizarAsync(ActualizarMovInventarioDTO dto)
        {
            try
            {
                _logger.LogInformation("Actualizando movimiento: {NroDocumento}", dto.NroDocumento);

                var entity = dto.ToEntity();
                var movimientoActualizado = await _unitOfWork.MovInventarioRepository.ActualizarAsync(entity);
                await _unitOfWork.GuardarCambiosAsync();

                _logger.LogInformation("Movimiento actualizado exitosamente: {NroDocumento}", dto.NroDocumento);
                return movimientoActualizado.ToDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar movimiento");
                throw;
            }
        }

        public async Task EliminarAsync(string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Eliminando movimiento: {NroDocumento}", nroDocumento);

                await _unitOfWork.MovInventarioRepository.EliminarAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);
                await _unitOfWork.GuardarCambiosAsync();

                _logger.LogInformation("Movimiento eliminado exitosamente: {NroDocumento}", nroDocumento);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar movimiento");
                throw;
            }
        }

        public async Task<IEnumerable<MostrarMovInventarioDTO>> ObtenerPorTipoAsync(string tipoMovimiento)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimientos por tipo: {Tipo}", tipoMovimiento);

                var movimientos = await _unitOfWork.MovInventarioRepository.ObtenerPorTipoMovimientoAsync(tipoMovimiento);
                return movimientos.ToDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos por tipo");
                throw;
            }
        }

        public async Task<IEnumerable<MostrarMovInventarioDTO>> ObtenerPorAlmacenAsync(string almacen)
        {
            try
            {
                _logger.LogInformation("Obteniendo movimientos por almacén: {Almacen}", almacen);

                var movimientos = await _unitOfWork.MovInventarioRepository.ObtenerPorAlmacenAsync(almacen);
                return movimientos.ToDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener movimientos por almacén");
                throw;
            }
        }
    }
}
