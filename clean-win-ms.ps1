# Copyrighted to Jones Joseph
# Advanced PowerShell Script for Cleanup of Temp Files, Logs, and Microsoft Apps with Detailed Logs

# Set the directory for the log file (where the script is located)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path -Path $scriptPath -ChildPath "cleanup_log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Function to log messages with timestamp
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Output $logMessage
}

# Ensure the log file exists
New-Item -Path $logFile -ItemType File -Force | Out-Null

Log-Message "Cleanup process started."

# 1. Clean up Temporary Files for Microsoft Apps
Log-Message "Finding and cleaning up temporary files for installed Microsoft apps..."

# Get the list of installed Microsoft apps
$installedApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -like "*Microsoft*" }

if ($installedApps.Count -gt 0) {
    # For each app, find its temp and log files and display file size
    foreach ($app in $installedApps) {
        $appName = $app.Name
        $appTempPath = "C:\ProgramData\$appName\Temp"
        $appLogPath = "C:\ProgramData\$appName\Logs"

        Log-Message "Checking for temporary and log files for app: $appName"

        # Check and display temp files
        if (Test-Path -Path $appTempPath) {
            $tempFiles = Get-ChildItem -Path $appTempPath -Recurse -Force
            foreach ($file in $tempFiles) {
                $fileSize = $file.Length
                Log-Message "App: $appName - Temp File: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
            }
        }

        # Check and display log files
        if (Test-Path -Path $appLogPath) {
            $logFiles = Get-ChildItem -Path $appLogPath -Recurse -Force
            foreach ($file in $logFiles) {
                $fileSize = $file.Length
                Log-Message "App: $appName - Log File: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
            }
        }
    }
} else {
    Log-Message "No Microsoft apps found."
}

# 2. Cleanup Microsoft App Temp and Log Files with User Confirmation
Log-Message "Prompting user for cleanup confirmation..."

# Ask the user if they want to clean up the displayed files
$cleanupConfirmation = Read-Host "Do you want to clean up the displayed temporary and log files? (y/n)"

if ($cleanupConfirmation -eq "y") {
    # Perform cleanup based on the user confirmation
    foreach ($app in $installedApps) {
        $appName = $app.Name
        $appTempPath = "C:\ProgramData\$appName\Temp"
        $appLogPath = "C:\ProgramData\$appName\Logs"

        Log-Message "Cleaning up temp and log files for app: $appName"

        # Clean up temp files
        if (Test-Path -Path $appTempPath) {
            $tempFiles = Get-ChildItem -Path $appTempPath -Recurse -Force
            foreach ($file in $tempFiles) {
                try {
                    $fileSize = $file.Length
                    Remove-Item $file.FullName -Force
                    Log-Message "Removed temp file: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
                }
                catch {
                    Log-Message "Error removing temp file: $($file.FullName) - $_"
                }
            }
        }

        # Clean up log files
        if (Test-Path -Path $appLogPath) {
            $logFiles = Get-ChildItem -Path $appLogPath -Recurse -Force
            foreach ($file in $logFiles) {
                try {
                    $fileSize = $file.Length
                    Remove-Item $file.FullName -Force
                    Log-Message "Removed log file: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
                }
                catch {
                    Log-Message "Error removing log file: $($file.FullName) - $_"
                }
            }
        }
    }
} else {
    Log-Message "Cleanup canceled by user."
}

# 3. Clean up System Log Files (Already in Previous Script)
Log-Message "Cleaning up system log files..."

$logPaths = @(
    "C:\Windows\System32\winevt\Logs\*.evtx", # Event logs
    "C:\Windows\Temp\*.log",                # System temporary logs
    "C:\ProgramData\Microsoft\Windows\WER\*.txt" # Windows Error Reporting logs
)

foreach ($logPath in $logPaths) {
    $logFiles = Get-ChildItem -Path $logPath -Recurse -Force
    foreach ($file in $logFiles) {
        try {
            $fileSize = $file.Length
            Remove-Item $file.FullName -Force
            Log-Message "Removed system log file: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
        }
        catch {
            Log-Message "Error removing log file: $($file.FullName) - $_"
        }
    }
}

# 4. Check for Running Processes that Might Interfere with Cleanup
Log-Message "Checking for running processes that might interfere with cleanup..."

$runningProcesses = Get-Process | Where-Object { $_.Path -like "C:\Program Files\*" }
if ($runningProcesses.Count -gt 0) {
    Log-Message "The following processes may prevent cleanup. Please close them before continuing:"
    foreach ($process in $runningProcesses) {
        Log-Message "Process: $($process.Name) - Path: $($process.Path)"
    }

    $processConfirmation = Read-Host "Do you want to continue with cleanup even if some processes are running? (y/n)"
    if ($processConfirmation -eq "n") {
        Log-Message "Cleanup process halted due to running processes."
        Write-Host "Cleanup halted. Please close the processes and rerun the script."
        exit
    }
}

# 5. Optionally Clear Browser Cache (e.g., Edge, Chrome)
$browserCachePaths = @(
    "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*",
    "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Cache\*"
)

foreach ($cachePath in $browserCachePaths) {
    if (Test-Path -Path $cachePath) {
        $cacheFiles = Get-ChildItem -Path $cachePath -Recurse -Force
        foreach ($file in $cacheFiles) {
            try {
                $fileSize = $file.Length
                Remove-Item $file.FullName -Force
                Log-Message "Removed browser cache file: $($file.FullName) (Size: $([math]::round($fileSize / 1MB, 2)) MB)"
            }
            catch {
                Log-Message "Error removing browser cache file: $($file.FullName) - $_"
            }
        }
    }
}

# 6. Provide Final Status and Summary
Log-Message "Cleanup process completed successfully."

# Final Log Entry with summary
$cleanupSummary = @()
$cleanupSummary += "Cleanup completed successfully on $(Get-Date)"
$cleanupSummary += "Log file located at: $logFile"

Write-Host $cleanupSummary

# Display the full cleanup summary to the user
$cleanupSummary | ForEach-Object { Write-Host $_ }

# Optional: Notify user about any remaining tasks (like rebooting)
$rebootRequired = Read-Host "Would you like to reboot the system now to finalize cleanup? (y/n)"
if ($rebootRequired -eq "y") {
    Log-Message "System reboot initiated."
    Restart-Computer -Force
}

exit 0
