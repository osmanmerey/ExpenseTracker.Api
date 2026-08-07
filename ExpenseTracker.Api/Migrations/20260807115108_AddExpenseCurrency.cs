using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ExpenseTracker.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddExpenseCurrency : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Currency",
                table: "Expenses",
                type: "character varying(3)",
                maxLength: 3,
                nullable: false,
                defaultValue: "TRY");

            // Backfill from legacy title encoding [USD] description; then strip prefix.
            migrationBuilder.Sql(
                """
                UPDATE "Expenses"
                SET "Currency" = UPPER(SUBSTRING("Title" FROM 2 FOR 3))
                WHERE "Title" ~ '^\\[[A-Za-z]{3}\\]'
                  AND UPPER(SUBSTRING("Title" FROM 2 FOR 3)) IN ('TRY', 'USD', 'EUR', 'GBP');

                UPDATE "Expenses"
                SET "Title" = TRIM(SUBSTRING("Title" FROM POSITION(']' IN "Title") + 1))
                WHERE "Title" ~ '^\\[[A-Za-z]{3}\\]';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Currency",
                table: "Expenses");
        }
    }
}
