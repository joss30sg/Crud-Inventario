using InventarioMVC.Domain.Interfaces;
using InventarioMVC.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace InventarioMVC.Infrastructure.Extensions
{
    /// <summary>
    /// Extensiones para registrar servicios de la capa Infrastructure.
    /// Implementa el patrón de inyección de dependencias.
    /// </summary>
    public static class InfrastructureServiceCollectionExtensions
    {
        public static IServiceCollection AddInfrastructureServices(
            this IServiceCollection services, IConfiguration configuration)
        {
            // Registrar DbContext
            var connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? "Server=localhost\\SQLEXPRESS;Database=inventario;Trusted_Connection=true;Encrypt=false;";

            services.AddDbContext<InventarioDbContext>(options =>
                options.UseSqlServer(connectionString, sqlOptions =>
                {
                    sqlOptions.MigrationsAssembly("InventarioMVC.Infrastructure");
                    sqlOptions.CommandTimeout(30);
                }));

            // Registrar Unit of Work
            services.AddScoped<IUnitOfWork, UnitOfWork>();

            return services;
        }
    }
}
