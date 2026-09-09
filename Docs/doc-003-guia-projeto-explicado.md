# Mana Digital Web: explicacao completa do projeto

Este documento explica o projeto `ManaDigital.Web` de um jeito simples, como se estivéssemos desmontando um brinquedo para descobrir o que cada peca faz.

A ideia nao e decorar nomes. A ideia e entender o caminho que uma informacao faz:

```text
Pessoa abre uma URL
        |
        v
ASP.NET Core encontra uma rota
        |
        v
Um Controller decide o que fazer
        |
        +--> devolve uma View HTML para o navegador
        |
        +--> consulta ou grava dados no PostgreSQL
        |
        +--> devolve JSON para o aplicativo Flutter
```

---

## 1. O que e este projeto?

O Mana Digital e uma plataforma de treinamento corporativo sobre diversidade etnico-racial, com elementos de gamificacao.

A solucao foi pensada para ter dois tipos de usuarios tecnicos:

1. **Pessoa usando um navegador**
   - Acessa paginas HTML.
   - Faz login e cadastro.
   - Entra em uma area protegida.
   - Esse lado usa MVC e cookies.

2. **Aplicativo Flutter**
   - Nao precisa receber uma pagina HTML completa.
   - Envia e recebe dados no formato JSON.
   - Usa endpoints de API.
   - No planejamento do projeto, a ideia e autenticar o Flutter com token JWT, mas o codigo atual ainda devolve os dados do login sem criar um JWT.

A mesma aplicacao ASP.NET Core pode atender os dois lados. Ela pode devolver uma pagina para o navegador e, em outra URL, devolver dados JSON para o celular.

---

## 2. O que significa MVC?

MVC significa:

- **M: Model**
- **V: View**
- **C: Controller**

Imagine um restaurante:

- O **Model** e a ficha que diz quais ingredientes existem e como um prato e representado.
- A **View** e o prato servido ao cliente.
- O **Controller** e o garcom: recebe o pedido, conversa com a cozinha e entrega o resultado.

No projeto:

```text
Model      = Usuario.cs
View       = Views/Account/Login.cshtml
Controller = Controllers/AccountController.cs
```

### 2.1. Model

O Model representa os dados do sistema.

O arquivo `Models/Usuario.cs` representa uma pessoa cadastrada. Ele possui propriedades como:

```csharp
public Guid Id { get; set; }
public string Email { get; set; }
public string SenhaHash { get; set; }
public string Nome { get; set; }
public string Apelido { get; set; }
public string Cargo { get; set; }
public int Pontos { get; set; }
```

A classe tambem usa atributos para explicar ao Entity Framework como cada propriedade se relaciona com o banco:

```csharp
[Table("usuarios")]
public class Usuario
```

Isso diz que a classe `Usuario` representa a tabela `usuarios`.

Outro exemplo:

```csharp
[Column("senha_hash")]
public string SenhaHash { get; set; }
```

Isso diz que a propriedade C# `SenhaHash` corresponde a coluna `senha_hash` no banco.

### 2.2. View

A View e o arquivo que produz a pagina enviada para o navegador.

Exemplos:

```text
Views/Account/Login.cshtml
Views/Home/Index.cshtml
Views/Shared/_Layout.cshtml
```

O sufixo `.cshtml` significa que o arquivo mistura HTML com Razor.

HTML normal:

```html
<h1>Login</h1>
```

Razor/C# dentro do HTML:

```cshtml
@if (ViewBag.Error != null)
{
    <div>@ViewBag.Error</div>
}
```

O navegador nao recebe exatamente o C# do Razor. O servidor executa o Razor primeiro e envia o HTML resultante.

### 2.3. Controller

O Controller recebe a requisicao e escolhe o proximo passo.

Exemplo:

```csharp
public IActionResult Login()
{
    return View();
}
```

Essa action diz: "quando alguem pedir a pagina de login, devolva a View de login".

Outro exemplo:

```csharp
return RedirectToAction("Index", "Home");
```

Essa linha diz: "agora mande o navegador para a action `Index` do `HomeController`."

---

## 3. O mapa de pastas

