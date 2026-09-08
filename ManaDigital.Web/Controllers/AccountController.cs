using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using ManaDigital.Web.Data;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Controllers;

public class AccountController : Controller
{
    private readonly AppDbContext _context;
    private readonly PasswordHasher<Usuario> _passwordHasher;

    public AccountController(AppDbContext context)
    {
        _context = context;
        _passwordHasher = new PasswordHasher<Usuario>();
    }

    // ==========================================
    // PARTE 1: MVC (Para o Navegador)
    // ==========================================

    [HttpGet]
    public IActionResult Login()
    {
        return View(); // Devolve a tela HTML bonita que você fez
    }

    [HttpPost]
    public async Task<IActionResult> Login(string email, string password)
    {
        var user = await _context.Usuarios.FirstOrDefaultAsync (u => u.Email == email);
        if (user == null)
        {
            ViewBag.Error = "E-mail ou senha Inválidos.";
            return View();
        }

        var result = _passwordHasher.VerifyHashedPassword(user, user.SenhaHash, password);
        if(result == PasswordVerificationResult.Failed)
        {
            ViewBag.Error = "E-mail ou senha inválidos.";
            return View();
        }

        // Cria sessão de login no navegador (Cookie)
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Nome),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Cargo)
        };

        var identify = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identify));

        return RedirectToAction("Index", "Home");   // Redireciona para o Painel
    }

    [HttpPost]
    public async Task<IActionResult> Register(string name, string email, string password, string access_role)
    {   
        // 1. Se o e-mail já existe, avisa na tela
        var usuarioExixtente = await _context.Usuarios.AnyAsync( u => u.Email == email);
        if (usuarioExixtente != null)
        {
            ViewBag.Error = "Este e-mail já está cadastrado! Alterne para a aba 'Entrar' e faça login.";
            return View("Login");
        }

        // 2. Cria o novo usuário
        var novoUsuario = new Usuario
        {
            Nome = name,
            Apelido = name.Split(' ')[0],
            Email = email,
            Cargo = (access_role == "admin") ? "adm": "comum",
            Pontos = 50 // Bônus de 50 XP do card gamificado!
        };

        novoUsuario.SenhaHash = _passwordHasher.HashPassword(novoUsuario, password);

        _context.Usuarios.Add(novoUsuario);
        await _context.SaveChangesAsync();

        // 3. LOGIN AUTOMÁTICO: Cria o cookie de autenticação na hora
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, novoUsuario.Id.ToString()),
            new Claim(ClaimTypes.Name, novoUsuario.Nome),
            new Claim(ClaimTypes.Email, novoUsuario.Email),
            new Claim(ClaimTypes.Role, novoUsuario.Cargo)
        };

        var identify = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identify));


        // 4. Redireciona direto para a página Home!
        return RedirectToAction("Index", "Home");
    }

    // ==========================================
    // PARTE 2: API REST (Para o Flutter do Wesley/Matheus)
    // ==========================================

    [HttpPost("api/auth/login")]
    public async Task<IActionResult> ApiLogin([FromBody] LoginRequest request)
    {
        var user = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == request.Email);
        if (user == null) return Unauthorized(new { message = "Credenciais inválidas" });

        var verify = _passwordHasher.VerifyHashedPassword(user, user.SenhaHash, request.Password);
        if (verify == PasswordVerificationResult.Failed)
            return Unauthorized(new { message = "Credenciais inválidas" });

        return Ok(new
        {
            id = user.Id,
            nome = user.Nome,
            apelido = user.Apelido,
            email = user.Email,
            cargo = user.Cargo,
            pontos = user.Pontos
        });
    }

    [HttpPost("api/auth/register")]
    public async Task<IActionResult> ApiRegister([FromBody] RegisterRequest request)
    {
        if (await _context.Usuarios.AnyAsync(u => u.Email == request.Email))
            return BadRequest(new { message = "E-mail já cadastrado" });

        var novoUsuario = new Usuario
        {
            Nome = request.Name,
            Apelido = request.Name.Split(' ')[0],
            Email = request.Email,
            Cargo = "comum",
            Pontos = 50
        };

        novoUsuario.SenhaHash = _passwordHasher.HashPassword(novoUsuario, request.Password);

        _context.Usuarios.Add(novoUsuario);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Usuário cadastrado com sucesso!", pontos = novoUsuario.Pontos });
    }
}

// DTOs para o Flutter mandar os JSONs limpos
public record LoginRequest(string Email, string Password);
public record RegisterRequest(string Name, string Email, string Password);
