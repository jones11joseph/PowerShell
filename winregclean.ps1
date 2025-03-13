# Copyrighted to Jones Joseph
# Windows Registry Cleanup Script for Expert-Level Users
# This script performs a comprehensive cleanup of the Windows Registry and system event logs.
# Operations performed:
# 1. Backup the registry to a safe location before performing any cleanup.
# 2. Remove obsolete registry keys and values that might affect performance or security.
# 3. Clean up empty registry keys, especially those left over by uninstalled software.
# 4. Remove old event logs to recover disk space and improve system performance.
# 5. Log all actions performed to a file based on the system's motherboard serial number.

# Initialize Logging
$serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
$scriptDirectory = $PSScriptRoot  # Get the directory where the script is located
$logFile = Join-Path -Path $scriptDirectory -ChildPath "RegistryCleanup_${serialNumber}.log"
$date = Get-Date
Add-Content -Path $logFile -Value "Registry Cleanup started at $date"

# Function to Backup Registry to a Safe Location
Function Backup-Registry {
    $backupPath = "C:\RegistryBackup"
    If (-Not (Test-Path -Path $backupPath)) {
        Write-Host "Creating backup folder: $backupPath"
        New-Item -Path $backupPath -ItemType Directory -Force
    }

    $backupFile = "$backupPath\RegistryBackup_$($date.ToString('yyyyMMdd_HHmmss')).reg"
    Write-Host "Backing up registry to: $backupFile"
    reg export HKCU $backupFile /y
    reg export HKLM $backupFile /y
    Add-Content -Path $logFile -Value "Registry backed up to: $backupFile"
}

# Function to Remove Obsolete Registry Keys (Example keys for removal)
Function Remove-ObsoleteRegistryKeys {
    Write-Host "Removing obsolete registry keys..."
    
    # Example registry keys to clean
    $keysToRemove = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU",  # Recent run commands
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs",  # Recent documents
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU",  # Open/Save dialog history
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",  # Leftover registry entries from uninstalled software
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSizeMove",  # Taskbar settings
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_NotifyNewAppInstall"  # New app installation notification
    )

    ForEach ($key in $keysToRemove) {
        If (Test-Path -Path $key) {
            Write-Host "Removing registry key: $key"
            Remove-Item -Path $key -Recurse -Force
            Add-Content -Path $logFile -Value "Removed registry key: $key"
        } Else {
            Write-Host "Registry key not found: $key"
            Add-Content -Path $logFile -Value "Registry key not found: $key"
        }
    }
}

# Function to Clean Empty Registry Keys
Function Clean-EmptyRegistryKeys {
    Write-Host "Cleaning empty registry keys..."

    $registryPaths = @("HKCU:\Software", "HKLM:\Software")

    ForEach ($path in $registryPaths) {
        $subKeys = Get-ChildItem -Path $path -Recurse | Where-Object { $_.PsIsContainer -and !(Get-ChildItem -Path $_.PSPath) }

        ForEach ($key in $subKeys) {
            Try {
                Write-Host "Removing empty registry key: $($key.PSPath)"
                Remove-Item -Path $key.PSPath -Recurse -Force
                Add-Content -Path $logFile -Value "Removed empty registry key: $($key.PSPath)"
            }
            Catch {
                Write-Host "Error removing empty registry key: $($key.PSPath)"
                Add-Content -Path $logFile -Value "Error removing empty registry key: $($key.PSPath) - $_"
            }
        }
    }

    Write-Host "Empty registry keys cleaned."
    Add-Content -Path $logFile -Value "Empty registry keys cleaned."
}

# Function to Remove Old Event Logs
Function Remove-OldEventLogs {
    Write-Host "Removing old event logs..."

    $eventLogPath = "C:\Windows\System32\winevt\Logs"
    $eventLogFiles = Get-ChildItem -Path $eventLogPath -Recurse

    ForEach ($logFile in $eventLogFiles) {
        If ($logFile.LastWriteTime -lt (Get-Date).AddDays(-30)) {
            Try {
                Write-Host "Removing old event log: $($logFile.FullName)"
                Remove-Item -Path $logFile.FullName -Force
                Add-Content -Path $logFile -Value "Removed old event log: $($logFile.FullName)"
            }
            Catch {
                Write-Host "Error removing old event log: $($logFile.FullName)"
                Add-Content -Path $logFile -Value "Error removing old event log: $($logFile.FullName) - $_"
            }
        }
    }

    Write-Host "Old event logs removed."
    Add-Content -Path $logFile -Value "Old event logs removed."
}

# Function to Check and Remove Unused File Associations
Function Remove-UnusedFileAssociations {
    Write-Host "Cleaning unused file associations..."

    $unusedFileAssociations = @(
        "txtfile",
        "htmlfile",
        "pdf",
        "zipfile"
    )

    ForEach ($assoc in $unusedFileAssociations) {
        $assocPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$assoc"
        If (Test-Path -Path $assocPath) {
            Try {
                Write-Host "Removing unused file association: $assoc"
                Remove-Item -Path $assocPath -Recurse -Force
                Add-Content -Path $logFile -Value "Removed unused file association: $assoc"
            }
            Catch {
                Write-Host "Error removing unused file association: $assoc"
                Add-Content -Path $logFile -Value "Error removing unused file association: $assoc - $_"
            }
        }
    }

    Write-Host "Unused file associations removed."
    Add-Content -Path $logFile -Value "Unused file associations removed."
}

# Function to Perform a Deep Clean of the Registry
Function Deep-CleanRegistry {
    Write-Host "Performing deep registry cleanup..."

    # Clean temporary files
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force
    Write-Host "Removed temporary files."
    Add-Content -Path $logFile -Value "Removed temporary files from Windows Temp and User Temp directories."

    # Clean Prefetch folder
    Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force
    Write-Host "Removed files from the Prefetch folder."
    Add-Content -Path $logFile -Value "Removed files from the Prefetch folder."

    # Clean Windows Update Cache
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
    Write-Host "Removed Windows Update cache."
    Add-Content -Path $logFile -Value "Removed Windows Update cache."

    Write-Host "Deep registry cleanup complete."
    Add-Content -Path $logFile -Value "Deep registry cleanup complete."
}

# Main Script Execution
Write-Host "Starting Advanced Registry Cleanup..."

# Step 1: Backup the Registry
Backup-Registry

# Step 2: Remove Obsolete Registry Keys
Remove-ObsoleteRegistryKeys

# Step 3: Clean Empty Registry Keys
Clean-EmptyRegistryKeys

# Step 4: Remove Old Event Logs
Remove-OldEventLogs

# Step 5: Remove Unused File Associations
Remove-UnusedFileAssociations

# Step 6: Perform a Deep Clean of the Registry
Deep-CleanRegistry

# Finalize Logging
$finalDate = Get-Date
Add-Content -Path $logFile -Value "Registry Cleanup completed at $finalDate"

Write-Host "Registry cleanup completed. Review the log file for details."
Write-Host "The registry cleanup log is located at: $logFile"

# Script Completion
Write-Host "Advanced Registry cleanup script execution completed."
