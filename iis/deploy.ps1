param (
    [string]$SiteName = "vm-dotnet-api",
    [string]$AppPoolName = "vm-dotnet-api",
    [string]$DeployPath = "C:\inetpub\vm-dotnet-api",
    [int]$HttpPort = 80,
    [int]$HttpsPort = 443
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Ensure IIS features installed
Write-Host "Ensuring IIS Features are installed..."

$features = @(
    "Web-Server",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Static-Content",
    "Web-Default-Doc",
    "Web-Http-Errors",
    "Web-App-Dev",
    "Web-Asp-Net45",
    "Web-Net-Ext45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Security",
    "Web-Filtering",
    "Web-Mgmt-Tools"
)

foreach ($feature in $features) {
    if (-not (Get-WindowsFeature $feature).Installed) {
        Install-WindowsFeature $feature | Out-Null
    }
}

# Ensure App Pool is present
Import-Module WebAdministration

Write-Host "Ensuring App Pool '$AppPoolName' exists..."

if (-not (Test-Path "IIS:\AppPools\$AppPoolName")) {
    New-WebAppPool -Name $AppPoolName
}

Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name managedRuntimeVersion -Value ""
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name startMode -Value "AlwaysRunning"

# Publish .NET application
Write-Host "Publishing .NET application..."

$publishPath = Join-Path $DeployPath "app"

if (-not (Test-Path $DeployPath)) {
    New-Item -ItemType Directory -Path $DeployPath | Out-Null
}

dotnet publish "..\src\api" -c Release -o $publishPath

# Validate IIS Site exists
Write-Host "Ensuring IIS Site '$SiteName' exists..."

if (-not (Get-Website -Name $SiteName -ErrorAction SilentlyContinue)) {
    New-Website `
        -Name $SiteName `
        -PhysicalPath $publishPath `
        -ApplicationPool $AppPoolName `
        -Port $HttpPort
}
else {
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath -Value $publishPath
}

# Self Signed Cert
Write-Host "Ensuring self-signed certificate exists..."

$cert = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -eq "CN=$SiteName" }
if (-not $cert) {
    $cert = New-SelfSignedCertificate `
    -DnsName $SiteName `
    -CertStoreLocation "Cert:\LocalMachine\My"
}

# Check for HTTPS Binding
Write-Host "Ensuring HTTPS binding exists..."

$binding = Get-WebBinding -Name $SiteName -Protocol https -ErrorAction SilentlyContinue

if (-not $binding){
    New-WebBinding `
        -Name $SiteName `
        -Protocol https `
        -Port $HttpsPort `
        -SslFlags 0

    $binding = Get-WebBinding -Name $SiteName -Protocol https
}

$binding.AddSslCertificate($cert.Thumbprint, "My")

# Restart Pool
Restart-WebAppPool -Name $AppPoolName
Write-Host "IIS deployment complete."