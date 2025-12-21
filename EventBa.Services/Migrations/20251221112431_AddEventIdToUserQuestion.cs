using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventBa.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddEventIdToUserQuestion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "event_id",
                table: "user_questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_user_questions_event_id",
                table: "user_questions",
                column: "event_id");

            migrationBuilder.AddForeignKey(
                name: "user_questions_event_id_fkey",
                table: "user_questions",
                column: "event_id",
                principalTable: "events",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "user_questions_event_id_fkey",
                table: "user_questions");

            migrationBuilder.DropIndex(
                name: "IX_user_questions_event_id",
                table: "user_questions");

            migrationBuilder.DropColumn(
                name: "event_id",
                table: "user_questions");
        }
    }
}
