namespace InventarioMVC.Domain.Interfaces
{
    /// <summary>
    /// Interfaz para el repositorio de MovInventario.
    /// Implementa el patrón Repository para acceso a datos.
    /// </summary>
    public interface IMovInventarioRepository
    {
        /// <summary>Obtiene todos los movimientos de inventario</summary>
        Task<IEnumerable<Entities.MovInventario>> ObtenerTodosAsync();

        /// <summary>Obtiene un movimiento específico por su clave primaria compuesta</summary>
        Task<Entities.MovInventario?> ObtenerPorIdAsync(string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2);

        /// <summary>Obtiene movimientos con paginación</summary>
        Task<(IEnumerable<Entities.MovInventario> Items, int Total)> ObtenerConPaginacionAsync(
            int pageNumber, int pageSize, string? searchTerm = null, string? filterTipo = null);

        /// <summary>Crea un nuevo movimiento</summary>
        Task<Entities.MovInventario> CrearAsync(Entities.MovInventario movimiento);

        /// <summary>Actualiza un movimiento existente</summary>
        Task<Entities.MovInventario> ActualizarAsync(Entities.MovInventario movimiento);

        /// <summary>Elimina un movimiento</summary>
        Task EliminarAsync(string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2);

        /// <summary>Obtiene movimientos filtrados por tipo</summary>
        Task<IEnumerable<Entities.MovInventario>> ObtenerPorTipoMovimientoAsync(string tipoMovimiento);

        /// <summary>Obtiene movimientos filtrados por almacén</summary>
        Task<IEnumerable<Entities.MovInventario>> ObtenerPorAlmacenAsync(string almacen);
    }
}
