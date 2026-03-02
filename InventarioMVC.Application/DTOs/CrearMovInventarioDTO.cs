namespace InventarioMVC.Application.DTOs
{
    /// <summary>
    /// DTO para crear un movimiento de inventario.
    /// Separa la representación de datos de la entidad de dominio.
    /// </summary>
    public class CrearMovInventarioDTO
    {
        public string CodCia { get; set; } = null!;
        public string CompaniaVenta3 { get; set; } = null!;
        public string AlmacenVenta { get; set; } = null!;
        public string TipoMovimiento { get; set; } = null!;
        public string TipoDocumento { get; set; } = null!;
        public string NroDocumento { get; set; } = null!;
        public string CodItem2 { get; set; } = null!;
        public int Cantidad { get; set; }
        public string? Proveedor { get; set; }
        public string? AlmacenDestino { get; set; }
        public string? DocRef1 { get; set; }
        public string? DocRef2 { get; set; }
        public string? DocRef3 { get; set; }
        public string? DocRef4 { get; set; }
        public string? DocRef5 { get; set; }
        public DateTime? FechaMovimiento { get; set; }
    }
}

