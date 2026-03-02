using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FluentAssertions;
using InventarioMVC.Application.DTOs;
using InventarioMVC.Domain.Entities;
using Moq;
using Xunit;

namespace InventarioMVC.Tests.Application.Services
{
    /// <summary>
    /// Tests para validar conversiones y mapeos de DTOs.
    /// Simula la capa de servicios sin dependencias externas.
    /// </summary>
    public class DTOConversionTests
    {
        private CrearMovInventarioDTO CreateValidDTO()
        {
            return new CrearMovInventarioDTO
            {
                CodCia = "001",
                CompaniaVenta3 = "CORP",
                AlmacenVenta = "ALM-01",
                TipoMovimiento = "EN",
                TipoDocumento = "01",
                NroDocumento = "FAC-00001",
                CodItem2 = "ITEM-001",
                Cantidad = 100,
                FechaTransaccion = DateTime.Now,
                Proveedor = "Proveedor ABC"
            };
        }

        [Fact]
        public void ConvertirDTOAEntidad_ConValoresValidos_DebeMapearCorrectamente()
        {
            // Arrange
            var dto = CreateValidDTO();

            // Act
            var entidad = new MovInventario
            {
                CodCia = dto.CodCia,
                CompaniaVenta3 = dto.CompaniaVenta3,
                AlmacenVenta = dto.AlmacenVenta,
                TipoMovimiento = dto.TipoMovimiento,
                TipoDocumento = dto.TipoDocumento,
                NroDocumento = dto.NroDocumento,
                CodItem2 = dto.CodItem2,
                Cantidad = (int)(dto.Cantidad ?? 0),
                FechaTransaccion = dto.FechaTransaccion ?? DateTime.Now,
                Proveedor = dto.Proveedor
            };

            // Assert
            entidad.CodCia.Should().Be(dto.CodCia);
            entidad.NroDocumento.Should().Be(dto.NroDocumento);
            entidad.Cantidad.Should().Be(dto.Cantidad);
            entidad.Proveedor.Should().Be(dto.Proveedor);
        }

        [Fact]
        public void DTOMovInventario_ConPropiedadesOpcionales_DebeAceptarvaloresNulos()
        {
            // Arrange
            var dto = new CrearMovInventarioDTO
            {
                CodCia = "001",
                CompaniaVenta3 = "CORP",
                AlmacenVenta = "ALM-01",
                TipoMovimiento = "EN",
                TipoDocumento = "01",
                NroDocumento = "FAC-00001",
                CodItem2 = "ITEM-001",
                Cantidad = 100,
                FechaTransaccion = DateTime.Now,
                Proveedor = null,
                AlmacenDestino = null
            };

            // Act & Assert
            dto.Should().NotBeNull();
            dto.Proveedor.Should().BeNull();
            dto.AlmacenDestino.Should().BeNull();
        }

        [Theory]
        [InlineData(0)]
        [InlineData(1)]
        [InlineData(999999)]
        public void DTOCantidad_ConValoresVariados_DebeAceptarseEnElDTO(int cantidad)
        {
            // Arrange
            var dto = CreateValidDTO();
            dto.Cantidad = cantidad;

            // Act & Assert
            dto.Cantidad.Should().Be(cantidad);
        }

        [Fact]
        public void ListaDTOs_CreacionMultiple_DebeContenerVariosRegistros()
        {
            // Arrange
            var dtos = new List<CrearMovInventarioDTO>();
            for (int i = 1; i <= 5; i++)
            {
                var dto = CreateValidDTO();
                dto.NroDocumento = $"FAC-{i:D5}"; // Formato de 5 dígitos: FAC-00001, FAC-00002, etc
                dtos.Add(dto);
            }

            // Act & Assert
            dtos.Should().HaveCount(5);
            dtos.Select(d => d.NroDocumento).Should().Contain("FAC-00001").And.Contain("FAC-00005");
        }
    }
}
