$output = "C:\Users\mwypchlo\Documents\zasoby.csv"
$interval = 30 # czas w sekundach między pomiarami
$processName = "Xopero.Device.App"

# Utworzenie pliku z nagłówkiem (jeśli jeszcze nie istnieje)
if (-not (Test-Path $output)) {
    "Czas,Proces,CPU_Proc,RAM_MB" | Out-File -FilePath $output -Encoding utf8
}

while ($true) {
    $czas = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($processes) {
        foreach ($proc in $processes) {
            # Pobranie aktualnego zużycia CPU (%) za pomocą licznika wydajności
            $cpuCounter = Get-Counter "\Process($($proc.Name))\ % Processor Time" -ErrorAction SilentlyContinue
            
            if ($cpuCounter) {
                # Licznik uwzględnia wszystkie rdzenie, dzielimy przez liczbę rdzeni logicznych
                $rawCpu = $cpuCounter.CounterSamples[0].CookedValue
                $cpuPercent = [math]::Round($rawCpu / $env:NUMBER_OF_PROCESSORS, 2)
            } else {
                $cpuPercent = 0
            }

            $ram = [math]::Round($proc.WorkingSet64 / 1MB, 2)

            "$czas,$($proc.Name),$cpuPercent,$ram" | Out-File -FilePath $output -Append -Encoding utf8
        }
    }

    Start-Sleep -Seconds $interval
}