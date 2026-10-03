using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ErpGovernance.Web.Controllers;

[Authorize]
public class AttachmentsController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IFileStorageService _storage;
    private readonly IAuditService _audit;
    private readonly ICurrentUserService _currentUser;

    public AttachmentsController(ApplicationDbContext db, IFileStorageService storage, IAuditService audit, ICurrentUserService currentUser)
    {
        _db = db;
        _storage = storage;
        _audit = audit;
        _currentUser = currentUser;
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Upload(IFormFile file, string entityType, int entityId, string returnUrl)
    {
        if (file == null || file.Length == 0)
        {
            TempData["Error"] = "No file selected.";
            return Redirect(returnUrl);
        }

        var (valid, error) = _storage.Validate(file.FileName, file.Length);
        if (!valid)
        {
            TempData["Error"] = error;
            return Redirect(returnUrl);
        }

        using var stream = file.OpenReadStream();
        var (relativePath, originalName, size, mimeType) = await _storage.SaveAsync(stream, file.FileName, entityType);

        var attachment = new Attachment
        {
            EntityType = entityType,
            EntityId = entityId,
            FileName = originalName,
            FilePath = relativePath,
            FileSize = size,
            MimeType = mimeType,
            UploadedById = _currentUser.UserId,
            CreatedAt = DateTime.UtcNow
        };

        _db.Attachments.Add(attachment);
        await _db.SaveChangesAsync();

        await _audit.LogAsync("upload", "Attachment", attachment.Id, $"Uploaded {originalName} to {entityType} {entityId}");

        TempData["Success"] = "File uploaded successfully.";
        return Redirect(returnUrl);
    }

    public async Task<IActionResult> Download(int id)
    {
        var attachment = await _db.Attachments.FindAsync(id);
        if (attachment == null) return NotFound();

        var fullPath = _storage.GetFullPath(attachment.FilePath);
        if (!System.IO.File.Exists(fullPath)) return NotFound();

        return PhysicalFile(fullPath, attachment.MimeType ?? "application/octet-stream", attachment.FileName);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id, string returnUrl)
    {
        var attachment = await _db.Attachments.FindAsync(id);
        if (attachment == null) return NotFound();

        await _storage.DeleteAsync(attachment.FilePath);
        _db.Attachments.Remove(attachment);
        await _db.SaveChangesAsync();

        await _audit.LogAsync("delete", "Attachment", id, $"Deleted {attachment.FileName}");

        TempData["Success"] = "File deleted successfully.";
        return Redirect(returnUrl);
    }
}
