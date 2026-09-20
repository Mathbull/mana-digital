using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.Cookies;
using ManaDigital.Web.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using ManaDigital.Web.Services;


var builder = WebApplication.CreateBuilder(args);

// 1. Conexão com Supabase (PostgreSQL)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Permite injetar o MedalhaService nos Controllers
builder.Services.AddScoped<MedalhaService>();

// 2. Habilita Controllers com Views (MVC) e Controllers de API
builder.Services.AddControllersWithViews();

// 3. Configura autenticação para o MVC (Navegador)
builder.Services.AddAuthentication(options =>
{
    // Cookie continua sendo usado pelo MVC
    options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;
})
.AddCookie(options =>
{
    options.LoginPath = "/Account/Login";
    options.AccessDeniedPath = "/Account/Denied";
})
.AddJwtBearer(options =>
{
    var jwtKey = builder.Configuration["Jwt:Key"];

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey!)
        ),

        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],

        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],

        ValidateLifetime = true,

        ClockSkew = TimeSpan.Zero
    };
});

// builder.WebHost.UseUrls("http://0.0.0.0:8000");
builder.Services.AddCors(options =>
{
    options.AddPolicy("Flutter", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseCors("Flutter");

app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllers();

// Rota padrão do MVC
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");

app.Run();
