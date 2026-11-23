$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }
$source = Join-Path $root "dist"
$dest = Join-Path ([Environment]::GetFolderPath("Desktop")) "paar-web-cpanel.zip"

if (-not (Test-Path (Join-Path $source "index.html"))) {
  Write-Error "dist\index.html was not found. Build did not produce the site."
}

$utf8 = New-Object System.Text.UTF8Encoding $false
function Copy-NoBom($from, $to) {
  $bytes = [System.IO.File]::ReadAllBytes($from)
  $start = 0
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $start = 3
  }
  $text = $utf8.GetString($bytes, $start, $bytes.Length - $start)
  [System.IO.File]::WriteAllText($to, $text, $utf8)
}

$uploadDir = Join-Path $source "uploads\chat"
New-Item -ItemType Directory -Force -Path $uploadDir | Out-Null
Copy-NoBom (Join-Path $root "cpanel\uploads.htaccess") (Join-Path $uploadDir ".htaccess")
Copy-NoBom (Join-Path $root "cpanel\index.php") (Join-Path $source "index.php")
Copy-NoBom (Join-Path $root "cpanel\.htaccess") (Join-Path $source ".htaccess")
[System.IO.File]::WriteAllText((Join-Path $source "deploy-id.txt"), (Get-Date -Format "yyyyMMddHHmmss"), $utf8)

$relative = @(Get-ChildItem -Path $source -Recurse -File | ForEach-Object {
  $_.FullName.Substring($source.Length + 1).Replace("\", "/")
})
if ($relative -notcontains "keep.txt") {
  $relative += "keep.txt"
}
[System.IO.File]::WriteAllText((Join-Path $source "keep.txt"), ($relative -join "`n"), $utf8)

if (Test-Path $dest) {
  try {
    Remove-Item $dest -Force
  } catch {
    throw "Could not replace the zip. Close paar-web-cpanel.zip if it is open, then run the script again."
  }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($dest, "Create")
try {
  Get-ChildItem -Path $source -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($source.Length + 1).Replace("\", "/")
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel)
  }
} finally {
  $zip.Dispose()
}

$check = [System.IO.Compression.ZipFile]::OpenRead($dest)
try {
  $hasIndex = $check.Entries | Where-Object { $_.FullName -eq "index.html" }
  $hasApi = $check.Entries | Where-Object { $_.FullName -eq "api/chat_request.php" }
  $hasCleaner = $check.Entries | Where-Object { $_.FullName -eq "index.php" }
  if (-not $hasIndex -or -not $hasApi -or -not $hasCleaner) {
    throw "Zip is missing index.html, index.php, or the api folder."
  }
  Write-Output ("Zipped {0} files to {1}" -f $check.Entries.Count, $dest)
} finally {
  $check.Dispose()
}
