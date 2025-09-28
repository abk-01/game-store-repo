using GameStore.Api.Dtos;

namespace GameStore.Api.Entities;

public class Game
{
    public int Id { get; set; }

    public required string Name { get; set; }

    public int GenreId { get; set; }
    public Genre? Genre { get; set; }

    public decimal Price { get; set; }

    public DateOnly ReleaseDate { get; set; }

    internal GameDetailsDto ToGameDetailsDto()
    {
        return new GameDetailsDto(
            this.Id,
            this.Name,
            this.GenreId,
            this.Price,
            this.ReleaseDate
        );
    }

    internal GameSummaryDto ToGameSummaryDto()
    {
        return new GameSummaryDto(
            this.Id,
            this.Name,
            this.Genre!.Name,
            this.Price,
            this.ReleaseDate
        );
    }
}