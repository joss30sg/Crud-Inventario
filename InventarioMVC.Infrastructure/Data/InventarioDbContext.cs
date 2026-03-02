using InventarioMVC.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using InventarioMVC.Infrastructure.Data.Configuration;

namespace InventarioMVC.Infrastructure.Data
{
    /// <summary>
    /// Contexto de Entity Framework Core.
    /// Gestiona la conexión y mapeo con la base de datos SQL Server.
    /// </summary>
    public class InventarioDbContext : DbContext
    {
        public InventarioDbContext(DbContextOptions<InventarioDbContext> options) : base(options)
        {
        }

        public DbSet<MovInventario> MovInventario { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Aplicar configuraciones de entidades
            modelBuilder.ApplyConfiguration(new MovInventarioConfiguration());
        }
    }
}
