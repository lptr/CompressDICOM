# CompressDICOM.ps1

PowerShell Script to Compress DICOM Files Using dcmcjpeg

## Usage

Enable PowerShell script execution; without this step, the script will not run

```pwsh
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run the script with the root directory as the argument to compress

```pwsh
dicompress.ps1 <DIR>
```

Run with the decompression tool instead to revert

```pwsh
dicompress.ps1 <DIR> "dcmdjpls"
```
