using Serilog;
using FluentValidation.AspNetCore;
using InventarioMVC.Application.Extensions;
using InventarioMVC.Infrastructure.Extensions;
using InventarioMVC.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// ========== Configuración de Logging con Serilog ==========
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .WriteTo.Console()
    .WriteTo.File("logs/inventario-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// ========== Configuración de Servicios de Capas ==========
builder.Services
    .AddApplicationServices()
    .AddInfrastructureServices(builder.Configuration);

// ========== Configuración de Autenticación ==========
builder.Services.AddAuthentication("CookieAuth")
    .AddCookie("CookieAuth", options =>
    {
        options.LoginPath = "/Auth/Login";
        options.LogoutPath = "/Auth/Logout";
        options.AccessDeniedPath = "/Auth/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
    });

builder.Services.AddAuthorization();

// ========== Configuración de Sesión ==========
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// ========== Configuración de MVC y Validación ==========
builder.Services
    .AddFluentValidationAutoValidation()
    .AddFluentValidationClientsideAdapters();

builder.Services
    .AddControllersWithViews()
    .AddRazorRuntimeCompilation();

builder.Services.AddLogging();

// ========== Compilar aplicación ==========
var app = builder.Build();

// ========== Aplicar Migraciones Automáticamente ==========
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<InventarioDbContext>();
        context.Database.EnsureCreated();
        Log.Information("Base de datos verificada/inicializada exitosamente");
    }
    catch (Exception ex)
    {
        Log.Error(ex, "Error al inicializar la base de datos");
    }
}

// ========== Middleware y Pipeline HTTP ==========
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseStaticFiles();
app.UseSession();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// ========== Mapeo de Rutas ==========
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Auth}/{action=Login}/{id?}");

app.MapControllerRoute(
    name: "movInventario",
    pattern: "{controller=MovInventario}/{action=Index}/{id?}");

Log.Information("Aplicación iniciada correctamente");
app.Run();
