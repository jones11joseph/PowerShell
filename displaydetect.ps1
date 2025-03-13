# Copyrighted to Jones Joseph
# Script to retrieve connected monitor details including OEM information

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
}

# Function to get monitor details
function Get-MonitorDetails {
    Log-Message "Retrieving connected monitor information..."

    # Query the WMI class for monitor information
    $monitors = Get-WmiObject -Class Win32_DesktopMonitor

    if ($monitors.Count -eq 0) {
        Log-Message "No monitors found."
        Write-Host "No monitors found."
    } else {
        Log-Message "The following monitors are connected:"
        $monitors | ForEach-Object {
            $monitorName = $_.Name
            $monitorStatus = $_.Status
            $screenWidth = $_.ScreenWidth
            $screenHeight = $_.ScreenHeight
            $screenSize = "$screenWidth x $screenHeight"
            
            Log-Message "Monitor: $monitorName, Status: $monitorStatus, Resolution: $screenSize"
            Write-Host "Monitor: $monitorName"
            Write-Host "  Status: $monitorStatus"
            Write-Host "  Resolution: $screenSize"
        }
    }
}

# Function to get the connection type of the monitors
function Get-MonitorConnectionType {
    Log-Message "Retrieving monitor connection types..."

    $monitors = Get-WmiObject -Class Win32_VideoController

    if ($monitors.Count -eq 0) {
        Log-Message "No video controllers found."
        Write-Host "No video controllers found."
    } else {
        Log-Message "The following monitor connection types are detected:"
        $monitors | ForEach-Object {
            $connectionType = $_.VideoModeDescription
            Log-Message "Connection Type: $connectionType"
            Write-Host "Connection Type: $connectionType"
        }
    }
}

# Function to get OEM details for the monitor
function Get-MonitorOEMDetails {
    Log-Message "Retrieving OEM details for connected monitors..."

    # Query WMI for video controller info (OEM details)
    $videoControllers = Get-WmiObject -Class Win32_VideoController

    if ($videoControllers.Count -eq 0) {
        Log-Message "No video controllers found for OEM details."
        Write-Host "No video controllers found."
    } else {
        $videoControllers | ForEach-Object {
            $manufacturer = $_.VideoProcessor
            $videoMode = $_.VideoModeDescription
            $adapterRAM = [math]::round($_.AdapterRAM / 1MB, 2)
            $name = $_.Name

            Log-Message "OEM Details for Video Adapter: $name"
            Log-Message "  Manufacturer: $manufacturer"
            Log-Message "  Video Mode: $videoMode"
            Log-Message "  RAM: $adapterRAM MB"
            Write-Host "OEM Details for Video Adapter: $name"
            Write-Host "  Manufacturer: $manufacturer"
            Write-Host "  Video Mode: $videoMode"
            Write-Host "  RAM: $adapterRAM MB"
        }
    }
}

# Main logic
Log-Message "Starting monitor detection script."

# Retrieve and display monitor details
Get-MonitorDetails

# Retrieve and display connection type
Get-MonitorConnectionType

# Retrieve and display OEM details
Get-MonitorOEMDetails

Log-Message "Monitor detection script completed."
Write-Host "Monitor detection script completed."
