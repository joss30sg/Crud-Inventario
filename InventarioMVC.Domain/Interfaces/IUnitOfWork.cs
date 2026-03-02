namespace InventarioMVC.Domain.Interfaces
{
    /// <summary>
    /// Interfaz para la unidad de trabajo (Unit of Work pattern).
    /// Coordina múltiples repositorios y gestiona transacciones.
    /// </summary>
    public interface IUnitOfWork : IAsyncDisposable
    {
        /// <summary>Repositorio de MovInventario</summary>
        IMovInventarioRepository MovInventarioRepository { get; }

        /// <summary>Guarda cambios en la base de datos</summary>
        Task<int> GuardarCambiosAsync();

        /// <summary>Inicia una transacción</summary>
        Task IniciarTransaccionAsync();

        /// <summary>Confirma la transacción</summary>
        Task ConfirmarTransaccionAsync();

        /// <summary>Revierte la transacción</summary>
        Task RevierteTransaccionAsync();
    }
}
