using System;
using System.Collections.Generic;
using FluentAssertions;
using InventarioMVC.Domain.Entities;
using Xunit;

namespace InventarioMVC.Tests.Validation
{
    /// <summary>
    /// Tests para validar reglas de negocio y restricciones.
    /// Simula validaciones que ocurrirían en la capa de servicios.
    /// </summary>
    public class BusinessRulesTests
    {
        [Theory]
        [InlineData("EN", true)]  // Entrada válida
        [InlineData("SA", true)]  // Salida válida
        [InlineData("TR", true)]  // Traslado válido
        [InlineData("XX", false)] // Tipo inválido
        [InlineData("", false)]   // Vacío
        [InlineData(null, false)] // Nulo
        public void ValidarTipoMovimiento_ConVariosValores_DebeValidarCorrectamente(
            string tipoMovimiento,
            bool esValido)
        {
            // Arrange
            var tiposValidos = new[] { "EN", "SA", "TR" };

            // Act
            var resultado = !string.IsNullOrEmpty(tipoMovimiento) &&
                            tiposValidos.Contains(tipoMovimiento);

            // Assert
            resultado.Should().Be(esValido);
        }

        [Theory]
        [InlineData(0, false)]      // Cantidad cero no permitida
        [InlineData(1, true)]       // Cantidad mínima
        [InlineData(100, true)]     // Cantidad normal
        [InlineData(-10, false)]    // Cantidad negativa
        [InlineData(int.MaxValue, true)] // Cantidad máxima
        public void ValidarCantidad_ConVariosValores_DebeValidarCorrectamente(
            int cantidad,
            bool esValida)
        {
            // Arrange & Act
            var resultado = cantidad > 0;

            // Assert
            resultado.Should().Be(esValida);
        }

        [Theory]
        [InlineData("FAC-00001", true)]   // Documento válido
        [InlineData("REM-12345", true)]   // Documento válido
        [InlineData("", false)]            // Documento vacío
        [InlineData(null, false)]          // Documento nulo
        [InlineData("A", true)]            // Un carácter válido
        public void ValidarNroDocumento_ConVariosValores_DebeValidarCorrectamente(
            string nroDocumento,
            bool esValido)
        {
            // Arrange & Act
            var resultado = !string.IsNullOrWhiteSpace(nroDocumento);

            // Assert
            resultado.Should().Be(esValido);
        }

        [Fact]
        public void ValidarFechaTransaccion_EnRango_NoDebeSerFuturaAlejada()
        {
            // Arrange
            var ahora = DateTime.Now;
            var hace30Dias = ahora.AddDays(-30);
            var dentro30Dias = ahora.AddDays(30);

            // Act
            var esValida_hace30 = hace30Dias >= ahora.AddDays(-365) && hace30Dias <= ahora;
            var esValida_dentro30 = dentro30Dias <= ahora; // Fechas futuras no son permitidas en negocio

            // Assert
            esValida_hace30.Should().BeTrue();
            esValida_dentro30.Should().BeFalse(); // Las fechas futuras no son permitidas
        }

        [Fact]
        public void ValidarComposClave_DebenSerUnicos()
        {
            // Arrange
            var movimientos = new List<MovInventario>
            {
                new() {
                    CodCia = "001", CompaniaVenta3 = "CORP", AlmacenVenta = "ALM-01",
                    TipoMovimiento = "EN", TipoDocumento = "01", NroDocumento = "FAC-001",
                    CodItem2 = "ITEM-001", Cantidad = 100, FechaTransaccion = DateTime.Now
                },
                new() {
                    CodCia = "001", CompaniaVenta3 = "CORP", AlmacenVenta = "ALM-01",
                    TipoMovimiento = "EN", TipoDocumento = "01", NroDocumento = "FAC-001",
                    CodItem2 = "ITEM-001", Cantidad = 50, FechaTransaccion = DateTime.Now
                },
            };

            // Act
            var duplicados = movimientos[0].CodCia == movimientos[1].CodCia &&
                            movimientos[0].NroDocumento == movimientos[1].NroDocumento;

            // Assert
            duplicados.Should().BeTrue(); // Estos registros tienen clave duplicada
        }

        [Fact]
        public void ValidarObligatorios_CamposPrincipales_NoDebenSerVacios()
        {
            // Arrange
            var camposObligatorios = new[] { "CodCia", "TipoMovimiento", "NroDocumento", "CodItem2" };

            // Act
            var mov = new MovInventario
            {
                CodCia = "001",
                TipoMovimiento = "EN",
                NroDocumento = "FAC-001",
                CodItem2 = "ITEM-001"
            };

            // Assert
            mov.CodCia.Should().NotBeNullOrEmpty();
            mov.TipoMovimiento.Should().NotBeNullOrEmpty();
            mov.NroDocumento.Should().NotBeNullOrEmpty();
            mov.CodItem2.Should().NotBeNullOrEmpty();
        }
    }
}
