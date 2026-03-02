using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace InventarioMVC.Presentation.Controllers
{
    /// <summary>
    /// Controlador de autenticación que gestiona el login y logout de usuarios.
    /// </summary>
    public class AuthController : Controller
    {
        private readonly ILogger<AuthController> _logger;

        /// <summary>
        /// Constructor del controlador de autenticación.
        /// </summary>
        /// <param name="logger">Servicio de logging para registrar eventos de autenticación.</param>
        public AuthController(ILogger<AuthController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Obtiene la página de login. Si el usuario ya está autenticado, lo redirige al inventario.
        /// </summary>
        /// <returns>Vista de login o redirección al inventario si ya está autenticado.</returns>
        [HttpGet]
        public IActionResult Login()
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "MovInventario");
            }
            return View();
        }

        /// <summary>
        /// Procesa el login del usuario. Valida las credenciales y crea una sesión autenticada.
        /// </summary>
        /// <param name="email">Email del usuario.</param>
        /// <param name="password">Contraseña del usuario.</param>
        /// <returns>Redirección al inventario si el login es exitoso, o vuelve a la vista de login si falla.</returns>
        [HttpPost]
        public async Task<IActionResult> Login(string email, string password)
        {
            if (ValidarCredenciales(email, password))
            {
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Email, email),
                    new Claim(ClaimTypes.NameIdentifier, email),
                    new Claim("NombreUsuario", ObtenerNombreUsuario(email)),
                    new Claim(ClaimTypes.Role, ObtenerRol(email))
                };

                var claimsIdentity = new ClaimsIdentity(claims, "CookieAuth");
                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
                };

                await HttpContext.SignInAsync("CookieAuth", new ClaimsPrincipal(claimsIdentity), authProperties);

                _logger.LogInformation($"Usuario {email} inició sesión correctamente");
                return RedirectToAction("Index", "MovInventario");
            }

            _logger.LogWarning($"Intento de login fallido para usuario {email}");
            ViewBag.Error = "Email o contraseña incorrectos";
            return View();
        }

        /// <summary>
        /// Cierra la sesión del usuario autenticado y lo redirige a la página de login.
        /// </summary>
        /// <returns>Redirección a la página de login.</returns>
        [HttpPost]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync("CookieAuth");
            _logger.LogInformation("Usuario cerró sesión");
            return RedirectToAction("Login", "Auth");
        }

        /// <summary>
        /// Muestra la página de acceso denegado cuando un usuario no tiene permisos.
        /// </summary>
        /// <returns>Vista de acceso denegado.</returns>
        public IActionResult AccessDenied()
        {
            return View();
        }

        private bool ValidarCredenciales(string email, string password)
        {
            var usuarios = new Dictionary<string, string>
            {
                { "admin@empresa.com", "Admin@123456" },
                { "manager@empresa.com", "Manager@123456" },
                { "user@empresa.com", "User@123456" }
            };

            return usuarios.ContainsKey(email) && usuarios[email] == password;
        }

        private string ObtenerNombreUsuario(string email)
        {
            return email.Split('@')[0].ToUpper();
        }

        private string ObtenerRol(string email)
        {
            return email switch
            {
                "admin@empresa.com" => "Admin",
                "manager@empresa.com" => "Gerente",
                "user@empresa.com" => "Usuario",
                _ => "Usuario"
            };
        }
    }
}