A pasta principal do projeto e `ManaDigital.Web`.

```text
ManaDigital.Web/
|-- Program.cs
|-- ManaDigital.Web.csproj
|-- appsettings.json
|-- appsettings.Development.json
|-- Controllers/
|   |-- AccountController.cs
|   `-- HomeController.cs
|-- Data/
|   `-- AppDbContext.cs
|-- Models/
|   |-- Usuario.cs
|   `-- ErrorViewModel.cs
|-- Views/
|   |-- _ViewImports.cshtml
|   |-- _ViewStart.cshtml
|   |-- Account/
|   |   |-- _ViewStart.cshtml
|   |   `-- Login.cshtml
|   |-- Home/
|   |   `-- Index.cshtml
|   `-- Shared/
|       |-- _Layout.cshtml
|       `-- Error.cshtml
|-- wwwroot/
|   |-- css/
|   |-- js/
|   `-- lib/
`-- Properties/
    `-- launchSettings.json
```

### 3.1. `Program.cs`

E o ponto de partida da aplicacao.

E nele que o projeto configura:

- banco de dados;
- MVC;
- autenticacao por cookie;
- rotas;
- middleware;
- inicio do servidor.

Uma forma simples de pensar:

```text
Program.cs = quadro de energia e mapa de encanamento da aplicacao
```

### 3.2. `Controllers/`

Contem os Controllers.

Eles respondem as URLs e executam as regras do fluxo web.

### 3.3. `Models/`

Contem as classes que representam os dados.

Hoje existe o Model `Usuario`. No futuro, podem existir Models para:

- leitura;
- video;
- jogo;
- pergunta;
- resposta;
- iniciativa;
- medalha;
- log de pontuacao.

### 3.4. `Data/`

Contem a ponte entre o C# e o banco.

O arquivo importante e `AppDbContext.cs`.

### 3.5. `Views/`

Contem as paginas Razor do MVC.

A organizacao normalmente segue o nome do Controller:

```text
AccountController -> Views/Account/
HomeController    -> Views/Home/
```

### 3.6. `wwwroot/`

Contem arquivos publicos que o navegador pode baixar diretamente:

- CSS;
- JavaScript;
- imagens;
- bibliotecas como Bootstrap e jQuery.

### 3.7. `Properties/launchSettings.json`

Configura como o projeto e iniciado localmente.

Ele informa, por exemplo:

- porta HTTP;
- porta HTTPS;
- ambiente `Development`;
- se o navegador deve abrir automaticamente.

Ele nao define as regras do login e nao consulta o banco.

### 3.8. `bin/` e `obj/`

Sao pastas geradas pelo .NET durante compilacao e execucao.

Elas normalmente nao devem ser versionadas no Git. Em geral, entram no `.gitignore`:

```gitignore
bin/
obj/
```

---

## 4. O que acontece quando a aplicacao inicia?

A aplicacao começa em `Program.cs`.

### 4.1. Criacao do construtor

```csharp
var builder = WebApplication.CreateBuilder(args);
```

Aqui o .NET cria um objeto que ajuda a montar a aplicacao.

Esse objeto conhece:

- configuracoes;
- servicos;
- ambiente;
- argumentos de inicializacao.

### 4.2. Registro do banco

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DefaultConnection")));
```

Vamos separar essa linha:

1. `AddDbContext<AppDbContext>` registra o contexto do banco no sistema de injecao de dependencia.
2. `GetConnectionString("DefaultConnection")` procura a configuracao com esse nome.
3. `UseNpgsql` informa que o banco e PostgreSQL e que o provedor sera o Npgsql.

Depois, quando um Controller pede `AppDbContext` no construtor, o ASP.NET entrega uma instancia pronta.

O Controller faz isso:

```csharp
public AccountController(AppDbContext context)
{
    _context = context;
}
```

Isso se chama **injecao de dependencia**.

Em vez de o Controller criar sozinho a conexao, o ASP.NET entrega o objeto que foi configurado no `Program.cs`.

### 4.3. Registro do MVC

```csharp
builder.Services.AddControllersWithViews();
```

Essa linha habilita Controllers que podem devolver Views.

Por isso o projeto consegue executar:

```csharp
return View();
```

### 4.4. Registro da autenticacao por cookie

```csharp
builder.Services.AddAuthentication(
    CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/Denied";
    });
