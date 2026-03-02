using InventarioMVC.Application.DTOs;

namespace InventarioMVC.Application.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de aplicación para MovInventario.
    /// Define los casos de uso (Use Cases) de la aplicación.
    /// Implementa el patrón Service Layer.
    /// </summary>
    public interface IMovInventarioService
    {
        /// <summary>Obtiene todos los movimientos paginados con filtros</summary>
        Task<PaginatedDTO<MostrarMovInventarioDTO>> ObtenerTodosAsync(
            int pageNumber = 1, int pageSize = 10, string? searchTerm = null, string? filterTipo = null);

        /// <summary>Obtiene un movimiento específico</summary>
        Task<MostrarMovInventarioDTO?> ObtenerPorIdAsync(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2);

        /// <summary>Crea un nuevo movimiento</summary>
        Task<MostrarMovInventarioDTO> CrearAsync(CrearMovInventarioDTO dto);

        /// <summary>Actualiza un movimiento existente</summary>
        Task<MostrarMovInventarioDTO> ActualizarAsync(ActualizarMovInventarioDTO dto);

        /// <summary>Elimina un movimiento</summary>
        Task EliminarAsync(string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2);

        /// <summary>Obtiene movimientos por tipo de movimiento</summary>
        Task<IEnumerable<MostrarMovInventarioDTO>> ObtenerPorTipoAsync(string tipoMovimiento);

        /// <summary>Obtiene movimientos por almacén</summary>
        Task<IEnumerable<MostrarMovInventarioDTO>> ObtenerPorAlmacenAsync(string almacen);
    }
}
