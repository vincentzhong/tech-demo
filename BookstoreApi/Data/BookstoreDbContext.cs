using Microsoft.EntityFrameworkCore;
using BookstoreApi.Models;

namespace BookstoreApi.Data;

public class BookstoreDbContext : DbContext
{
    public BookstoreDbContext(DbContextOptions<BookstoreDbContext> options) 
        : base(options)
    {
    }

    public DbSet<Book> Books { get; set; }
    public DbSet<Author> Authors { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Book entity
        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.ISBN)
                .IsRequired()
                .HasMaxLength(20);
            
            entity.Property(e => e.Price)
                .HasPrecision(18, 2);
            
            entity.Property(e => e.CreatedAt)
                .HasColumnType("datetime")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
            
            // Relationship: One Author has Many Books
            entity.HasOne(e => e.Author)
                .WithMany(a => a.Books)
                .HasForeignKey(e => e.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasIndex(e => e.ISBN)
                .IsUnique();
        });

        // Configure Author entity
        modelBuilder.Entity<Author>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(100);
            
            entity.Property(e => e.Bio)
                .HasMaxLength(1000);
            
            entity.Property(e => e.Country)
                .HasMaxLength(50);
            
            entity.Property(e => e.CreatedAt)
                .HasColumnType("datetime")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
        });

        // Configure User entity
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Username)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.Property(e => e.Email)
                .IsRequired()
                .HasMaxLength(100);
            
            entity.Property(e => e.PasswordHash)
                .IsRequired();
            
            entity.Property(e => e.Role)
                .HasMaxLength(20)
                .HasDefaultValue("User");
            
            entity.Property(e => e.CreatedAt)
                .HasColumnType("datetime")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
            
            entity.HasIndex(e => e.Username)
                .IsUnique();
        });

        // Seed data
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        var baseDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        // NOTE: Demo users are seeded via environment variables for security
        // Set ADMIN_USER and DEMO_USER environment variables in format: username:password
        // Example: ADMIN_USER=admin:securepassword DEMO_USER=demo:password
        // 
        // For local development without env vars set, default demo users will be created
        // This allows easy local testing while keeping production credentials secure
        
        var adminUser = Environment.GetEnvironmentVariable("ADMIN_USER");
        var demoUser = Environment.GetEnvironmentVariable("DEMO_USER");
        
        // Parse admin user credentials
        var (adminUsername, adminPassword) = ParseUserCredentials(adminUser, "admin", "change-on-first-login");
        
        // Parse demo user credentials
        var (demoUsername, demoPassword) = ParseUserCredentials(demoUser, "demo", "demo123");
        
        modelBuilder.Entity<User>().HasData(
            new User
            {
                Id = 1,
                Username = adminUsername,
                Email = $"{adminUsername}@bookstore.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(adminPassword),
                Role = "Admin",
                CreatedAt = baseDate
            },
            new User
            {
                Id = 2,
                Username = demoUsername,
                Email = $"{demoUsername}@bookstore.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(demoPassword),
                Role = "User",
                CreatedAt = baseDate
            }
        );

        // Seed Authors
        modelBuilder.Entity<Author>().HasData(
            new Author
            {
                Id = 1,
                Name = "J.K. Rowling",
                Bio = "British author best known for the Harry Potter series",
                Country = "United Kingdom",
                CreatedAt = baseDate
            },
            new Author
            {
                Id = 2,
                Name = "George R.R. Martin",
                Bio = "American novelist and short story writer, screenwriter, and television producer",
                Country = "United States",
                CreatedAt = baseDate
            },
            new Author
            {
                Id = 3,
                Name = "J.R.R. Tolkien",
                Bio = "English writer, poet, philologist, and academic, best known as the author of The Lord of the Rings",
                Country = "United Kingdom",
                CreatedAt = baseDate
            },
            new Author
            {
                Id = 4,
                Name = "Brandon Sanderson",
                Bio = "American author of epic fantasy and science fiction",
                Country = "United States",
                CreatedAt = baseDate
            }
        );

        // Seed Books
        modelBuilder.Entity<Book>().HasData(
            new Book
            {
                Id = 1,
                Title = "Harry Potter and the Philosopher's Stone",
                ISBN = "978-0747532699",
                PublishedDate = new DateTime(1997, 6, 26),
                Price = 29.99m,
                AuthorId = 1,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 2,
                Title = "Harry Potter and the Chamber of Secrets",
                ISBN = "978-0747538493",
                PublishedDate = new DateTime(1998, 7, 2),
                Price = 29.99m,
                AuthorId = 1,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 3,
                Title = "A Game of Thrones",
                ISBN = "978-0553103540",
                PublishedDate = new DateTime(1996, 8, 1),
                Price = 34.99m,
                AuthorId = 2,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 4,
                Title = "A Clash of Kings",
                ISBN = "978-0553108033",
                PublishedDate = new DateTime(1998, 11, 16),
                Price = 34.99m,
                AuthorId = 2,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 5,
                Title = "The Fellowship of the Ring",
                ISBN = "978-0547928210",
                PublishedDate = new DateTime(1954, 7, 29),
                Price = 39.99m,
                AuthorId = 3,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 6,
                Title = "The Two Towers",
                ISBN = "978-0547928203",
                PublishedDate = new DateTime(1954, 11, 11),
                Price = 39.99m,
                AuthorId = 3,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 7,
                Title = "The Way of Kings",
                ISBN = "978-0765326355",
                PublishedDate = new DateTime(2010, 8, 31),
                Price = 44.99m,
                AuthorId = 4,
                CreatedAt = baseDate
            },
            new Book
            {
                Id = 8,
                Title = "Words of Radiance",
                ISBN = "978-0765326362",
                PublishedDate = new DateTime(2014, 3, 4),
                Price = 44.99m,
                AuthorId = 4,
                CreatedAt = baseDate
            }
        );
    }
    
    /// <summary>
    /// Parses user credentials from environment variable in format "username:password"
    /// Falls back to default values if env var not set or invalid format
    /// </summary>
    private static (string username, string password) ParseUserCredentials(string? envVar, string defaultUsername, string defaultPassword)
    {
        if (string.IsNullOrWhiteSpace(envVar))
        {
            return (defaultUsername, defaultPassword);
        }
        
        var parts = envVar.Split(':', 2);
        if (parts.Length != 2 || string.IsNullOrWhiteSpace(parts[0]) || string.IsNullOrWhiteSpace(parts[1]))
        {
            Console.WriteLine($"WARNING: Invalid user credential format. Expected 'username:password', got '{envVar}'. Using defaults.");
            return (defaultUsername, defaultPassword);
        }
        
        return (parts[0].Trim(), parts[1].Trim());
    }
}
