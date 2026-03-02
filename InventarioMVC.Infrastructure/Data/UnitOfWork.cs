using InventarioMVC.Domain.Interfaces;
using InventarioMVC.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;

namespace InventarioMVC.Infrastructure.Data
{
    /// <summary>
    /// Implementación del patrón Unit of Work.
    /// Coordina múltiples repositorios y gestiona transacciones.
    /// Proporciona una interfaz coherente para acceso a datos.
    /// </summary>
    public class UnitOfWork : IUnitOfWork
    {
        private readonly InventarioDbContext _context;
        private readonly ILogger<MovInventarioRepository> _logger;
        private IMovInventarioRepository? _movInventarioRepository;
        private IDbContextTransaction? _transaction;

        public UnitOfWork(InventarioDbContext context, ILogger<MovInventarioRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public IMovInventarioRepository MovInventarioRepository
        {
            get
            {
                _movInventarioRepository ??= new MovInventarioRepository(_context, _logger);
                return _movInventarioRepository;
            }
        }

        public async Task<int> GuardarCambiosAsync()
        {
            try
            {
                return await _context.SaveChangesAsync();
            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task IniciarTransaccionAsync()
        {
            _transaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task ConfirmarTransaccionAsync()
        {
            try
            {
                await GuardarCambiosAsync();
                if (_transaction != null)
                {
                    await _transaction.CommitAsync();
                }
            }
            catch
            {
                await RevierteTransaccionAsync();
                throw;
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async Task RevierteTransaccionAsync()
        {
            try
            {
                if (_transaction != null)
                {
                    await _transaction.RollbackAsync();
                }
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async ValueTask DisposeAsync()
        {
            if (_transaction != null)
            {
                await _transaction.DisposeAsync();
            }

            if (_context != null)
            {
                await _context.DisposeAsync();
            }

            GC.SuppressFinalize(this);
        }
    }
}
