using System.ComponentModel.DataAnnotations;
using GameStore.Api.Entities;

namespace GameStore.Api.Dtos;

public record class CreateGameDto(

   [Required][StringLength(50)] string Name,
    int GenreId,
    [Range(1, 100)] decimal Price,
    DateOnly ReleaseDate)
{
    internal Game ToEntity()
    {
        return new Game
        {
            Name = this.Name,
            GenreId = this.GenreId,
            Price = this.Price,
            ReleaseDate = this.ReleaseDate
        };
    }
}
