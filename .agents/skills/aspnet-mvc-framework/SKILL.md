---
name: aspnet-mvc-framework
description: >
  Work on ASP.NET MVC 5 / .NET Framework 4.x web projects (classic csproj
  layout, Razor views, ADO.NET with System.Data.SqlClient). Covers building
  with MSBuild, running under IIS Express, registering files in the .csproj,
  bundling, Web.config connection strings to SQL Server or LocalDB,
  parameterized ADO.NET data access, and verifying Razor pages by request.
  Use for .NET Framework MVC tasks: adding models, controllers, or views,
  fixing build or Razor errors, writing a data access layer, wiring bundles,
  or "run the MVC app". Not for ASP.NET Core, Blazor, Web Forms, or .NET
  SDK-style projects.
---

# ASP.NET MVC on .NET Framework

For classic System.Web MVC projects: a Visual Studio solution with
`packages.config`, a project folder holding `Web.config`, and IIS Express as
the runner. Verified against a fresh MVC 5.2.9 template on net48.

## Stack facts

- .NET Framework 4.8, ASP.NET MVC 5, Razor 3 views.
- C# compiles through Roslyn (Microsoft.CodeDom.Providers.DotNetCompilerPlatform);
  stay within C# 7-era syntax unless the project proves more.
- Frontend: Bootstrap 5, jQuery 3, jquery.validate.unobtrusive. Assets are
  declared as bundles in `App_Start/BundleConfig.cs` and rendered with
  `@Scripts.Render` / `@Styles.Render`.
- NuGet uses `packages.config` (not PackageReference) and restores into a
  solution-level `packages/` folder.

## Project wiring

- `Global.asax.cs` -> `Application_Start` registers areas, filters, routes,
  bundles.
- Routes: `App_Start/RouteConfig.cs`; the default pattern is
  `{controller}/{action}/{id}`.
- Views: `Views/<Controller>/<Action>.cshtml`; layout in
  `Views/Shared/_Layout.cshtml`; `_ViewStart.cshtml` selects it.
  `Views/Web.config` holds the Razor namespaces.

## Adding a feature

1. Model: plain class under `Models/`; DataAnnotations for validation.
2. Controller action under `Controllers/`; return `View(model)`. Form POST
   actions use `[HttpPost]`, `ModelState.IsValid`, `[ValidateAntiForgeryToken]`,
   and `@Html.AntiForgeryToken()` in the view.
3. View: strongly typed `@model` with `@Html.*` helpers.
4. Register every new `.cs`, `.cshtml`, and content file in the `.csproj`
   (`<Compile Include>`, `<Content Include>`, `<None Include>`). This project
   system does not glob: a file that is not listed is not compiled.
5. New script or stylesheet: add it to `App_Start/BundleConfig.cs` instead of
   hardcoding `<script>` or `<link>` paths.

## ADO.NET data access

- Connection string in `Web.config` under `<connectionStrings>`:

```xml
<add name="AppDb" connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=AppDb;Integrated Security=True" providerName="System.Data.SqlClient" />
```

  LocalDB alternative:
  `Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=AppDb;Integrated Security=True`.
- `System.Data.SqlClient` ships with .NET Framework; do not add a NuGet
  package for it.
- Pattern: one small data-access class per aggregate under a `DAL/` (or
  `Data/`) folder. `using` every `SqlConnection` / `SqlCommand` /
  `SqlDataReader`; always parameterized queries, never string concatenation:

```csharp
using (var conn = new SqlConnection(connString))
using (var cmd = new SqlCommand("SELECT Id, Name FROM Recipes WHERE Name LIKE @q", conn))
{
    cmd.Parameters.AddWithValue("@q", "%" + keyword + "%");
    conn.Open();
    using (var reader = cmd.ExecuteReader()) { /* map rows to models */ }
}
```

- Multi-table writes (for example recipe + ingredients) go in one
  `SqlTransaction`.
- Inspect the database from the CLI. ODBC Driver 18 needs `-C` to accept the
  local instance's self-signed certificate:
  `sqlcmd -S .\SQLEXPRESS -E -C -Q "SELECT name FROM sys.databases"`.

## Build

```powershell
# From the solution root (the folder with the .sln):
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
& $msbuild (Get-ChildItem *.sln | Select-Object -First 1).FullName /p:Configuration=Debug /v:m /nologo
```

- Fresh clone: restore `packages/` first. Visual Studio restores on build;
  from the CLI use NuGet.exe `restore` (packages.config is not restored by
  `dotnet restore`).

## Run and verify

```powershell
# IIS Express serves the project folder that contains Web.config (not the
# solution root). Pick a free port.
& "C:\Program Files\IIS Express\iisexpress.exe" /path:"$pwd\WebApp" /port:8080

# In another shell, verify the app responds:
(Invoke-WebRequest http://localhost:8080/ -UseBasicParsing).StatusCode  # expect 200
```

- Build before running: IIS Express serves the compiled `bin/` output.
- Stop the IIS Express process when done.

## Traps

- `MvcBuildViews` is false by default: a green build does not prove Razor
  views compile. Request each changed page and check the status code.
- Bootstrap 5 JavaScript needs Popper: the navbar toggler and dropdowns work
  only when the bundle includes `bootstrap.bundle.js`. The default
  `BundleConfig` references `bootstrap.js` alone.
- Adding a NuGet package means editing `packages.config`, the csproj
  references, and, when versions collide, `Web.config` binding redirects.
  Prefer what is already installed.
- Runtime failures show as the yellow ASP.NET error page (or
  `Views/Shared/Error.cshtml`), not in the build log. Read the exception text
  from the HTTP response.
- The `.csproj` also carries per-configuration output paths; keep Debug/Release
  in sync when editing it.

## Boundaries

- Not for ASP.NET Core, .NET 5+ MVC, Blazor, Web Forms, or SDK-style csproj
  (`<Project Sdk=...>`).
- Keep project-specific requirements in the project's own docs, not here.
