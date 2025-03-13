# Copyrighted to Jones Joseph
# Script to detect and manage if any browser is running at startup

# Define the list of browsers to check for
$browserNames = @("chrome.exe", "msedge.exe", "firefox.exe", "iexplore.exe", "safari.exe", "brave.exe")

# Function to check if any of the browsers are in the startup registry
function Check-BrowsersInStartupRegistry {
    Log-Message "Checking startup programs in the registry..."

    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",         # Current user startup registry
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",         # All users startup registry
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" # 32-bit apps on 64-bit systems
    )

    $startupItems = @()
    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            $startupItems += Get-ItemProperty -Path $path
        }
    }

    $browserStartup = $startupItems | Where-Object {
        $browserNames -contains $_.PSChildName.ToLower()
    }

    return $browserStartup
}

# Function to check if any browser process is currently running
function Check-BrowsersRunning {
    Log-Message "Checking if any browser is running..."

    $runningBrowsers = Get-Process | Where-Object { 
        $browserNames -contains $_.Name.ToLower()
    }

    return $runningBrowsers
}

# Function to log the message to the log file and console
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
}

# Function to remove a browser from startup registry
function Remove-BrowserFromStartup {
    param (
        [string]$browserName
    )
    
    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    
    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            $key = Get-ItemProperty -Path $path
            if ($key.PSObject.Properties[$browserName]) {
                Remove-ItemProperty -Path $path -Name $browserName
                Log-Message "Removed $browserName from startup registry."
                Write-Host "$browserName has been removed from startup registry."
            }
        }
    }
}

# Function to disable a browser from startup (by commenting it out in registry)
function Disable-BrowserFromStartup {
    param (
        [string]$browserName
    )
    
    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    
    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            $key = Get-ItemProperty -Path $path
            if ($key.PSObject.Properties[$browserName]) {
                # Commenting out the line in registry to disable startup
                $value = $key.$browserName
                Set-ItemProperty -Path $path -Name $browserName -Value "# $value"
                Log-Message "Disabled $browserName from startup registry (commented out)."
                Write-Host "$browserName has been disabled from startup registry."
            }
        }
    }
}

# Main logic

# Check if any browsers are running at startup
$browserStartup = Check-BrowsersInStartupRegistry
$browserRunning = Check-BrowsersRunning

# Output and log results for startup detection
if ($browserStartup.Count -gt 0) {
    Log-Message "The following browsers are set to run at startup:"
    $browserStartup | ForEach-Object { 
        Log-Message "$($_.PSChildName) is set to run at startup."
        Write-Host "$($_.PSChildName) is set to run at startup."
        
        # Ask the user whether they want to remove or disable this browser from startup
        $userResponse = Read-Host "Do you want to remove or disable $($_.PSChildName) from startup? (remove/disable/skip)"
        switch ($userResponse.ToLower()) {
            "remove" {
                Remove-BrowserFromStartup -browserName $_.PSChildName
            }
            "disable" {
                Disable-BrowserFromStartup -browserName $_.PSChildName
            }
            "skip" {
                Write-Host "Skipping $($_.PSChildName)."
            }
            default {
                Write-Host "Invalid option, skipping..."
            }
        }
    }
} else {
    Log-Message "No browsers found running at startup in registry."
    Write-Host "No browsers found running at startup in registry."
}

# Output and log results for currently running browser processes
if ($browserRunning.Count -gt 0) {
    Log-Message "The following browsers are currently running:"
    $browserRunning | ForEach-Object { 
        Log-Message "$($_.Name) is currently running."
        Write-Host "$($_.Name) is currently running."
    }
} else {
    Log-Message "No browsers are currently running."
    Write-Host "No browsers are currently running."
}

# Final message indicating the end of the script
Log-Message "Browser startup check completed."
Write-Host "Browser startup check completed."
