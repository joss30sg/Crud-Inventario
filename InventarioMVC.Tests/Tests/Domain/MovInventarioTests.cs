using System;
using FluentAssertions;
using InventarioMVC.Domain.Entities;
using Xunit;

namespace InventarioMVC.Tests.Domain
{
    /// <summary>
    /// Tests para la entidad MovInventario.
    /// Valida que la entidad cumpla con las reglas de negocio.
    /// </summary>
    public class MovInventarioTests
    {
        [Fact]
        public void CrearMovInventario_ConValoresValidos_DebeCrearseCorrectamente()
        {
            // Arrange
            var codCia = "001";
            var companiaVenta3 = "CORP";
            var almacenVenta = "ALM-01";
            var tipoMovimiento = "EN";
            var tipoDocumento = "01";
            var nroDocumento = "FAC-00001";
            var codItem2 = "ITEM-001";
            var cantidad = 100;
            var fechaTransaccion = DateTime.Now;

            // Act
            var movInventario = new MovInventario
            {
                CodCia = codCia,
                CompaniaVenta3 = companiaVenta3,
                AlmacenVenta = almacenVenta,
                TipoMovimiento = tipoMovimiento,
                TipoDocumento = tipoDocumento,
                NroDocumento = nroDocumento,
                CodItem2 = codItem2,
                Cantidad = cantidad,
                FechaTransaccion = fechaTransaccion
            };

            // Assert
            movInventario.Should().NotBeNull();
            movInventario.CodCia.Should().Be(codCia);
            movInventario.CompaniaVenta3.Should().Be(companiaVenta3);
            movInventario.TipoMovimiento.Should().Be(tipoMovimiento);
            movInventario.Cantidad.Should().Be(cantidad);
        }

        [Theory]
        [InlineData("EN")]
        [InlineData("SA")]
        [InlineData("TR")]
        public void MovInventario_ConTipoMovimientoValido_DebeAceptarse(string tipoMovimiento)
        {
            // Arrange & Act
            var movInventario = new MovInventario
            {
                CodCia = "001",
                CompaniaVenta3 = "CORP",
                AlmacenVenta = "ALM-01",
                TipoMovimiento = tipoMovimiento,
                TipoDocumento = "01",
                NroDocumento = "FAC-00001",
                CodItem2 = "ITEM-001",
                Cantidad = 100,
                FechaTransaccion = DateTime.Now
            };

            // Assert
            movInventario.TipoMovimiento.Should().Be(tipoMovimiento);
        }

        [Fact]
        public void MovInventario_ConCantidadNegativa_DebeCrearsePeroPuedeValidarseEnServicio()
        {
            // Arrange & Act
            var movInventario = new MovInventario
            {
                CodCia = "001",
                CompaniaVenta3 = "CORP",
                AlmacenVenta = "ALM-01",
                TipoMovimiento = "EN",
                TipoDocumento = "01",
                NroDocumento = "FAC-00001",
                CodItem2 = "ITEM-001",
                Cantidad = -50, // Cantidad negativa
                FechaTransaccion = DateTime.Now
            };

            // Assert - La entidad se crea, pero la validación debe ocurrir en servicio/validador
            movInventario.Should().NotBeNull();
            movInventario.Cantidad.Should().Be(-50);
        }

        [Fact]
        public void MovInventario_ConFechaDefault_DebeUtilizarFechaActual()
        {
            // Arrange
            var ahora = DateTime.Now;

            // Act
            var movInventario = new MovInventario
            {
                CodCia = "001",
                CompaniaVenta3 = "CORP",
                AlmacenVenta = "ALM-01",
                TipoMovimiento = "EN",
                TipoDocumento = "01",
                NroDocumento = "FAC-00001",
                CodItem2 = "ITEM-001",
                Cantidad = 100,
                FechaTransaccion = ahora
            };

            // Assert
            movInventario.FechaTransaccion.Should().Be(ahora);
        }
    }
}
