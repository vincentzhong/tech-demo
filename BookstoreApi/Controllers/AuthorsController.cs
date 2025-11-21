using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using BookstoreApi.Data;
using BookstoreApi.Models;

namespace BookstoreApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AuthorsController : ControllerBase
{
    private readonly BookstoreDbContext _context;
    private readonly ILogger<AuthorsController> _logger;

    public AuthorsController(BookstoreDbContext context, ILogger<AuthorsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all authors
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Author>>> GetAuthors()
    {
        _logger.LogInformation("Getting all authors");
        var authors = await _context.Authors
            .Include(a => a.Books)
            .ToListAsync();
        
        return Ok(authors);
    }

    /// <summary>
    /// Get a specific author by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Author>> GetAuthor(int id)
    {
        _logger.LogInformation("Getting author with ID: {AuthorId}", id);
        
        var author = await _context.Authors
            .Include(a => a.Books)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (author == null)
        {
            _logger.LogWarning("Author with ID {AuthorId} not found", id);
            return NotFound(new { message = $"Author with ID {id} not found" });
        }

        return Ok(author);
    }

    /// <summary>
    /// Get all books by a specific author
    /// </summary>
    [HttpGet("{id}/books")]
    public async Task<ActionResult<IEnumerable<Book>>> GetAuthorBooks(int id)
    {
        _logger.LogInformation("Getting books for author with ID: {AuthorId}", id);
        
        var authorExists = await _context.Authors.AnyAsync(a => a.Id == id);
        if (!authorExists)
        {
            _logger.LogWarning("Author with ID {AuthorId} not found", id);
            return NotFound(new { message = $"Author with ID {id} not found" });
        }

        var books = await _context.Books
            .Where(b => b.AuthorId == id)
            .Include(b => b.Author)
            .ToListAsync();

        return Ok(books);
    }

    /// <summary>
    /// Create a new author
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Author>> CreateAuthor(Author author)
    {
        _logger.LogInformation("Creating new author: {AuthorName}", author.Name);

        author.CreatedAt = DateTime.UtcNow;
        _context.Authors.Add(author);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Author created successfully with ID: {AuthorId}", author.Id);

        return CreatedAtAction(nameof(GetAuthor), new { id = author.Id }, author);
    }

    /// <summary>
    /// Update an existing author
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateAuthor(int id, Author author)
    {
        if (id != author.Id)
        {
            return BadRequest(new { message = "ID mismatch" });
        }

        _logger.LogInformation("Updating author with ID: {AuthorId}", id);

        var existingAuthor = await _context.Authors.FindAsync(id);
        if (existingAuthor == null)
        {
            _logger.LogWarning("Author with ID {AuthorId} not found for update", id);
            return NotFound(new { message = $"Author with ID {id} not found" });
        }

        existingAuthor.Name = author.Name;
        existingAuthor.Bio = author.Bio;
        existingAuthor.Country = author.Country;
        existingAuthor.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("Author updated successfully with ID: {AuthorId}", id);
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await AuthorExists(id))
            {
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }

    /// <summary>
    /// Delete an author
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAuthor(int id)
    {
        _logger.LogInformation("Deleting author with ID: {AuthorId}", id);

        var author = await _context.Authors
            .Include(a => a.Books)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (author == null)
        {
            _logger.LogWarning("Author with ID {AuthorId} not found for deletion", id);
            return NotFound(new { message = $"Author with ID {id} not found" });
        }

        // Check if author has books
        if (author.Books.Any())
        {
            return BadRequest(new { message = $"Cannot delete author with ID {id} because they have associated books. Delete the books first." });
        }

        _context.Authors.Remove(author);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Author deleted successfully with ID: {AuthorId}", id);

        return NoContent();
    }

    private async Task<bool> AuthorExists(int id)
    {
        return await _context.Authors.AnyAsync(e => e.Id == id);
    }
}
