namespace ErpGovernance.Application.Interfaces;

public interface IFileStorageService
{
    /// <summary>Saves a file to the secure upload location. Returns relative path.</summary>
    Task<(string RelativePath, string OriginalName, long Size, string MimeType)> SaveAsync(
        Stream fileStream, string originalFileName, string entityType);

    /// <summary>Returns the full physical path for a stored file.</summary>
    string GetFullPath(string relativePath);

    /// <summary>Deletes a file from storage.</summary>
    Task DeleteAsync(string relativePath);

    /// <summary>Validates file extension and size (max 5MB).</summary>
    (bool Valid, string? Error) Validate(string fileName, long size);
}
