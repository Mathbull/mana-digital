using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Data;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions <AppDbContext> options): base(options) { }
    public DbSet<Usuario> Usuarios => Set<Usuario>();
}