using GameStore.Api.Data;
using GameStore.Api.Dtos;
using GameStore.Api.Entities;
// using GameStore.Api.Mapping; // Removed because the namespace does not exist or is not needed
using Microsoft.EntityFrameworkCore;

namespace GameStore.Api.Endpoints;

public static class GamesEndPoints
{
    const string GetGameEndpoint = "GetGame";

    public static RouteGroupBuilder MapGamesEndPoints(this WebApplication app)
    {
        var group = app.MapGroup("games")
                        .WithParameterValidation();



        // GET /games
        group.MapGet("/", async (GameStoreContext db) =>
        {
            var games = await db.Games
                                .AsNoTracking()
                                .Include(g => g.Genre)
                                .Select(g => new GameSummaryDto(
                                    g.Id,
                                    g.Name,
                                    g.GenreId,
                                    g.Genre != null ? g.Genre.Name : "Unknown",
                                    g.Price,
                                    g.ReleaseDate))
                                .ToListAsync();

            return Results.Ok(games);
        });

        // GET /games/{id}
        group.MapGet("/{id}", async (int id, GameStoreContext db) =>
        {
            var game = await db.Games
                               .AsNoTracking()
                               .Include(g => g.Genre)
                               .FirstOrDefaultAsync(g => g.Id == id);

            if (game is null) 
                return Results.NotFound();

            return Results.Ok(game.ToGameDetailsDto());
        })
        .WithName(GetGameEndpoint);

        // POST /games
        group.MapPost("/", async (CreateGameDto dto, GameStoreContext db) =>
        {
            var game = dto.ToEntity();

            // ensure genre exists and attach
            if (dto.GenreId != 0)
            {
                var genre = await db.Genres.FindAsync(dto.GenreId);
                if (genre == null) return Results.BadRequest($"Genre with id {dto.GenreId} not found.");
                game.Genre = genre;
            }

            db.Games.Add(game);
            await db.SaveChangesAsync();

            return Results.CreatedAtRoute(GetGameEndpoint, new { id = game.Id }, game.ToGameDetailsDto());
        });

        // PUT /games/{id}
        group.MapPut("/{id}", async (int id, UpdateGameDto dto, GameStoreContext db) =>
        {
            var existing = await db.Games.Include(g => g.Genre).FirstOrDefaultAsync(g => g.Id == id);
            if (existing is null) return Results.NotFound();

            existing.Name = dto.Name;
            existing.Price = dto.Price;
            existing.ReleaseDate = dto.ReleaseDate;
            existing.GenreId = dto.GenreId;

            if (dto.GenreId != 0)
            {
                var genre = await db.Genres.FindAsync(dto.GenreId);
                if (genre == null) return Results.BadRequest($"Genre with id {dto.GenreId} not found.");
                existing.Genre = genre;
            }

            await db.SaveChangesAsync();
            return Results.Ok(existing.ToGameDetailsDto());
        });

        // DELETE /games/{id}
        group.MapDelete("/{id}", async (int id, GameStoreContext db) =>
        {
            var existing = await db.Games.FindAsync(id);
            if (existing is null) return Results.NotFound();

            db.Games.Remove(existing);
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return group;
    }

}

public record class GameSummaryDto(
    int Id,
    string Name,
    int GenreId,
    string Genre,
    decimal Price,
    DateOnly ReleaseDate
);