```

Aqui o projeto escolhe cookies como forma de lembrar que uma pessoa fez login.

O cookie e um pequeno identificador que o navegador guarda e envia nas proximas requisicoes.

O cookie nao deve guardar a senha. Ele representa a sessao autenticada.

`LoginPath` diz para onde enviar uma pessoa que tentou acessar uma pagina protegida sem estar logada.

`AccessDeniedPath` seria o caminho para uma pagina de acesso negado. Atualmente e importante verificar se existe uma action/view `Denied`, porque a configuracao aponta para ela.

### 4.5. Construir a aplicacao

```csharp
var app = builder.Build();
```

A partir daqui, o objeto `app` representa o servidor configurado.

### 4.6. Middleware

Middleware e como uma fila de porteiros. Cada um olha a requisicao e pode:

- deixar passar;
- alterar algo;
- interromper;
- encaminhar para o proximo.

No projeto:

```csharp
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
```

A ordem importa.

- `UseHttpsRedirection`: tenta levar HTTP para HTTPS.
- `UseStaticFiles`: permite servir CSS, JavaScript e imagens.
- `UseRouting`: descobre qual rota combina com a URL.
- `UseAuthentication`: identifica quem e o usuario usando o cookie.
- `UseAuthorization`: verifica se essa pessoa tem permissao.

### 4.7. Rota padrao

```csharp
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

A rota tem tres partes:

```text
/{controller}/{action}/{id?}
```

- `controller`: nome do Controller sem o sufixo `Controller`.
- `action`: nome do metodo.
- `id?`: identificador opcional.

Os valores padrao sao:

```text
controller = Account
action = Login
```

Por isso, acessar a raiz:

```text
http://localhost:5273/
```

tenta abrir:

```text
AccountController.Login()
```

A URL:

```text
/Account/Login
```

tambem chama a action `Login`.

### 4.8. Iniciar o servidor

```csharp
app.Run();
```

A aplicacao fica ouvindo requisicoes do navegador e de outros clientes.

---

## 5. O caminho da pagina de login

Quando a pessoa abre:

```text
/Account/Login
```

acontece isto:

```text
1. O navegador envia uma requisicao GET.
2. O sistema de rotas procura AccountController e Login.
3. A action GET Login e escolhida.
4. A action executa return View().
5. O Razor procura Views/Account/Login.cshtml.
6. O Razor transforma o arquivo em HTML.
7. O HTML vai para o navegador.
```

A action e:

```csharp
[HttpGet]
public IActionResult Login()
{
    return View();
}
```

O atributo `[HttpGet]` significa que essa action atende uma requisicao GET.

GET normalmente significa: "quero buscar e mostrar alguma coisa".

---

## 6. Por que `Login.cshtml` nao usa o layout normal?

Existe um `_ViewStart.cshtml` geral:

```cshtml
@{
    Layout = "_Layout";
}
```

Ele normalmente faz todas as Views usarem `Views/Shared/_Layout.cshtml`.

Mas dentro de `Views/Account/` existe outro `_ViewStart.cshtml`:

```cshtml
@{
    Layout = null;
}
```

Como esse arquivo esta mais perto de `Views/Account/Login.cshtml`, ele sobrescreve a regra geral.

Resultado:

```text
Login.cshtml -> nao usa Shared/_Layout.cshtml
```

Isso e util porque a tela de login tem um visual proprio e nao deve mostrar o menu interno da aplicacao.

A Home, por outro lado, continua usando o layout geral, porque esta em `Views/Home/` e nao possui um `_ViewStart.cshtml` local com `Layout = null`.

---

## 7. O cadastro pelo navegador

O cadastro usa a action:

```csharp
[HttpPost]
public async Task<IActionResult> Register(
    string name,
    string email,
    string password,
    string access_role)
```

POST normalmente significa: "estou enviando dados para criar ou alterar algo".

O caminho e:

