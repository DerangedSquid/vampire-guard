<#
===============================================================================
NAME:        VRising-Host-VMConfigurator.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     1.0

SYNOPSIS:
    Interactive Hyper-V VM provisioning script for creating a new virtual
    machine with user-defined CPU, memory, disk, and network configuration.

DESCRIPTION:
    This script performs the following:
    - Ensures Hyper-V is enabled on the host
    - Gathers available system resources
    - Prompts the user for VM configuration parameters
    - Creates a Generation 2 VM
    - Creates and attaches a dynamic VHDX
    - Mounts a Windows installation ISO
    - Creates (if needed) and attaches an external virtual switch
    - Starts the VM

PREREQUISITES:
    - Windows 10/11 Pro, Enterprise, or Education
    - SLAT-capable CPU with virtualization enabled in BIOS
    - Hyper-V feature installed (script will enable if missing)
    - Minimum 4 GB RAM
    - Windows installation ISO located at:
      C:\Hyper V\ISO\<your ISO folder>\<your ISO>.ISO

USAGE:
    Run this script in an elevated PowerShell session:
        Set-ExecutionPolicy Bypass -Scope Process
        .\VRising-Host-VMConfigurator.ps1

NOTES:
    This script is intentionally generic and can be used to provision ANY VM,
    not just VRising. It is included in the VRising automation suite because
    it provides the base VM used for the VRising server.
===============================================================================
#>

Write-Host "`n=== Hyper-V VM Provisioning Script ===`n" -ForegroundColor Cyan

# -----------------------------------------
# Step 1: Check if Hyper-V is already enabled
# -----------------------------------------
$hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

if ($hyperVFeature.State -eq "Enabled") {
    Write-Host "Hyper-V is already enabled." -ForegroundColor Green
} else {
    Write-Host "Enabling Hyper-V feature..." -ForegroundColor Cyan
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Write-Host "`nHyper-V feature enabled. Please reboot your system to continue." -ForegroundColor Green
    Pause
    exit
}

# -----------------------------------------
# Step 2: Get Available System Resources
# -----------------------------------------
$availableMemoryBytes = (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory
$availableMemoryGB = [math]::round($availableMemoryBytes / 1MB, 2)

$diskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
$availableDiskSpaceGB = [math]::round($diskInfo.FreeSpace / 1GB, 2)

$totalCores = (Get-WmiObject -Class Win32_Processor).NumberOfLogicalProcessors

$networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
$networkAdapterNames = $networkAdapters.Name

Write-Host "`nAvailable system resources:" -ForegroundColor Cyan
Write-Host "  Memory Available:        $availableMemoryGB GB"
Write-Host "  Disk Space Available:    $availableDiskSpaceGB GB"
Write-Host "  Logical CPU Cores:       $totalCores"
Write-Host "  Network Adapters:        $($networkAdapterNames -join ', ')"

# -----------------------------------------
# Step 3: Gather User Input
# -----------------------------------------
$vmName = Read-Host "Enter the name for the new VM (e.g., 'VRising-Server')"

do {
    $vmMemory = Read-Host "Enter the amount of memory for the VM in GB"
} until ($vmMemory -match '^\d+$' -and [int]$vmMemory -le $availableMemoryGB)

do {
    $vmDiskSize = Read-Host "Enter the disk size for the VM in GB"
} until ($vmDiskSize -match '^\d+$' -and [int]$vmDiskSize -le $availableDiskSpaceGB)

do {
    $vmCores = Read-Host "Enter the number of CPU cores for the VM"
} until ($vmCores -match '^\d+$' -and [int]$vmCores -le $totalCores)

do {
    $adapterName = Read-Host "Enter the network adapter name (choose from: $($networkAdapterNames -join ', '))"
} until ($networkAdapterNames -contains $adapterName)

Write-Host "`nProceeding with VM creation..." -ForegroundColor Green

# -----------------------------------------
# Step 4: Create the VM
# -----------------------------------------
$vmPath = "C:\Hyper V\Hosts"
New-VM -Name $vmName -Path $vmPath -MemoryStartupBytes ([int64]$vmMemory * 1GB)

if (-not (Get-VM -Name $vmName -ErrorAction SilentlyContinue)) {
    Write-Host "VM creation failed. Exiting." -ForegroundColor Red
    exit
}

# Set CPU cores
Set-VMProcessor -VMName $vmName -Count $vmCores

# -----------------------------------------
# Step 5: Create Virtual Hard Disk
# -----------------------------------------
$vhdPath = "$vmPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
New-VHD -Path $vhdPath -SizeBytes ([int64]$vmDiskSize * 1GB) -Dynamic

# -----------------------------------------
# Step 6: Attach VHD to VM
# -----------------------------------------
Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath

# -----------------------------------------
# Step 7: Mount ISO
# -----------------------------------------
$isoPath = "C:\Hyper V\ISO\WD_WC10P_V2004\SW_DVD9_Win_Pro_10_2004_64BIT_English_Pro_Ent_EDU_N_MLF_-2_X22-29752.ISO"

if (-Not (Test-Path $isoPath)) {
    Write-Host "ISO not found at: $isoPath" -ForegroundColor Red
    exit
}

Set-VMDvdDrive -VMName $vmName -ControllerNumber 1 -Path $isoPath

# -----------------------------------------
# Step 8: Create Virtual Switch
# -----------------------------------------
$switchName = "ExternalSwitch"

if (-not (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating external virtual switch using '$adapterName'..." -ForegroundColor Cyan
    New-VMSwitch -Name $switchName -NetAdapterName $adapterName -AllowManagementOS $true
}

# -----------------------------------------
# Step 9: Connect Switch to VM
# -----------------------------------------
Write-Host "Connecting VM '$vmName' to virtual switch '$switchName'..." -ForegroundColor Cyan
Connect-VMNetworkAdapter -VMName $vmName -SwitchName $switchName

# -----------------------------------------
# Step 10: Start VM
# -----------------------------------------
Write-Host "Starting VM..." -ForegroundColor Cyan
Start-VM -Name $vmName

Write-Host "`nVM '$vmName' setup is complete and started!" -ForegroundColor Green
