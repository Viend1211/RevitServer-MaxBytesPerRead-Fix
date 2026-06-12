[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

chcp 65001 > $null

Clear-Host

$LogFile = "$PSScriptRoot\RevitServerFix.log"

function Write-Log {
    param([string]$Text)

    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Text"

    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

Clear-Host

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Revit Server Config Manager" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$base = "C:\Program Files\Autodesk"

$servers = Get-ChildItem $base -Directory | Where-Object {
    $_.Name -like "Revit Server*"
}

if ($servers.Count -eq 0) {

    Write-Host "Revit Server не найден." -ForegroundColor Red
    pause
    exit
}

Write-Host "Найденные версии:" -ForegroundColor Yellow
Write-Host ""

for ($i = 0; $i -lt $servers.Count; $i++) {

    Write-Host "[$($i+1)] $($servers[$i].Name)"
}

Write-Host ""
Write-Host "[A] Все версии"
Write-Host ""

$choice = Read-Host "Выберите номера через запятую или A"

$selectedServers = @()

if ($choice.ToUpper() -eq "A") {

    $selectedServers = $servers
}
else {

    $indexes = $choice -split ","

    foreach ($idx in $indexes) {

        try {

            $n = [int]$idx.Trim() - 1

            if ($n -ge 0 -and $n -lt $servers.Count) {

                $selectedServers += $servers[$n]
            }

        } catch {}
    }
}

if ($selectedServers.Count -eq 0) {

    Write-Host ""
    Write-Host "Ничего не выбрано." -ForegroundColor Red
    pause
    exit
}

Write-Host ""
Write-Host "Выберите режим:" -ForegroundColor Yellow
Write-Host ""
Write-Host "[1] Установить 102400"
Write-Host "[2] Вернуть stock 4096"
Write-Host ""

$mode = Read-Host "Введите номер"

switch ($mode) {

    "1" {
        $oldValue = 'maxBytesPerRead="4096"'
        $newValue = 'maxBytesPerRead="102400"'
        $modeText = "SET 102400"
    }

    "2" {
        $oldValue = 'maxBytesPerRead="102400"'
        $newValue = 'maxBytesPerRead="4096"'
        $modeText = "RESTORE 4096"
    }

    default {

        Write-Host "Неверный режим." -ForegroundColor Red
        pause
        exit
    }
}

Write-Log "========== START =========="
Write-Log "MODE: $modeText"

# Службы
Write-Log "Stopping Revit Server services..."

$services = Get-Service | Where-Object {
    $_.DisplayName -like "*Revit Server*" -or
    $_.Name -like "*RevitServer*"
}

foreach ($svc in $services) {

    try {

        if ($svc.Status -ne 'Stopped') {

            Write-Log "Stopping: $($svc.DisplayName)"

            Stop-Service $svc.Name -Force
        }

    } catch {

        Write-Log "ERROR stopping service: $($_.Exception.Message)"
    }
}

# Изменение файлов
foreach ($server in $selectedServers) {

    Write-Log "Version: $($server.Name)"

    $files = @(
        (Join-Path $server.FullName "Services\ModelService\web.config"),
        (Join-Path $server.FullName "Services\LocalService\web.config")
    )

    foreach ($file in $files) {

        if (Test-Path $file) {

            try {

                Write-Log "Processing: $file"

                # backup
                Copy-Item $file "$file.bak" -Force

                # content
                $content = Get-Content $file -Raw

                # replace
                $newContent = $content -replace $oldValue, $newValue

                # save
                Set-Content $file $newContent -Encoding UTF8

                Write-Log "SUCCESS"

            }
            catch {

                Write-Log "ERROR file: $($_.Exception.Message)"
            }

        }
        else {

            Write-Log "NOT FOUND: $file"
        }
    }
}

# Запуск служб
Write-Log "Starting Revit Server services..."

foreach ($svc in $services) {

    try {

        Write-Log "Starting: $($svc.DisplayName)"

        Start-Service $svc.Name

    }
    catch {

        Write-Log "ERROR starting service: $($_.Exception.Message)"
    }
}

Write-Log "=========== FINISH ==========="

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "                 ГОТОВО" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

pause