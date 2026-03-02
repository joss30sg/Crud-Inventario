namespace InventarioMVC.Common.Constants
{
    /// <summary>
    /// Constantes de la aplicación.
    /// Centraliza valores constantes para evitar magic strings.
    /// </summary>
    public static class ApplicationConstants
    {
        public static class TiposMovimiento
        {
            public const string Entrada = "EN";
            public const string Salida = "SA";
            public const string Traslado = "TR";

            public static readonly string[] Todos = { Entrada, Salida, Traslado };
        }

        public static class TiposDocumento
        {
            public const string Factura = "01";
            public const string NotaCredito = "02";
            public const string Remision = "03";
            public const string Guia = "04";
            public const string Comprobante = "05";

            public static readonly string[] Todos = { Factura, NotaCredito, Remision, Guia, Comprobante };
        }

        public static class Pagina
        {
            public const int TamañoPorDefecto = 10;
            public const int TamañoMinimo = 5;
            public const int TamañoMaximo = 100;
        }

        public static class Validacion
        {
            public const int LongitudMaximaNroDocumento = 50;
            public const int LongitudMaximaProducto = 50;
            public const int LongitudMaximaProveedor = 100;
            public const int LongitudMaximaAlmacen = 50;
        }
    }
}
