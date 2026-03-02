namespace InventarioMVC.Application.DTOs
{
    /// <summary>
    /// DTO para mostrar un movimiento de inventario.
    /// Incluye información completa y descripciones legibles.
    /// </summary>
    public class MostrarMovInventarioDTO
    {
        public string CodCia { get; set; } = null!;
        public string CompaniaVenta3 { get; set; } = null!;
        public string AlmacenVenta { get; set; } = null!;
        public string TipoMovimiento { get; set; } = null!;
        public string DescripcionTipo { get; set; } = null!;
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
        public DateTime FechaMovimiento { get; set; }
    }
}
