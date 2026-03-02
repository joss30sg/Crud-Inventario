namespace InventarioMVC.Application.DTOs
{
    /// <summary>
    /// DTO para paginación de resultados.
    /// Patrón para enviar datos paginados a la presentación.
    /// </summary>
    /// <typeparam name="T">Tipo de DTO a paginar</typeparam>
    public class PaginatedDTO<T>
    {
        public List<T> Items { get; set; } = new();
        public int TotalItems { get; set; }
        public int CurrentPage { get; set; }
        public int TotalPages { get; set; }
        public int PageSize { get; set; }
        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;
    }
}
