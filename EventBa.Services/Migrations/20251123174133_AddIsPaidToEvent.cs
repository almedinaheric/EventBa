using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventBa.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddIsPaidToEvent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_paid",
                table: "events",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "is_paid",
                table: "events");
        }
    }
}
