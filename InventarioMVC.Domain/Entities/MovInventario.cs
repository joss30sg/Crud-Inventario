namespace InventarioMVC.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un movimiento de inventario.
    /// Sigue el patrón de Entidad de Dominio (DDD).
    /// Alineada con tabla MOV_INVENTARIO y stored procedures CRUD.
    /// </summary>
    public class MovInventario
    {
        #region Propiedades Clave Primaria (7 campos)

        /// <summary>Código de compañía (Parte de la PK)</summary>
        public string CodCia { get; set; } = null!;

        /// <summary>Compañía de venta (Parte de la PK)</summary>
        public string CompaniaVenta3 { get; set; } = null!;

        /// <summary>Almacén de origen (Parte de la PK)</summary>
        public string AlmacenVenta { get; set; } = null!;

        /// <summary>Tipo de movimiento: EN, SA, TR (Parte de la PK)</summary>
        public string TipoMovimiento { get; set; } = null!;

        /// <summary>Tipo de documento: 01-05 (Parte de la PK)</summary>
        public string TipoDocumento { get; set; } = null!;

        /// <summary>Número de documento (Parte de la PK)</summary>
        public string NroDocumento { get; set; } = null!;

        /// <summary>Código del producto/item (Parte de la PK)</summary>
        public string CodItem2 { get; set; } = null!;

        #endregion

        #region Propiedades de Información (Alineadas con BD)

        /// <summary>Cantidad de unidades movidas</summary>
        public int Cantidad { get; set; }

        /// <summary>Proveedor del item (opcional)</summary>
        public string? Proveedor { get; set; }

        /// <summary>Almacén destino para traslados (opcional)</summary>
        public string? AlmacenDestino { get; set; }

        /// <summary>Documento de referencia 1 (opcional)</summary>
        public string? DocRef1 { get; set; }

        /// <summary>Documento de referencia 2 (opcional)</summary>
        public string? DocRef2 { get; set; }

        /// <summary>Documento de referencia 3 (opcional)</summary>
        public string? DocRef3 { get; set; }

        /// <summary>Documento de referencia 4 (opcional)</summary>
        public string? DocRef4 { get; set; }

        /// <summary>Documento de referencia 5 (opcional)</summary>
        public string? DocRef5 { get; set; }

        /// <summary>Fecha de la transacción</summary>
        public DateTime FechaTransaccion { get; set; }

        #endregion
        #region Métodos

        public override string ToString()
        {
            return $"{NroDocumento} - {CodItem2} ({Cantidad} unidades)";
        }

        /// <summary>
        /// Obtiene el nombre descriptivo del tipo de movimiento.
        /// </summary>
        public string ObtenerDescripcionTipo()
        {
            return TipoMovimiento switch
            {
                "EN" => "ENTRADA",
                "SA" => "SALIDA",
                "TR" => "TRASLADO",
                _ => "DESCONOCIDO"
            };
        }

        #endregion
    }
}