```text
1. Pessoa preenche o formulario.
2. O navegador envia POST para /Account/Register.
3. O Controller recebe name, email, password e access_role.
4. O sistema procura um usuario com o mesmo e-mail.
5. Se ja existir, volta para Login com uma mensagem.
6. Se nao existir, cria um objeto Usuario.
7. A senha vira um hash.
8. O novo usuario e salvo no banco.
9. Um cookie de autenticacao e criado.
10. A pessoa e redirecionada para Home/Index.
```

### 7.1. Verificacao de e-mail repetido

```csharp
var usuarioExistente = await _context.Usuarios
    .AnyAsync(u => u.Email == email);
```

`_context.Usuarios` representa a tabela de usuarios.

`AnyAsync` pergunta:

> Existe pelo menos um usuario cujo e-mail seja igual ao e-mail recebido?

O resultado e `true` ou `false`.

### 7.2. Criacao do objeto

```csharp
var novoUsuario = new Usuario
{
    Nome = name,
    Apelido = name.Split(' ')[0],
    Email = email,
    Cargo = (access_role == "admin") ? "adm" : "comum",
    Pontos = 50
};
```

Aqui nasce um objeto em memoria.

Ele ainda nao esta salvo no banco apenas porque foi criado com `new`.

### 7.3. Hash da senha

```csharp
novoUsuario.SenhaHash =
    _passwordHasher.HashPassword(novoUsuario, password);
```

A senha original nao deve ser salva diretamente.

Exemplo perigoso:

```text
senha_hash = 123456
```

O correto e salvar um resultado embaralhado, chamado hash.

Importante: hash nao e o mesmo que criptografia reversivel. A aplicacao nao precisa descobrir a senha original. Ela compara uma nova tentativa com o hash salvo.

### 7.4. Salvamento

```csharp
_context.Usuarios.Add(novoUsuario);
await _context.SaveChangesAsync();
```

A primeira linha coloca o objeto na fila de alteracoes do Entity Framework.

A segunda envia a alteracao para o PostgreSQL.

Sem `SaveChangesAsync`, criar o objeto em memoria nao cria uma linha no banco.

### 7.5. Login automatico depois do cadastro

Depois de salvar, o projeto cria claims e chama:

```csharp
await HttpContext.SignInAsync(
    CookieAuthenticationDefaults.AuthenticationScheme,
    new ClaimsPrincipal(identity));
```

Isso cria o cookie que diz ao navegador:

> Esta pessoa foi autenticada.

Por isso o cadastro atual tenta levar a pessoa direto para Home.

---

## 8. O login pelo navegador

O login possui duas actions com o mesmo nome, mas verbos HTTP diferentes.

### 8.1. GET Login

```csharp
[HttpGet]
public IActionResult Login()
{
    return View();
}
```

Serve para mostrar o formulario.

### 8.2. POST Login

```csharp
[HttpPost]
public async Task<IActionResult> Login(string email, string password)
```

Serve para receber os dados digitados.

O caminho esperado e:

```text
1. O formulario envia POST para Account/Login.
2. Os campos precisam chegar com os nomes email e password.
3. O Controller procura o e-mail no banco.
4. Se nao encontrar, mostra erro.
5. Se encontrar, compara a senha recebida com SenhaHash.
6. Se a senha estiver errada, mostra erro.
7. Se estiver certa, cria claims.
8. SignInAsync cria o cookie.
9. RedirectToAction leva para Home/Index.
```

A busca e:

```csharp
var user = await _context.Usuarios
    .FirstOrDefaultAsync(u => u.Email == email);
```

`FirstOrDefaultAsync` significa:

> Pegue o primeiro usuario que combina; se nenhum combinar, devolva null.

A validacao da senha e:

```csharp
var result = _passwordHasher.VerifyHashedPassword(
    user,
    user.SenhaHash,
    password);
```

A senha digitada e comparada com o hash salvo.

O sistema nunca precisa comparar simplesmente:

```csharp
password == user.SenhaHash
```

Isso estaria errado porque o hash nao e a senha original.

---

## 9. O que sao Claims?

Claims sao pequenas informacoes sobre a pessoa autenticada.

O projeto cria:

