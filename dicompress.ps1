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

# Enable ANSI support if needed (for older versions, typically not needed in Windows Terminal)
$Host.UI.RawUI.FlushInputBuffer()  # Optional, clears leftover input

# Get all .dcm files recursively from the root directory
$files = Get-ChildItem -Path $rootDir -File -Recurse
$total = $files.Count
$index = 0

foreach ($fileInfo in $files) {
    $index++
    $file = $fileInfo.FullName
    $dir = $fileInfo.DirectoryName
    $filename = $fileInfo.Name

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

    $percent = [math]::Round(($index / $total) * 100)
    Write-Host "`r[$percent%] Processing: $filename" -NoNewline

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
        Write-Host ""
        Write-Host "Compression failed for file: $file" -ForegroundColor Red
        Write-Host "Output: $stdout" -ForegroundColor Yellow
        Write-Host "Error: $stderr" -ForegroundColor Yellow

        # Remove temp file if it exists
        if (Test-Path $tempFile) {
            Remove-Item -Path $tempFile -Force
        }
    }
}

# Move to a new line at the end
Write-Host "`r[100%] Done.`n"
