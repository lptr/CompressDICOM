# CompressDICOM.ps1
# PowerShell Script to Compress DICOM Files Using dcmcjpeg

# Usage
#
# REM Enable PowerShell script execution; without this step, the script will not run
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#
# REM Run the script with the root directory as the argument to compress
# dicompress.ps1 <DIR>
#
# REM Run with the decompression tool instead to revert
# dicompress.ps1 <DIR> "dcmdjpls"

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$rootDir,

    [Parameter(Position = 1)]
    [string]$compressionTool = "dcmcjpls"
)

# Get all .dcm files recursively from the root directory
Get-ChildItem -Path $rootDir -File -Recurse | ForEach-Object {
    $file = $_.FullName
    $dir = $_.DirectoryName
    $filename = $_.Name

    # Create a unique temporary filename in the same directory
    $tempFile = Join-Path $dir ([System.IO.Path]::GetRandomFileName() + ".dcm")

    # Prepare the arguments for dcmcjpeg
    $arguments = "`"$file`" `"$tempFile`""

    # Set up the process start information
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $compressionTool
    $processInfo.Arguments = $arguments
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo

    Write-Host "Processing file using ${compressionTool}: $file"

    # Start the compression process
    $process.Start() | Out-Null
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -eq 0) {
        # Remove the original file
        Remove-Item -Path $file -Force

        # Rename temp file to original file name
        Rename-Item -Path $tempFile -NewName $filename
    } else {
        # Compression failed, output error message
        Write-Host "Compression failed for file: $file" -ForegroundColor Red
        Write-Host "Output: $stdout" -ForegroundColor Yellow
        Write-Host "Error: $stderr" -ForegroundColor Yellow

        # Remove temp file if it exists
        if (Test-Path $tempFile) {
            Remove-Item -Path $tempFile -Force
        }
    }
}