```csharp
new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
new Claim(ClaimTypes.Name, user.Nome)
new Claim(ClaimTypes.Email, user.Email)
new Claim(ClaimTypes.Role, user.Cargo)
```

Pense nelas como etiquetas dentro do cracha:

```text
ID    = identificador do usuario
Nome  = nome da pessoa
Email = e-mail da pessoa
Role  = cargo/permissao
```

Depois, a aplicacao consegue ler essas informacoes pelo objeto `User`.

Na Home existe:

```csharp
ViewBag.NomeUsuario = User.Identity?.Name ?? "Operador";
```

Isso tenta pegar o nome guardado na claim `ClaimTypes.Name`.

---

## 10. Como a Home fica protegida?

O `HomeController` possui:

```csharp
[Authorize]
public class HomeController : Controller
```

`[Authorize]` significa:

> So pode executar este Controller quem estiver autenticado.

Se uma pessoa nao logada tentar acessar `/Home/Index`, o middleware de autorizacao percebe que ela nao tem um cookie valido e redireciona para:

```text
/Account/Login
```

Isso funciona porque o `Program.cs` configurou:

```csharp
options.LoginPath = "/Account/Login";
```

A Home tem:

```csharp
public IActionResult Index()
{
    ViewBag.NomeUsuario = User.Identity?.Name ?? "Operador";
    return View();
}
```

A action recebe a requisicao e entrega `Views/Home/Index.cshtml`.

Hoje essa View ainda tem o conteudo padrao do template MVC, com o texto `Welcome`. O dashboard gamificado descrito nos documentos ainda precisa ser construido.

---

## 11. Como funciona o logout?

A action da Home e:

```csharp
public async Task<IActionResult> Logout()
{
    await HttpContext.SignOutAsync();
    return RedirectToAction("Login", "Account");
}
```

O caminho e:

```text
1. Pessoa acessa a rota de logout.
2. SignOutAsync remove a autenticacao do cookie.
3. A pessoa deixa de ser considerada logada.
4. O navegador volta para a tela de login.
```

Depois do logout, acessar a Home novamente deve ativar o `[Authorize]` e redirecionar para Login.

---

## 12. Como o banco aparece no codigo?

O arquivo `Data/AppDbContext.cs` e:

```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    public DbSet<Usuario> Usuarios => Set<Usuario>();
}
```

Pense no `AppDbContext` como uma caixa que representa o banco inteiro.

Dentro dele:

```csharp
DbSet<Usuario> Usuarios
```

representa a colecao de linhas da tabela `usuarios`.

Por isso o Controller usa:

```csharp
_context.Usuarios
```

O nome precisa ser exatamente igual ao nome da propriedade. C# diferencia nomes escritos de forma diferente.

### 12.1. Entity Framework Core

O Entity Framework Core e um tradutor.

Voce escreve C#:

```csharp
_context.Usuarios.FirstOrDefaultAsync(
    u => u.Email == email)
```

E o Entity Framework transforma isso em uma consulta SQL apropriada para o PostgreSQL.

Esse estilo e chamado de LINQ.

### 12.2. Npgsql

O Npgsql e o provedor que permite ao .NET conversar com PostgreSQL.

O projeto possui no `.csproj`:

```xml
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" />
```

Sem esse provedor, o Entity Framework nao saberia como abrir uma conexao PostgreSQL.

---

## 13. Configuracao do banco e seguranca

O `Program.cs` procura:

```csharp
GetConnectionString("DefaultConnection")
```

Essa configuracao normalmente fica em:

```text
ConnectionStrings:DefaultConnection
```

Existe uma connection string no `appsettings.json`. Como esse arquivo esta no projeto, a senha nao deve ficar versionada no Git.

A recomendacao e:

1. Trocar a senha do banco se ela ja foi publicada ou compartilhada.
2. Colocar a nova senha em User Secrets, variavel de ambiente ou segredo da plataforma de deploy.
3. Manter no Git apenas uma configuracao sem segredo.
4. Adicionar arquivos sensiveis ao `.gitignore`.

Exemplo de variavel de ambiente no PowerShell:

