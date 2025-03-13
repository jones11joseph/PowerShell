# Copyrighted to Jones Joseph
# Script to Find Duplicate Files in User Directory
# This script finds duplicate files based on content hash and displays their locations.
# Operations performed:
# 1. Scans the user's directory for all files.
# 2. Compares the hashes (MD5) of each file to identify duplicates.
# 3. Displays the file names and their locations for any duplicates found.
# 4. Lists all the duplicates found in the specified user directory.

# Get the script directory where the script is located
$scriptDirectory = $PSScriptRoot
$logFile = Join-Path $scriptDirectory "DuplicateFilesLog.txt"  # Log file to store results
$date = Get-Date

# Initialize logging
Add-Content -Path $logFile -Value "Duplicate File Finder started at $date"
Add-Content -Path $logFile -Value "Scanning directory: $scriptDirectory"

Write-Host "Scanning for duplicate files in script directory: $scriptDirectory"

# Function to calculate file hash (MD5)
Function Get-FileHash {
    param(
        [string]$filePath
    )
    try {
        $hash = Get-FileHash -Path $filePath -Algorithm MD5
        return $hash.Hash
    } catch {
        Write-Warning "Could not compute hash for file: $filePath"
        return $null
    }
}

# Function to find and list duplicate files
Function Find-DuplicateFiles {
    param(
        [string]$directory
    )
    
    $fileHashes = @{}
    $duplicateFiles = @()

    # Get all files recursively in the user directory
    $files = Get-ChildItem -Path $directory -Recurse -File -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $fileHash = Get-FileHash -filePath $file.FullName
        if ($fileHash) {
            # If hash already exists, it means we have found a duplicate
            if ($fileHashes.ContainsKey($fileHash)) {
                $duplicateFiles += [PSCustomObject]@{
                    OriginalFile = $fileHashes[$fileHash]
                    DuplicateFile = $file.FullName
                }
            } else {
                $fileHashes[$fileHash] = $file.FullName
            }
        }
    }

    return $duplicateFiles
}

# Call the Find-DuplicateFiles function
$duplicates = Find-DuplicateFiles -directory $scriptDirectory

# Output duplicates to console and log file
if ($duplicates.Count -gt 0) {
    Write-Host "Duplicate files found:"
    Add-Content -Path $logFile -Value "Duplicate files found:"
    
    foreach ($duplicate in $duplicates) {
        Write-Host "Original File: $($duplicate.OriginalFile)"
        Write-Host "Duplicate File: $($duplicate.DuplicateFile)"
        Add-Content -Path $logFile -Value "Original File: $($duplicate.OriginalFile)"
        Add-Content -Path $logFile -Value "Duplicate File: $($duplicate.DuplicateFile)"
    }
} else {
    Write-Host "No duplicate files found."
    Add-Content -Path $logFile -Value "No duplicate files found."
}

# Final Log
$finalDate = Get-Date
Add-Content -Path $logFile -Value "Duplicate File Finder completed at $finalDate"
Write-Host "Duplicate file search completed. Check the log file at: $logFile"
