namespace InventarioMVC.Common.Utilities
{
    /// <summary>
    /// Utilidades para fechas.
    /// </summary>
    public static class DateUtility
    {
        public static string FormatearFecha(DateTime? fecha)
        {
            return fecha.HasValue ? fecha.Value.ToString("dd/MM/yyyy HH:mm:ss") : "N/A";
        }

        public static string FormatearFechaCorta(DateTime? fecha)
        {
            return fecha.HasValue ? fecha.Value.ToString("dd/MM/yyyy") : "N/A";
        }

        public static bool EsFechaValida(DateTime? fecha)
        {
            return !fecha.HasValue || fecha.Value <= DateTime.Now;
        }
    }
}
