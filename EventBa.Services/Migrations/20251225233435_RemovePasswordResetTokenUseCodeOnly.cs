using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventBa.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemovePasswordResetTokenUseCodeOnly : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PasswordResetToken",
                table: "users");

            migrationBuilder.RenameColumn(
                name: "PasswordResetTokenExpiry",
                table: "users",
                newName: "PasswordResetCodeExpiry");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "PasswordResetCodeExpiry",
                table: "users",
                newName: "PasswordResetTokenExpiry");

            migrationBuilder.AddColumn<string>(
                name: "PasswordResetToken",
                table: "users",
                type: "text",
                nullable: true);
        }
    }
}
