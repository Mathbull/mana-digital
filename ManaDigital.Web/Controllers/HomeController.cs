using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Controllers;

[Authorize] // Só acessa se estiver autenticado no sistema!
public class HomeController : Controller
{
    public IActionResult Index()
    {
        // Pega o nome do usuário logado para exibir se quiser
        ViewBag.NomeUsuario = User.Identity?.Name ?? "Operador";
        return View();
    }

    // Ação para deslogar (sair)
     public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync();
        return RedirectToAction("Login", "Account");
    }
}
