using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BookstoreApi.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "Authors",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Name = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Bio = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Country = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Authors", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "Books",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Title = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    ISBN = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    PublishedDate = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AuthorId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Books", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Books_Authors_AuthorId",
                        column: x => x.AuthorId,
                        principalTable: "Authors",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.InsertData(
                table: "Authors",
                columns: new[] { "Id", "Bio", "Country", "CreatedAt", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "British author best known for the Harry Potter series", "United Kingdom", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "J.K. Rowling", null },
                    { 2, "American novelist and short story writer, screenwriter, and television producer", "United States", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "George R.R. Martin", null },
                    { 3, "English writer, poet, philologist, and academic, best known as the author of The Lord of the Rings", "United Kingdom", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "J.R.R. Tolkien", null },
                    { 4, "American author of epic fantasy and science fiction", "United States", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Brandon Sanderson", null }
                });

            migrationBuilder.InsertData(
                table: "Books",
                columns: new[] { "Id", "AuthorId", "CreatedAt", "ISBN", "Price", "PublishedDate", "Title", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0747532699", 29.99m, new DateTime(1997, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), "Harry Potter and the Philosopher's Stone", null },
                    { 2, 1, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0747538493", 29.99m, new DateTime(1998, 7, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "Harry Potter and the Chamber of Secrets", null },
                    { 3, 2, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0553103540", 34.99m, new DateTime(1996, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "A Game of Thrones", null },
                    { 4, 2, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0553108033", 34.99m, new DateTime(1998, 11, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), "A Clash of Kings", null },
                    { 5, 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0547928210", 39.99m, new DateTime(1954, 7, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Fellowship of the Ring", null },
                    { 6, 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0547928203", 39.99m, new DateTime(1954, 11, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Two Towers", null },
                    { 7, 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0765326355", 44.99m, new DateTime(2010, 8, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Way of Kings", null },
                    { 8, 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "978-0765326362", 44.99m, new DateTime(2014, 3, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), "Words of Radiance", null }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Books_AuthorId",
                table: "Books",
                column: "AuthorId");

            migrationBuilder.CreateIndex(
                name: "IX_Books_ISBN",
                table: "Books",
                column: "ISBN",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Books");

            migrationBuilder.DropTable(
                name: "Authors");
        }
    }
}
