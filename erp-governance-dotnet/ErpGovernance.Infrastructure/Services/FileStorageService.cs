using ErpGovernance.Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace ErpGovernance.Infrastructure.Services;

public class FileStorageService : IFileStorageService
{
    private readonly string _basePath;
    private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".png", ".jpg", ".jpeg", ".gif", ".txt"
    };
    private static readonly Dictionary<string, string> MimeTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        [".pdf"] = "application/pdf",
        [".doc"] = "application/msword",
        [".docx"] = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        [".xls"] = "application/vnd.ms-excel",
        [".xlsx"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        [".png"] = "image/png",
        [".jpg"] = "image/jpeg",
        [".jpeg"] = "image/jpeg",
        [".gif"] = "image/gif",
        [".txt"] = "text/plain"
    };
    private const long MaxFileSize = 5 * 1024 * 1024; // 5MB

    public FileStorageService(IConfiguration configuration)
    {
        _basePath = configuration["FileStorage:BasePath"] ?? @"D:\ErpGovernanceUploads";
        Directory.CreateDirectory(_basePath);
    }

    public async Task<(string RelativePath, string OriginalName, long Size, string MimeType)> SaveAsync(
        Stream fileStream, string originalFileName, string entityType)
    {
        var ext = Path.GetExtension(originalFileName);
        var safeName = $"{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}_{Guid.NewGuid():N}{ext}";
        var subDir = Path.Combine(_basePath, entityType);
        Directory.CreateDirectory(subDir);
        var fullPath = Path.Combine(subDir, safeName);

        await using var fs = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None);
        await fileStream.CopyToAsync(fs);

        var relativePath = Path.Combine(entityType, safeName);
        var mimeType = MimeTypes.TryGetValue(ext, out var mime) ? mime : "application/octet-stream";
        return (relativePath, originalFileName, fileStream.Length, mimeType);
    }

    public string GetFullPath(string relativePath) => Path.Combine(_basePath, relativePath);

    public async Task DeleteAsync(string relativePath)
    {
        var fullPath = GetFullPath(relativePath);
        if (File.Exists(fullPath))
            await Task.Run(() => File.Delete(fullPath));
    }

    public (bool Valid, string? Error) Validate(string fileName, long size)
    {
        var ext = Path.GetExtension(fileName);
        if (!AllowedExtensions.Contains(ext))
            return (false, $"File type '{ext}' is not allowed.");
        if (size > MaxFileSize)
            return (false, "File size exceeds the 5MB limit.");
        return (true, null);
    }
}