```powershell
$env:ConnectionStrings__DefaultConnection = "Host=...;Port=5432;Database=...;Username=...;Password=..."
```

Os dois sublinhados representam os dois-pontos da configuracao:

```text
ConnectionStrings__DefaultConnection
        equivale a
ConnectionStrings:DefaultConnection
```

O `.env` nao e lido automaticamente pelo ASP.NET Core. Se a equipe escolher `.env`, precisa configurar uma biblioteca para carrega-lo, ou transformar os valores do ambiente em variaveis que o .NET consiga ler.

Para desenvolvimento local, User Secrets e uma alternativa nativa do .NET.

---

## 14. A parte da API para o Flutter

O mesmo `AccountController` tambem possui actions com rotas de API:

```csharp
[HttpPost("api/auth/login")]
public async Task<IActionResult> ApiLogin(
    [FromBody] LoginRequest request)
```

Essa action atende:

```text
POST /api/auth/login
```

Diferente do login MVC, ela espera JSON no corpo da requisicao.

Exemplo de JSON enviado pelo Flutter:

```json
{
  "email": "pessoa@empresa.com",
  "password": "senha-digitada"
}
```

O parametro:

```csharp
[FromBody] LoginRequest request
```

diz ao ASP.NET:

> Leia o corpo JSON e transforme-o em um objeto LoginRequest.

O record e:

```csharp
public record LoginRequest(string Email, string Password);
```

Se a senha estiver correta, a API devolve JSON:

```json
{
  "id": "...",
  "nome": "...",
  "apelido": "...",
  "email": "...",
  "cargo": "comum",
  "pontos": 50
}
```

Se o usuario nao existir ou a senha estiver errada:

```csharp
return Unauthorized(new { message = "Credenciais inválidas" });
```

Isso normalmente vira uma resposta HTTP `401`.

### 14.1. Cadastro da API

A outra rota e:

```text
POST /api/auth/register
```

Ela recebe:

```json
{
  "name": "Nome da Pessoa",
  "email": "pessoa@empresa.com",
  "password": "senha"
}
```

O codigo cria o usuario, gera o hash e salva no banco.

A API retorna uma mensagem de sucesso, mas nao cria cookie de navegador. Isso faz sentido porque o cliente e o Flutter, nao o navegador MVC.

### 14.2. Diferenca entre MVC e API

| MVC para navegador | API para Flutter |
|---|---|
| Recebe formulario | Recebe JSON |
| Devolve `View()` | Devolve `Ok(...)` com JSON |
| Usa cookie de autenticacao | O planejamento preve JWT |
| URL `/Account/Login` | URL `/api/auth/login` |
| Navegador mostra HTML | Flutter monta a propria tela |

---

## 15. O que e um DTO?

DTO significa Data Transfer Object, ou objeto de transferencia de dados.

No projeto:

```csharp
public record LoginRequest(string Email, string Password);
public record RegisterRequest(string Name, string Email, string Password);
```

Esses records sao formatos pequenos para transportar dados da API.

Eles nao sao a mesma coisa que o Model `Usuario`.

Isso e bom porque a API nao precisa receber ou devolver todos os campos internos do banco.

Por exemplo, a API nao deveria devolver `SenhaHash` para o Flutter.

---

## 16. O fluxo completo do cadastro MVC

Imagine que uma pessoa preenche o cadastro no navegador.

```text
Pessoa
  |
  | POST /Account/Register
  v
AccountController.Register
  |
  | _context.Usuarios.AnyAsync(...)
  v
PostgreSQL: o e-mail ja existe?
  |
  +--> sim: volta para Login com erro
  |
  `--> nao
          |
          v
       cria Usuario
          |
          v
       cria SenhaHash
          |
          v
       Add(novoUsuario)
          |
          v
       SaveChangesAsync()
          |
          v
       cria claims e cookie
          |
          v
       RedirectToAction("Index", "Home")
```

---

## 17. O fluxo completo do login MVC

```text
Pessoa
  |
  | POST /Account/Login
  v
AccountController.Login(email, password)
  |
  | procura o e-mail
  v
