using InventarioMVC.Application.DTOs;
using InventarioMVC.Domain.Entities;

namespace InventarioMVC.Application.Mappers
{
    /// <summary>
    /// Mapper para convertir entre DTOs y Entidades de Dominio.
    /// Implementa el patrón Mapper para separación de responsabilidades.
    /// </summary>
    public static class MovInventarioMapper
    {
        /// <summary>Convierte un DTO de creación a una entidad de dominio</summary>
        public static MovInventario ToEntity(this CrearMovInventarioDTO dto)
        {
            return new MovInventario
            {
                CodCia = dto.CodCia,
                CompaniaVenta3 = dto.CompaniaVenta3,
                AlmacenVenta = dto.AlmacenVenta,
                TipoMovimiento = dto.TipoMovimiento,
                TipoDocumento = dto.TipoDocumento,
                NroDocumento = dto.NroDocumento,
                CodItem2 = dto.CodItem2,
                Cantidad = dto.Cantidad,
                Proveedor = dto.Proveedor,
                AlmacenDestino = dto.AlmacenDestino,
                DocRef1 = dto.DocRef1,
                DocRef2 = dto.DocRef2,
                DocRef3 = dto.DocRef3,
                DocRef4 = dto.DocRef4,
                DocRef5 = dto.DocRef5,
                FechaTransaccion = dto.FechaTransaccion
            };
        }

        /// <summary>Convierte un DTO de actualización a una entidad de dominio</summary>
        public static MovInventario ToEntity(this ActualizarMovInventarioDTO dto)
        {
            return new MovInventario
            {
                CodCia = dto.CodCia,
                CompaniaVenta3 = dto.CompaniaVenta3,
                AlmacenVenta = dto.AlmacenVenta,
                TipoMovimiento = dto.TipoMovimiento,
                TipoDocumento = dto.TipoDocumento,
                NroDocumento = dto.NroDocumento,
                CodItem2 = dto.CodItem2,
                Cantidad = dto.Cantidad,
                Proveedor = dto.Proveedor,
                AlmacenDestino = dto.AlmacenDestino,
                DocRef1 = dto.DocRef1,
                DocRef2 = dto.DocRef2,
                DocRef3 = dto.DocRef3,
                DocRef4 = dto.DocRef4,
                DocRef5 = dto.DocRef5,
                FechaTransaccion = dto.FechaTransaccion ?? DateTime.Now
            };
        }

        /// <summary>Convierte una entidad de dominio a un DTO de visualización</summary>
        public static MostrarMovInventarioDTO ToDto(this MovInventario entity)
        {
            return new MostrarMovInventarioDTO
            {
                CodCia = entity.CodCia,
                CompaniaVenta3 = entity.CompaniaVenta3,
                AlmacenVenta = entity.AlmacenVenta,
                TipoMovimiento = entity.TipoMovimiento,
                DescripcionTipo = entity.ObtenerDescripcionTipo(),
                TipoDocumento = entity.TipoDocumento,
                NroDocumento = entity.NroDocumento,
                CodItem2 = entity.CodItem2,
                Cantidad = entity.Cantidad,
                Proveedor = entity.Proveedor,
                AlmacenDestino = entity.AlmacenDestino,
                DocRef1 = entity.DocRef1,
                DocRef2 = entity.DocRef2,
                DocRef3 = entity.DocRef3,
                DocRef4 = entity.DocRef4,
                DocRef5 = entity.DocRef5,
                FechaMovimiento = entity.FechaTransaccion
            };
        }

        /// <summary>Convierte una colección de entidades a DTOs</summary>
        public static IEnumerable<MostrarMovInventarioDTO> ToDto(this IEnumerable<MovInventario> entities)
        {
            return entities.Select(e => e.ToDto());
        }
    }
}
            
