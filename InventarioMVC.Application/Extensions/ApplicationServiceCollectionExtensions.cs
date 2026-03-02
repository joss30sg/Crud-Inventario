using InventarioMVC.Application.Interfaces;
using InventarioMVC.Application.Services;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace InventarioMVC.Application.Extensions
{
    /// <summary>
    /// Extensiones para registrar servicios de la capa Application.
    /// </summary>
    public static class ApplicationServiceCollectionExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            // Registrar servicios
            services.AddScoped<IMovInventarioService, MovInventarioService>();

            // Registrar validadores
            services.AddValidatorsFromAssemblyContaining<AssemblyReference>();

            return services;
        }
    }

    /// <summary>Referencia para ubicar la carpeta de validadores</summary>
    public class AssemblyReference { }
}
