using System;
using System.Reflection;
using Xunit;

namespace InventarioMVC.Tests.Architecture
{
    /// <summary>
    /// Tests de validación de arquitectura de capas.
    /// Verifica que las dependencias entre capas sean correctas.
    /// </summary>
    public class ArchitectureTests
    {
        [Fact]
        public void DomainLayer_ShouldExist()
        {
            // Arrange & Act
            var domainAssembly = typeof(InventarioMVC.Domain.Entities.MovInventario).Assembly;

            // Assert
            Assert.NotNull(domainAssembly);
            Assert.Equal("InventarioMVC.Domain", domainAssembly.GetName().Name);
        }

        [Fact]
        public void ApplicationLayer_ShouldExist()
        {
            // Arrange & Act
            var appAssembly = typeof(InventarioMVC.Application.DTOs.CrearMovInventarioDTO).Assembly;

            // Assert
            Assert.NotNull(appAssembly);
            Assert.Equal("InventarioMVC.Application", appAssembly.GetName().Name);
        }

        [Fact]
        public void InfrastructureLayer_ShouldExist()
        {
            // Arrange & Act
            var infraAssembly = typeof(InventarioMVC.Infrastructure.Data.InventarioDbContext).Assembly;

            // Assert
            Assert.NotNull(infraAssembly);
            Assert.Equal("InventarioMVC.Infrastructure", infraAssembly.GetName().Name);
        }

        [Fact]
        public void ApplicationLayer_ShouldReferenceDomain()
        {
            // Arrange
            var appAssembly = typeof(InventarioMVC.Application.DTOs.CrearMovInventarioDTO).Assembly;
            var referencedAssemblies = appAssembly.GetReferencedAssemblies();

            // Act & Assert
            Assert.True(
                referencedAssemblies.Any(a => a.Name == "InventarioMVC.Domain"),
                "Application debe referenciar Domain"
            );
        }

        [Fact]
        public void InfrastructureLayer_ShouldReferenceDomain()
        {
            // Arrange
            var infraAssembly = typeof(InventarioMVC.Infrastructure.Data.InventarioDbContext).Assembly;
            var referencedAssemblies = infraAssembly.GetReferencedAssemblies();

            // Act & Assert
            Assert.True(
                referencedAssemblies.Any(a => a.Name == "InventarioMVC.Domain"),
                "Infrastructure debe referenciar Domain"
            );
        }

        [Fact]
        public void DomainLayer_ShouldNotReferencePresentationOrApplication()
        {
            // Arrange
            var domainAssembly = typeof(InventarioMVC.Domain.Entities.MovInventario).Assembly;
            var referencedAssemblies = domainAssembly.GetReferencedAssemblies();

            // Act & Assert
            Assert.False(
                referencedAssemblies.Any(a => a.Name == "InventarioMVC.Presentation"),
                "Domain no debe referenciar Presentation"
            );

            Assert.False(
                referencedAssemblies.Any(a => a.Name == "InventarioMVC.Application"),
                "Domain no debe referenciar Application"
            );

            Assert.False(
                referencedAssemblies.Any(a => a.Name == "InventarioMVC.Infrastructure"),
                "Domain no debe referenciar Infrastructure"
            );
        }
    }
}
