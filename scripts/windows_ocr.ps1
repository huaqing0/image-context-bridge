param(
    [Parameter(Mandatory=$true)][string]$Path,
    [string]$Language = ""
)

$ErrorActionPreference = "Stop"

function Emit-Json($obj) {
    $obj | ConvertTo-Json -Depth 8 -Compress:$false
}

try {
    $full = [System.IO.Path]::GetFullPath($Path)
    if (-not [System.IO.File]::Exists($full)) {
        throw "File not found: $full"
    }

    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
    [Windows.Storage.FileAccessMode, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
    [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime] | Out-Null
    [Windows.Graphics.Imaging.SoftwareBitmap, Windows.Graphics.Imaging, ContentType = WindowsRuntime] | Out-Null
    [Windows.Media.Ocr.OcrEngine, Windows.Foundation.UniversalApiContract, ContentType = WindowsRuntime] | Out-Null
    [Windows.Globalization.Language, Windows.Foundation.UniversalApiContract, ContentType = WindowsRuntime] | Out-Null

    function Await($Async, [Type]$ResultType) {
        $methods = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
            $_.Name -eq "AsTask" -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1
        }
        $method = $methods | Select-Object -First 1
        $task = $method.MakeGenericMethod($ResultType).Invoke($null, @($Async))
        $task.Wait() | Out-Null
        return $task.Result
    }

    $file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($full)) ([Windows.Storage.StorageFile])
    $stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
    $decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
    $bitmap = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])

    $engine = $null
    if ($Language -ne "") {
        $langObj = [Windows.Globalization.Language]::new($Language)
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($langObj)
    }
    if ($null -eq $engine) {
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    }
    if ($null -eq $engine) {
        throw "Windows OCR engine is not available for the current user languages."
    }

    $result = Await ($engine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])
    $items = @()
    foreach ($line in $result.Lines) {
        foreach ($word in $line.Words) {
            $rect = $word.BoundingRect
            $items += [PSCustomObject]@{
                text = $word.Text
                confidence = $null
                box = [PSCustomObject]@{
                    x = $rect.X
                    y = $rect.Y
                    width = $rect.Width
                    height = $rect.Height
                }
            }
        }
    }

    Emit-Json ([PSCustomObject]@{
        ok = $true
        engine = "windows_ocr"
        items = $items
        error = $null
    })
} catch {
    Emit-Json ([PSCustomObject]@{
        ok = $false
        engine = "windows_ocr"
        items = @()
        error = $_.Exception.Message
    })
    exit 1
}
