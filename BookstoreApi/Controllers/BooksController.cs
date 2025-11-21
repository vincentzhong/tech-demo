using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using BookstoreApi.Data;
using BookstoreApi.Models;

namespace BookstoreApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BooksController : ControllerBase
{
    private readonly BookstoreDbContext _context;
    private readonly ILogger<BooksController> _logger;

    public BooksController(BookstoreDbContext context, ILogger<BooksController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all books
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        _logger.LogInformation("Getting all books");
        var books = await _context.Books
            .Include(b => b.Author)
            .ToListAsync();
        
        return Ok(books);
    }

    /// <summary>
    /// Get a specific book by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Book>> GetBook(int id)
    {
        _logger.LogInformation("Getting book with ID: {BookId}", id);
        
        var book = await _context.Books
            .Include(b => b.Author)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (book == null)
        {
            _logger.LogWarning("Book with ID {BookId} not found", id);
            return NotFound(new { message = $"Book with ID {id} not found" });
        }

        return Ok(book);
    }

    /// <summary>
    /// Create a new book
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        _logger.LogInformation("Creating new book: {BookTitle}", book.Title);

        // Validate author exists
        var authorExists = await _context.Authors.AnyAsync(a => a.Id == book.AuthorId);
        if (!authorExists)
        {
            return BadRequest(new { message = $"Author with ID {book.AuthorId} does not exist" });
        }

        // Check if ISBN already exists
        var isbnExists = await _context.Books.AnyAsync(b => b.ISBN == book.ISBN);
        if (isbnExists)
        {
            return BadRequest(new { message = $"Book with ISBN {book.ISBN} already exists" });
        }

        book.CreatedAt = DateTime.UtcNow;
        _context.Books.Add(book);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Book created successfully with ID: {BookId}", book.Id);

        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    /// <summary>
    /// Update an existing book
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBook(int id, Book book)
    {
        if (id != book.Id)
        {
            return BadRequest(new { message = "ID mismatch" });
        }

        _logger.LogInformation("Updating book with ID: {BookId}", id);

        var existingBook = await _context.Books.FindAsync(id);
        if (existingBook == null)
        {
            _logger.LogWarning("Book with ID {BookId} not found for update", id);
            return NotFound(new { message = $"Book with ID {id} not found" });
        }

        // Validate author exists
        var authorExists = await _context.Authors.AnyAsync(a => a.Id == book.AuthorId);
        if (!authorExists)
        {
            return BadRequest(new { message = $"Author with ID {book.AuthorId} does not exist" });
        }

        // Check if ISBN already exists for another book
        var isbnExists = await _context.Books
            .AnyAsync(b => b.ISBN == book.ISBN && b.Id != id);
        if (isbnExists)
        {
            return BadRequest(new { message = $"Another book with ISBN {book.ISBN} already exists" });
        }

        existingBook.Title = book.Title;
        existingBook.ISBN = book.ISBN;
        existingBook.PublishedDate = book.PublishedDate;
        existingBook.Price = book.Price;
        existingBook.AuthorId = book.AuthorId;
        existingBook.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("Book updated successfully with ID: {BookId}", id);
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await BookExists(id))
            {
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }

    /// <summary>
    /// Delete a book
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBook(int id)
    {
        _logger.LogInformation("Deleting book with ID: {BookId}", id);

        var book = await _context.Books.FindAsync(id);
        if (book == null)
        {
            _logger.LogWarning("Book with ID {BookId} not found for deletion", id);
            return NotFound(new { message = $"Book with ID {id} not found" });
        }

        _context.Books.Remove(book);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Book deleted successfully with ID: {BookId}", id);

        return NoContent();
    }

    private async Task<bool> BookExists(int id)
    {
        return await _context.Books.AnyAsync(e => e.Id == id);
    }
}
