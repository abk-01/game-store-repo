
using GameStore.Api.Data;
using GameStore.Api.Endpoints;
using Microsoft.AspNetCore.Builder;

var builder = WebApplication.CreateBuilder(args);

var connString = builder.Configuration.GetConnectionString("GameStore");
builder.Services.AddSqlite<GameStoreContext>(connString);

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// Add Swagger/OpenAPI services







var app = builder.Build();

// Configure the HTTP request pipeline

// Serve static files from wwwroot (index.html will be served at root)
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseRouting();

app.UseCors();
app.MapGet("/test", () => "Test endpoint works!");
app.MapGamesEndPoints(); // your game CRUD endpoints

app.MapGenresEndPoints();


await app.MigrateDb();

app.Run();