Usuario encontrado?
  |
  +--> nao: ViewBag.Error e retorna Login
  |
  `--> sim
          |
          | compara senha com SenhaHash
          v
       senha correta?
          |
          +--> nao: ViewBag.Error e retorna Login
          |
          `--> sim
                  |
                  v
               cria claims
                  |
                  v
               cria cookie
                  |
                  v
               redireciona para Home
```

---

## 18. O formulario precisa conversar com o Controller

Para o Controller receber os valores corretamente, os campos do formulario precisam ter nomes que combinem com os parametros da action.

A action espera:

```csharp
Login(string email, string password)
```

Entao os campos devem enviar:

```html
<input name="email" />
<input name="password" />
```

O `id` ajuda labels e JavaScript. O `name` e o nome usado na submissao do formulario.

Uma confusao comum e esta:

```html
<input id="login-email" />
```

O `id` sozinho nao garante que o valor sera associado ao parametro `email` no model binding.

Outra confusao comum e usar JavaScript assim:

```javascript
event.preventDefault();
```

Essa chamada cancela o envio normal do formulario. Se o JavaScript cancela o envio e apenas mostra uma mensagem bonita, o Controller nunca recebe a requisicao.

O login precisa escolher uma estrategia:

1. **Formulario tradicional MVC:** deixa o navegador enviar o POST para o Controller.
2. **Login via JavaScript:** o JavaScript envia `fetch` para uma API e trata a resposta.

Misturar as duas estrategias sem cuidado costuma fazer aparecer a mensagem de sucesso, mas nunca criar a sessao real.

---

## 19. O que ja existe e o que ainda falta

### Ja existe no codigo

- Projeto ASP.NET Core MVC.
- Rota padrao iniciando em Account/Login.
- Pagina visual de login e cadastro.
- Controller de conta.
- Cadastro MVC.
- Login MVC.
- Hash de senha com `PasswordHasher<Usuario>`.
- Autenticacao por cookie.
- Home protegida com `[Authorize]`.
- Logout por cookie.
- Entity Framework Core.
- Provedor PostgreSQL/Npgsql.
- Model `Usuario`.
- API de login.
- API de cadastro.

### Ainda precisa ser construido ou revisado

- Dashboard real da Home.
- Ranking semanal, mensal e geral.
- Patentes e regras definitivas de pontuacao.
- Medalhas.
- Leituras e perguntas.
- Videos e perguntas.
- Jogos e respostas.
- Iniciativas e aprovacao por administrador.
- Historico de pontuacao.
- Models e tabelas para os modulos acima.
- Autenticacao JWT completa para o Flutter, se essa for a escolha final.
- Validacoes de formulario mais fortes.
- Tratamento de erros do banco.
- Pagina `Denied`, caso o caminho configurado continue sendo usado.
- Protecao contra envio de formulario duplicado.
- Protecao e organizacao das credenciais do banco.

---

## 20. Modelo futuro de tabelas

Os documentos do projeto sugerem entidades como:

```text
usuarios
leituras
videos
jogos
perguntas
respostas
iniciativas
medalhas
usuarios_medalhas
historico_pontuacao
```

Uma leitura poderia ter:

```text
Id
Titulo
Conteudo
Pontos
Ativo
```

Um jogo poderia ter:

```text
Id
Titulo
Descricao
Pontos
```

Uma pergunta poderia ter:

```text
Id
JogoId
Enunciado
Pontos
```

Uma iniciativa poderia ter:

```text
Id
UsuarioId
Tipo
Descricao
Anexo
Status
PontosGanhos
ValidadoPor
Data
```

O historico e importante porque mostra de onde vieram os pontos. Sem ele, o sistema sabe apenas o total, mas nao sabe explicar o total.

---

## 21. Erros comuns e como pensar neles

### 21.1. `AppDbContext` nao possui `Usuario`

Verifique o nome exato da propriedade:

```csharp
public DbSet<Usuario> Usuarios => Set<Usuario>();
```

O uso precisa ser:

```csharp
_context.Usuarios
```

### 21.2. `Failed` escrito errado

Enums e metodos precisam ter o nome exato:

```csharp
PasswordVerificationResult.Failed
```

C# diferencia maiusculas, minusculas e cada letra do nome.

### 21.3. `SignInAsync` ou `SignOutAsync` nao encontrado

Esses metodos sao extensoes. Normalmente e necessario importar:

```csharp
using Microsoft.AspNetCore.Authentication;
```

### 21.4. Erro no formato da connection string

O Npgsql espera algo como:

```text
Host=servidor;Port=5432;Database=banco;Username=usuario;Password=senha
```

Uma URL que começa com `postgresql://` pode exigir tratamento ou conversao dependendo da origem.

