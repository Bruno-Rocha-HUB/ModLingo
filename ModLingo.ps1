
$ErrorActionPreference = "Stop"

Clear-Host

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " VICTORIA 3 - ModLingo" -ForegroundColor Cyan
Write-Host " Automatic Workshop Converter" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

try {

    # ============================================
    # LOCALIZAR STEAM EM TODOS OS DISCOS
    # ============================================

    $steamRoots = @()

    # Registro do Windows
    try {
        $steamRegistry = Get-ItemProperty `
            -Path "HKCU:\Software\Valve\Steam" `
            -Name SteamPath `
            -ErrorAction SilentlyContinue

        if ($steamRegistry.SteamPath) {
            $steamRoots += $steamRegistry.SteamPath.Replace('/', '\')
        }
    }
    catch {}

    # Detectar todos os discos locais
    $drives = @(
        Get-CimInstance Win32_LogicalDisk |
        Where-Object { $_.DriveType -eq 3 }
    )

    foreach ($drive in $drives) {

        $letter = $drive.DeviceID

        Write-Host "[BUSCA] Verificando disco $letter" -ForegroundColor DarkGray

        $possibleRoots = @(
            "$letter\Steam",
            "$letter\SteamLibrary",
            "$letter\Games\Steam",
            "$letter\Games\SteamLibrary",
            "$letter\Program Files\Steam",
            "$letter\Program Files (x86)\Steam",
            "$letter\Program Files\SteamLibrary",
            "$letter\Program Files (x86)\SteamLibrary"
        )

        foreach ($path in $possibleRoots) {

            if (Test-Path -LiteralPath $path -ErrorAction SilentlyContinue) {
                $steamRoots += $path
            }
        }
    }

    $steamRoots = @(
        $steamRoots |
        Where-Object {
            $_ -and (Test-Path -LiteralPath $_ -ErrorAction SilentlyContinue)
        } |
        Select-Object -Unique
    )

    # ============================================
    # LOCALIZAR BIBLIOTECAS ADICIONAIS
    # ============================================

    $initialRoots = @($steamRoots)

    foreach ($root in $initialRoots) {

        $libraryFile = Join-Path $root "steamapps\libraryfolders.vdf"

        if (Test-Path -LiteralPath $libraryFile) {

            try {

                $vdf = Get-Content -LiteralPath $libraryFile -Raw

                $pathMatches = [regex]::Matches(
                    $vdf,
                    '(?m)^\s*"path"\s+"([^"]+)"'
                )

                foreach ($match in $pathMatches) {

                    $libraryPath = $match.Groups[1].Value.Replace('\\', '\')

                    if (Test-Path -LiteralPath $libraryPath -ErrorAction SilentlyContinue) {
                        $steamRoots += $libraryPath
                    }
                }
            }
            catch {
                Write-Host "[AVISO] Erro ao ler $libraryFile" -ForegroundColor Yellow
            }
        }
    }

    $steamRoots = @($steamRoots | Select-Object -Unique)

    # ============================================
    # LOCALIZAR WORKSHOP DO VICTORIA 3
    # ============================================

    $workshopPaths = @()

    foreach ($root in $steamRoots) {

        $workshop = Join-Path $root "steamapps\workshop\content\529340"

        if (Test-Path -LiteralPath $workshop -ErrorAction SilentlyContinue) {
            $workshopPaths += $workshop
        }
    }

    $workshopPaths = @($workshopPaths | Select-Object -Unique)

    if ($workshopPaths.Count -eq 0) {
        throw "Workshop do Victoria 3 nao encontrado."
    }

    Write-Host ""
    Write-Host "Bibliotecas Steam: $($steamRoots.Count)" -ForegroundColor Green
    Write-Host "Workshops encontrados: $($workshopPaths.Count)" -ForegroundColor Green

    # ============================================
    # DESCOBRIR IDIOMAS DISPONIVEIS
    # ============================================

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " PROCURANDO IDIOMAS DISPONIVEIS" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    # Hashtable para evitar idiomas duplicados
    $availableLanguages = @{}

    # Pastas de localizacao do jogo
    $gameLocalizationPaths = @()

    foreach ($root in $steamRoots) {

        $possibleGamePaths = @(
            (Join-Path $root "steamapps\common\Victoria 3\game\localization"),
            (Join-Path $root "steamapps\common\Victoria 3\localization")
        )

        foreach ($path in $possibleGamePaths) {

            if (Test-Path -LiteralPath $path -ErrorAction SilentlyContinue) {
                $gameLocalizationPaths += $path
            }
        }
    }

    # Adicionar idiomas encontrados em uma pasta localization
    function Find-Languages {

        param (
            [string]$LocalizationPath
        )

        if (-not (Test-Path -LiteralPath $LocalizationPath)) {
            return
        }

        $languageFolders = @(
            Get-ChildItem -LiteralPath $LocalizationPath -Directory -ErrorAction SilentlyContinue
        )

        foreach ($folder in $languageFolders) {

            $languageCode = $folder.Name.ToLowerInvariant()

            # English e a lingua de origem
            if ($languageCode -eq "english") {
                continue
            }

            # Verifica se existem arquivos YML
            $ymlFiles = @(
                Get-ChildItem -LiteralPath $folder.FullName -Filter "*.yml" -File -ErrorAction SilentlyContinue
            )

            if ($ymlFiles.Count -gt 0) {
                $availableLanguages[$languageCode] = $languageCode
            }
        }
    }

    # Procurar idiomas no jogo
    foreach ($path in $gameLocalizationPaths) {
        Find-Languages -LocalizationPath $path
    }

    # Procurar idiomas em todos os mods do Workshop
    foreach ($basePath in $workshopPaths) {

        $mods = @(
            Get-ChildItem -LiteralPath $basePath -Directory -ErrorAction SilentlyContinue
        )

        foreach ($mod in $mods) {

            $localizationPath = Join-Path $mod.FullName "localization"

            Find-Languages -LocalizationPath $localizationPath
        }
    }

    # ============================================
    # NOMES DOS IDIOMAS
    # ============================================

    $languageNames = @{
        "braz_por"     = "Portugues Brasileiro"
        "french"       = "Frances"
        "german"       = "Alemao"
        "spanish"      = "Espanhol"
        "russian"      = "Russo"
        "simp_chinese" = "Chines Simplificado"
        "japanese"     = "Japones"
        "korean"       = "Coreano"
        "polish"       = "Polones"
        "italian"      = "Italiano"
        "dutch"        = "Holandes"
        "portuguese"   = "Portugues"
        "turkish"      = "Turco"
        "ukrainian"    = "Ucraniano"
        "hungarian"    = "Hungaro"
        "czech"        = "Tcheco"
        "swedish"      = "Sueco"
        "danish"       = "Dinamarques"
        "norwegian"    = "Noruegues"
        "finnish"      = "Finlandes"
        "greek"        = "Grego"
        "arabic"       = "Arabe"
    }

    # Organizar idiomas
    $languageList = @(
        $availableLanguages.Keys | Sort-Object
    )

    if ($languageList.Count -eq 0) {
        throw "Nenhum idioma de destino foi encontrado nas pastas do jogo ou dos mods."
    }

    # ============================================
    # MENU DE SELECAO DE IDIOMA
    # ============================================

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " SELECIONE O IDIOMA DE DESTINO" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $languageList.Count; $i++) {

        $code = $languageList[$i]

        if ($languageNames.ContainsKey($code)) {
            $displayName = $languageNames[$code]
        }
        else {
            $displayName = $code
        }

        Write-Host " [$($i + 1)] $displayName ($code)" -ForegroundColor White
    }

    Write-Host ""
    Write-Host " [0] Sair" -ForegroundColor Red
    Write-Host ""

    # Validar escolha
    do {

        $selection = Read-Host "Digite o numero do idioma desejado"

        $validSelection = $false

        if ($selection -match '^\d+$') {

            $number = [int]$selection

            if ($number -eq 0) {
                Write-Host "Operacao cancelada." -ForegroundColor Yellow
                return
            }

            if ($number -ge 1 -and $number -le $languageList.Count) {
                $validSelection = $true
            }
        }

        if (-not $validSelection) {
            Write-Host "Opcao invalida. Tente novamente." -ForegroundColor Red
        }

    } until ($validSelection)

    $selectedLanguage = $languageList[$number - 1]

    Write-Host ""
    Write-Host "Idioma selecionado: $selectedLanguage" -ForegroundColor Green

    # ============================================
    # CONTADORES
    # ============================================

    $totalMods = 0
    $processedMods = 0
    $createdFiles = 0
    $skippedFiles = 0
    $alreadyConverted = 0
    $errors = 0

    # ============================================
    # PROCESSAMENTO DOS MODS
    # ============================================

    foreach ($basePath in $workshopPaths) {

        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host " ANALISANDO WORKSHOP" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan

        Write-Host $basePath -ForegroundColor Gray

        $mods = @(
            Get-ChildItem -LiteralPath $basePath -Directory -ErrorAction SilentlyContinue
        )

        foreach ($mod in $mods) {

            $totalMods++

            Write-Host ""
            Write-Host "Analisando mod: $($mod.Name)" -ForegroundColor Cyan

            $localizationPath = Join-Path $mod.FullName "localization"
            $englishPath = Join-Path $localizationPath "english"
            $destinationPath = Join-Path $localizationPath $selectedLanguage

            # Verificar localization/english
            if (-not (Test-Path -LiteralPath $englishPath)) {

                Write-Host "[IGNORADO] Pasta english nao encontrada." -ForegroundColor DarkGray
                continue
            }

            # Verificar se ja existe pasta de destino
            if (Test-Path -LiteralPath $destinationPath) {

                Write-Host "[AVISO] Pasta $selectedLanguage ja existe." -ForegroundColor Yellow
                Write-Host "[INFO] Serao adicionados somente arquivos ausentes." -ForegroundColor Yellow

                $alreadyConverted++
            }

            # Localizar arquivos YML
            $files = @(
                Get-ChildItem -LiteralPath $englishPath -Filter "*.yml" -File -ErrorAction SilentlyContinue
            )

            if ($files.Count -eq 0) {

                Write-Host "[IGNORADO] Nenhum arquivo YML encontrado." -ForegroundColor DarkGray
                continue
            }

            $modChanged = $false

            foreach ($file in $files) {

                try {

                    # Alterar nome do arquivo
                    $newFileName = $file.Name -replace "_l_english(?=\.yml$)", "_l_$selectedLanguage"

                    if ($newFileName -eq $file.Name) {

                        Write-Host "[IGNORADO] Nome inesperado: $($file.Name)" -ForegroundColor Yellow

                        $skippedFiles++
                        continue
                    }

                    $destFile = Join-Path $destinationPath $newFileName

                    # Nunca sobrescrever arquivos existentes
                    if (Test-Path -LiteralPath $destFile) {

                        Write-Host "[IGNORADO] Arquivo existente: $newFileName" -ForegroundColor Yellow

                        $skippedFiles++
                        continue
                    }

                    # Ler arquivo original
                    $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8

                    # Verificar cabecalho
                    if (
                        $content.Count -eq 0 -or
                        $content[0] -notmatch "^l_english:"
                    ) {

                        Write-Host "[AVISO] Cabecalho inesperado: $($file.Name)" -ForegroundColor Yellow

                        $errors++
                        continue
                    }

                    # Criar pasta de destino
                    if (-not (Test-Path -LiteralPath $destinationPath)) {

                        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                    }

                    # Alterar cabecalho
                    $content[0] = "l_$selectedLanguage`:"

                    # Salvar novo arquivo
                    Set-Content `
                        -LiteralPath $destFile `
                        -Value $content `
                        -Encoding UTF8 `
                        -ErrorAction Stop

                    Write-Host "[OK] $newFileName" -ForegroundColor Green

                    $createdFiles++
                    $modChanged = $true

                }
                catch {

                    Write-Host "[ERRO] $($file.Name)" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red

                    $errors++
                }
            }

            if ($modChanged) {
                $processedMods++
            }
        }
    }

    # ============================================
    # RELATORIO FINAL
    # ============================================

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " PROCESSAMENTO FINALIZADO" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Idioma escolhido: $selectedLanguage" -ForegroundColor Cyan
    Write-Host "Mods analisados: $totalMods" -ForegroundColor White
    Write-Host "Mods modificados: $processedMods" -ForegroundColor Green
    Write-Host "Arquivos criados: $createdFiles" -ForegroundColor Green
    Write-Host "Arquivos ignorados: $skippedFiles" -ForegroundColor Yellow
    Write-Host "Mods com pasta de destino existente: $alreadyConverted" -ForegroundColor Yellow
    Write-Host "Erros: $errors" -ForegroundColor Red

    Write-Host ""
    Write-Host "Obrigado por utilizar ModLingo" -ForegroundColor Cyan

}
catch {

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " ERRO NA EXECUCAO" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red

    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host ""
    Write-Host "Detalhes:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
}

# ============================================
# DIVULGACAO DO CANAL
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " OBRIGADO POR UTILIZAR O CONVERSOR!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Curte Victoria 3 e outros jogos de estrategia?" -ForegroundColor White
Write-Host "Inscreva-se no canal Bruno Rocha Joga!" -ForegroundColor Yellow
Write-Host ""
Write-Host "YouTube:" -ForegroundColor White
Write-Host "https://youtube.com/@brunorochajoga?sub_confirmation=1" -ForegroundColor Red

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

Read-Host "Pressione Enter para sair"
