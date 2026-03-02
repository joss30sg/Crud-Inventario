using FluentValidation;

namespace InventarioMVC.Application.Validators
{
    /// <summary>
    /// Validador para actualizar movimientos de inventario.
    /// </summary>
    public class ActualizarMovInventarioValidator : AbstractValidator<DTOs.ActualizarMovInventarioDTO>
    {
        public ActualizarMovInventarioValidator()
        {
            // Cantidad (obligatoria)
            RuleFor(x => x.Cantidad)
                .GreaterThan(0)
                .WithMessage("La cantidad debe ser mayor a 0");

            // Proveedor (opcional)
            RuleFor(x => x.Proveedor)
                .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.Proveedor))
                .WithMessage("El proveedor no puede exceder 100 caracteres");

            // Almacén Destino (opcional)
            RuleFor(x => x.AlmacenDestino)
                .MaximumLength(50).When(x => !string.IsNullOrEmpty(x.AlmacenDestino))
                .WithMessage("El almacén destino no puede exceder 50 caracteres");

            // Fecha de Movimiento (opcional)
            RuleFor(x => x.FechaTransaccion)
                .LessThanOrEqualTo(DateTime.Now).When(x => x.FechaTransaccion.HasValue)
                .WithMessage("La fecha no puede ser en el futuro");
        }
    }
}

