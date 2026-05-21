# OSRS Flipper local web server.
# Right-click → "Run with PowerShell" (or run `powershell -ExecutionPolicy Bypass -File .\server.ps1`).
# Serves this folder over http://localhost:8080 and opens the page in your default browser.

$ErrorActionPreference = "Stop"
$port = 8080
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexFile = "index.html"

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "text/javascript; charset=utf-8"
  ".mjs"  = "text/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
  ".webp" = "image/webp"
  ".txt"  = "text/plain; charset=utf-8"
  ".map"  = "application/json; charset=utf-8"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() }
catch {
  Write-Host "Could not start the server on port $port. Is another server already running?" -ForegroundColor Red
  Write-Host $_.Exception.Message
  Read-Host "Press Enter to close"
  exit 1
}

Write-Host "OSRS Flipper server running:" -ForegroundColor Green
Write-Host "  Root : $root"
Write-Host "  URL  : http://localhost:$port/$indexFile"
Write-Host ""
Write-Host "Leave this window open while you use the app. Close it to stop." -ForegroundColor Yellow
Write-Host ""

# Open in default browser
Start-Process "http://localhost:$port/$indexFile"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response

    try {
      $rel = [System.Uri]::UnescapeDataString($req.Url.LocalPath).TrimStart('/')
      if ([string]::IsNullOrEmpty($rel)) { $rel = $indexFile }
      $full = Join-Path $root $rel

      # Prevent path-traversal outside the root
      $resolved = [System.IO.Path]::GetFullPath($full)
      $rootFull = [System.IO.Path]::GetFullPath($root)
      if (-not $resolved.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        $res.StatusCode = 403
        $res.Close()
        continue
      }

      if (Test-Path -LiteralPath $resolved -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($resolved)
        $ext = [System.IO.Path]::GetExtension($resolved).ToLowerInvariant()
        $res.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
        $res.StatusCode = 200
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $res.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rel")
        $res.OutputStream.Write($msg, 0, $msg.Length)
      }
    } catch {
      try {
        $res.StatusCode = 500
        $msg = [System.Text.Encoding]::UTF8.GetBytes("500: $($_.Exception.Message)")
        $res.OutputStream.Write($msg, 0, $msg.Length)
      } catch {}
    } finally {
      try { $res.Close() } catch {}
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
