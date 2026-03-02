using InventarioMVC.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace InventarioMVC.Infrastructure.Data.Configuration
{
    /// <summary>
    /// Configuración de la entidad MovInventario con Fluent API.
    /// Mapea exactamente a la tabla MOV_INVENTARIO y stored procedures.
    /// </summary>
    public class MovInventarioConfiguration : IEntityTypeConfiguration<MovInventario>
    {
        public void Configure(EntityTypeBuilder<MovInventario> builder)
        {
            builder.ToTable("MOV_INVENTARIO", "dbo");

            // CLAVE PRIMARIA COMPUESTA (7 campos)
            builder.HasKey(x => new
            {
                x.CodCia,
                x.CompaniaVenta3,
                x.AlmacenVenta,
                x.TipoMovimiento,
                x.TipoDocumento,
                x.NroDocumento,
                x.CodItem2
            });

            // ========== PROPIEDADES DE CLAVE PRIMARIA ==========
            
            builder.Property(x => x.CodCia)
                .HasColumnName("COD_CIA")
                .HasMaxLength(5)
                .IsRequired();

            builder.Property(x => x.CompaniaVenta3)
                .HasColumnName("COMPANIA_VENTA_3")
                .HasMaxLength(5)
                .IsRequired();

            builder.Property(x => x.AlmacenVenta)
                .HasColumnName("ALMACEN_VENTA")
                .HasMaxLength(10)
                .IsRequired();

            builder.Property(x => x.TipoMovimiento)
                .HasColumnName("TIPO_MOVIMIENTO")
                .HasMaxLength(2)
                .IsRequired();

            builder.Property(x => x.TipoDocumento)
                .HasColumnName("TIPO_DOCUMENTO")
                .HasMaxLength(2)
                .IsRequired();

            builder.Property(x => x.NroDocumento)
                .HasColumnName("NRO_DOCUMENTO")
                .HasMaxLength(50)
                .IsRequired();

            builder.Property(x => x.CodItem2)
                .HasColumnName("COD_ITEM_2")
                .HasMaxLength(50)
                .IsRequired();

            // ========== PROPIEDADES DE INFORMACIÓN ==========
            
            builder.Property(x => x.Cantidad)
                .HasColumnName("CANTIDAD")
                .IsRequired();

            builder.Property(x => x.Proveedor)
                .HasColumnName("PROVEEDOR")
                .HasMaxLength(100)
                .IsRequired(false);

            builder.Property(x => x.AlmacenDestino)
                .HasColumnName("ALMACEN_DESTINO")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.DocRef1)
                .HasColumnName("DOC_REF_1")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.DocRef2)
                .HasColumnName("DOC_REF_2")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.DocRef3)
                .HasColumnName("DOC_REF_3")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.DocRef4)
                .HasColumnName("DOC_REF_4")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.DocRef5)
                .HasColumnName("DOC_REF_5")
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(x => x.FechaTransaccion)
                .HasColumnName("FECHA_TRANSACCION")
                .IsRequired();

            // ÍNDICES PARA OPTIMIZACIÓN
            builder.HasIndex(x => x.FechaTransaccion)
                .HasDatabaseName("IX_MOV_INVENTARIO_FECHA");

            builder.HasIndex(x => x.NroDocumento)
                .HasDatabaseName("IX_MOV_INVENTARIO_DOCUMENTO");

            builder.HasIndex(x => x.TipoMovimiento)
                .HasDatabaseName("IX_MOV_INVENTARIO_TIPO");
        }
    }
}