### 21.5. Razor interpreta `@layer` como C#

Em `.cshtml`, o caractere `@` inicia Razor. Uma diretiva CSS como `@layer` pode ser interpretada como codigo C# se nao for escapada ou tratada.

### 21.6. Login mostra mensagem, mas nao navega

Verifique:

- o formulario tem `method="post"`;
- o `action` aponta para `/Account/Login`;
- os campos possuem `name="email"` e `name="password"`;
- nao existe `event.preventDefault()` cancelando o envio;
- o banco esta acessivel;
- o e-mail existe;
- a senha foi criada com `PasswordHasher`;
- `SignInAsync` foi executado;
- `HomeController` esta autorizado e a rota existe.

---

## 22. Uma forma simples de depurar

Quando algo nao funcionar, nao tente adivinhar tudo ao mesmo tempo. Siga a viagem da requisicao.

### Passo 1: a pagina abre?

Teste:

```text
/Account/Login
```

Se nao abrir, verifique rota, Controller e View.

### Passo 2: o formulario envia?

Abra as ferramentas do navegador e confira a requisicao na aba Network.

Veja:

- metodo: GET ou POST;
- URL;
- status HTTP;
- dados enviados.

### Passo 3: o Controller entra na action?

Coloque um breakpoint ou um log na primeira linha da action.

Se nao entrar, o problema esta no formulario ou na rota.

### Passo 4: o banco responde?

Se aparece erro do Npgsql, connection string ou banco, o problema esta antes da regra de senha.

### Passo 5: o usuario existe?

Se `user == null`, o e-mail nao foi encontrado ou chegou vazio/diferente.

### Passo 6: a senha combina?

Se o usuario existe, mas `Failed` aparece, a senha digitada nao combina com o hash salvo.

### Passo 7: o cookie foi criado?

Se o login parece dar certo, mas a Home manda de volta para Login, investigue:

- autenticacao registrada;
- `UseAuthentication()` antes de `UseAuthorization()`;
- esquema do cookie;
- navegador bloqueando o cookie;
- HTTPS e configuracoes de cookie.

---

## 23. Resumo em uma frase por arquivo

- `Program.cs`: monta e liga a aplicacao.
- `AccountController.cs`: faz login, cadastro, logout relacionado e API de autenticacao.
- `HomeController.cs`: entrega a Home e exige autenticacao.
- `AppDbContext.cs`: representa a conversa com o banco.
- `Usuario.cs`: descreve os dados de um usuario.
- `Login.cshtml`: desenha a tela de login/cadastro.
- `Index.cshtml`: desenha a Home.
- `Views/_ViewStart.cshtml`: define o layout geral das Views.
- `Views/Account/_ViewStart.cshtml`: remove o layout da tela de login.
- `Shared/_Layout.cshtml`: estrutura comum das paginas internas.
- `appsettings.json`: configuracoes, incluindo a referencia da conexao.
- `launchSettings.json`: portas e ambiente local.
- `ManaDigital.Web.csproj`: framework e pacotes instalados.
- `wwwroot`: arquivos que o navegador acessa diretamente.

---

## 24. A frase mais importante para lembrar

Quando uma pagina ou login falhar, pergunte nesta ordem:

```text
Qual URL foi chamada?
Qual metodo HTTP foi usado?
Qual Controller recebeu?
Qual action executou?
Quais dados chegaram?
O banco respondeu?
A regra deu certo?
Qual resposta voltou para o navegador ou Flutter?
```

Se voce responder essas perguntas, o erro deixa de ser um misterio. Ele vira apenas um ponto especifico do caminho que precisa ser corrigido.
