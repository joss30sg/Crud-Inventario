using FluentValidation;

namespace InventarioMVC.Application.Validators
{
    /// <summary>
    /// Validador para crear movimientos de inventario.
    /// Implementa reglas de negocio usando FluentValidation.
    /// </summary>
    public class CrearMovInventarioValidator : AbstractValidator<DTOs.CrearMovInventarioDTO>
    {
        public CrearMovInventarioValidator()
        {
            // Compañía
            RuleFor(x => x.CodCia)
                .NotEmpty().WithMessage("El código de compañía es requerido")
                .Length(1, 5).WithMessage("El código de compañía debe tener entre 1 y 5 caracteres");

            // Compañía Venta
            RuleFor(x => x.CompaniaVenta3)
                .NotEmpty().WithMessage("La compañía de venta es requerida")
                .MaximumLength(5).WithMessage("La compañía de venta no puede exceder 5 caracteres");

            // Almacén
            RuleFor(x => x.AlmacenVenta)
                .NotEmpty().WithMessage("El almacén de venta es requerido")
                .MaximumLength(10).WithMessage("El almacén no puede exceder 10 caracteres");

            // Tipo de Movimiento
            RuleFor(x => x.TipoMovimiento)
                .NotEmpty().WithMessage("El tipo de movimiento es requerido")
                .Must(x => new[] { "EN", "SA", "TR" }.Contains(x))
                .WithMessage("El tipo de movimiento debe ser EN (Entrada), SA (Salida) o TR (Traslado)");

            // Tipo de Documento
            RuleFor(x => x.TipoDocumento)
                .NotEmpty().WithMessage("El tipo de documento es requerido")
                .MaximumLength(2).WithMessage("El tipo de documento no puede exceder 2 caracteres");

            // Número de Documento
            RuleFor(x => x.NroDocumento)
                .NotEmpty().WithMessage("El número de documento es requerido")
                .MaximumLength(50).WithMessage("El número de documento no puede exceder 50 caracteres");

            // Código de Producto
            RuleFor(x => x.CodItem2)
                .NotEmpty().WithMessage("El código del producto es requerido")
                .MaximumLength(50).WithMessage("El código del producto no puede exceder 50 caracteres");

            // Cantidad (obligatoria)
            RuleFor(x => x.Cantidad)
                .GreaterThan(0)
                .WithMessage("La cantidad debe ser mayor a 0");

            RuleFor(x => x.FechaTransaccion)
                .LessThanOrEqualTo(DateTime.Now)
                .WithMessage("La fecha no puede ser en el futuro");

            // Proveedor (opcional)
            RuleFor(x => x.Proveedor)
                .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.Proveedor))
                .WithMessage("El proveedor no puede exceder 100 caracteres");

            // Almacén Destino (opcional)
            RuleFor(x => x.AlmacenDestino)
                .MaximumLength(50).When(x => !string.IsNullOrEmpty(x.AlmacenDestino))
                .WithMessage("El almacén destino no puede exceder 50 caracteres");
        }
    }
}

