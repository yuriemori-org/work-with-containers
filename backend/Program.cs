var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => new { message = "Hello World from Backend!" });

app.MapGet("/health", () => new { status = "OK" });

app.Run();
