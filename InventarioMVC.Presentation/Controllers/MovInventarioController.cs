using InventarioMVC.Application.DTOs;
using InventarioMVC.Application.Interfaces;
using InventarioMVC.Common.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace InventarioMVC.Presentation.Controllers
{
    /// <summary>
    /// Controlador para gestionar los movimientos de inventario.
    /// Implementa el patrón MVC y maneja las interacciones del usuario.
    /// </summary>
    [Authorize]
    public class MovInventarioController : Controller
    {
        private readonly IMovInventarioService _service;
        private readonly ILogger<MovInventarioController> _logger;

        /// <summary>
        /// Inicializa una nueva instancia del controlador MovInventarioController.
        /// </summary>
        /// <param name="service">El servicio de movimiento de inventario.</param>
        /// <param name="logger">El logger para registrar información.</param>
        public MovInventarioController(IMovInventarioService service, ILogger<MovInventarioController> logger)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>GET: MovInventario/Index</summary>
        public async Task<IActionResult> Index(int? pageNumber, string? searchTerm, string? filterTipo)
        {
            try
            {
                _logger.LogInformation("Accediendo a Index - Página: {Page}", pageNumber ?? 1);

                const int pageSize = ApplicationConstants.Pagina.TamañoPorDefecto;
                var page = pageNumber ?? 1;

                var resultado = await _service.ObtenerTodosAsync(page, pageSize, searchTerm, filterTipo);

                ViewData["SearchTerm"] = searchTerm;
                ViewData["FilterTipo"] = filterTipo;
                ViewData["TiposMovimiento"] = ApplicationConstants.TiposMovimiento.Todos;

                return View(resultado);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en Index");
                
                // Mensaje de error descriptivo
                string errorMessage = "Error al cargar los movimientos";
                
                if (ex.InnerException?.Message.Contains("Could not find stored procedure") == true)
                {
                    errorMessage = "La base de datos no está correctamente inicializada. Por favor, ejecute los scripts SQL localizados en la carpeta 'Base de Datos'.";
                }
                else if (ex.InnerException?.Message.Contains("Connection") == true || 
                         ex.Message.Contains("Connection") == true)
                {
                    errorMessage = "No se puede conectar a la base de datos. Verifique que SQL Server Express esté ejecutándose.";
                }
                else if (ex.Message.Contains("timeout") || ex.Message.Contains("Timeout"))
                {
                    errorMessage = "La operación tardó demasiado. La base de datos puede estar saturada.";
                }
                
                TempData["ErrorMessage"] = errorMessage;
                return View(new PaginatedDTO<MostrarMovInventarioDTO>());
            }
        }

        /// <summary>GET: MovInventario/Details</summary>
        public async Task<IActionResult> Details(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Obteniendo detalles de {NroDocumento}", nroDocumento);

                var movimiento = await _service.ObtenerPorIdAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                if (movimiento == null)
                {
                    _logger.LogWarning("Movimiento no encontrado: {NroDocumento}", nroDocumento);
                    return NotFound();
                }

                return View(movimiento);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en Details");
                TempData["ErrorMessage"] = "Error al cargar los detalles";
                return RedirectToAction(nameof(Index));
            }
        }

        /// <summary>GET: MovInventario/Create</summary>
        public IActionResult Create()
        {
            _logger.LogInformation("Accediendo a Create");
            return View();
        }

        /// <summary>POST: MovInventario/Create</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CrearMovInventarioDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    CargarDatosParaVista();
                    return View(dto);
                }

                _logger.LogInformation("Creando movimiento: {NroDocumento}", dto.NroDocumento);

                var resultado = await _service.CrearAsync(dto);

                TempData["SuccessMessage"] = $"Movimiento {resultado.NroDocumento} creado exitosamente.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear movimiento");
                ModelState.AddModelError("", "Error al crear el movimiento. Verifique que los datos sean válidos.");
                CargarDatosParaVista();
                return View(dto);
            }
        }

        /// <summary>GET: MovInventario/Edit</summary>
        public async Task<IActionResult> Edit(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Accediendo a Edit: {NroDocumento}", nroDocumento);

                var movimiento = await _service.ObtenerPorIdAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                if (movimiento == null)
                {
                    return NotFound();
                }

                var dto = new ActualizarMovInventarioDTO
                {
                    CodCia = movimiento.CodCia,
                    CompaniaVenta3 = movimiento.CompaniaVenta3,
                    AlmacenVenta = movimiento.AlmacenVenta,
                    TipoMovimiento = movimiento.TipoMovimiento,
                    TipoDocumento = movimiento.TipoDocumento,
                    NroDocumento = movimiento.NroDocumento,
                    CodItem2 = movimiento.CodItem2,
                    Cantidad = movimiento.Cantidad,
                    Proveedor = movimiento.Proveedor,
                    AlmacenDestino = movimiento.AlmacenDestino,
                    DocRef1 = movimiento.DocRef1,
                    DocRef2 = movimiento.DocRef2,
                    DocRef3 = movimiento.DocRef3,
                    DocRef4 = movimiento.DocRef4,
                    DocRef5 = movimiento.DocRef5,
                    FechaTransaccion = movimiento.FechaMovimiento
                };

                CargarDatosParaVista();
                return View(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en Edit");
                TempData["ErrorMessage"] = "Error al cargar el formulario de edición";
                return RedirectToAction(nameof(Index));
            }
        }

        /// <summary>POST: MovInventario/Edit</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(ActualizarMovInventarioDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    CargarDatosParaVista();
                    return View(dto);
                }

                _logger.LogInformation("Actualizando movimiento: {NroDocumento}", dto.NroDocumento);

                var resultado = await _service.ActualizarAsync(dto);

                TempData["SuccessMessage"] = $"Movimiento {resultado.NroDocumento} actualizado exitosamente.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar movimiento");
                ModelState.AddModelError("", "Error al actualizar el movimiento");
                CargarDatosParaVista();
                return View(dto);
            }
        }

        /// <summary>GET: MovInventario/Delete</summary>
        public async Task<IActionResult> Delete(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Accediendo a Delete: {NroDocumento}", nroDocumento);

                var movimiento = await _service.ObtenerPorIdAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                if (movimiento == null)
                {
                    return NotFound();
                }

                return View(movimiento);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en Delete");
                return NotFound();
            }
        }

        /// <summary>POST: MovInventario/Delete</summary>
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(
            string codCia, string companiaVenta3, string almacenVenta,
            string tipoMovimiento, string tipoDocumento, string nroDocumento, string codItem2)
        {
            try
            {
                _logger.LogInformation("Eliminando movimiento: {NroDocumento}", nroDocumento);

                await _service.EliminarAsync(
                    codCia, companiaVenta3, almacenVenta, tipoMovimiento, tipoDocumento, nroDocumento, codItem2);

                TempData["SuccessMessage"] = $"Movimiento {nroDocumento} eliminado exitosamente.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar movimiento");
                TempData["ErrorMessage"] = "Error al eliminar el movimiento";
                return RedirectToAction(nameof(Index));
            }
        }

        /// <summary>Carga datos comunes para la vista</summary>
        private void CargarDatosParaVista()
        {
            ViewData["TiposMovimiento"] = ApplicationConstants.TiposMovimiento.Todos;
            ViewData["TiposDocumento"] = ApplicationConstants.TiposDocumento.Todos;
        }
    }
}
