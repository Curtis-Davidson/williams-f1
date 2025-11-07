# Purpose: Remove non-ASCII “smart” punctuation from a PowerShell script that causes
# misleading '{ unexpected' parser errors; then verify parse.
param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path -LiteralPath $Path)) {
    throw "File not found: $Path"
}

# --- 1) Show offending non-ASCII characters with offsets (for audit) ---
$raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
$offenders = @()
for ($i=0; $i -lt $raw.Length; $i++) {
    $c = [int][char]$raw[$i]
    if ($c -gt 127) {
        $offenders += [pscustomobject]@{
            Index     = $i
            Char      = $raw[$i]
            CodePoint = ('U+{0:X4}' -f $c)
            Context   = $raw.Substring([Math]::Max(0,$i-10), [Math]::Min(20, $raw.Length-([Math]::Max(0,$i-10))))
        }
    }
}
if ($offenders.Count -gt 0) {
    Write-Host ("[INFO] Found {0} non-ASCII characters (likely smart quotes/dashes). Fixing..." -f $offenders.Count) -ForegroundColor Yellow
    $offenders | Format-Table -AutoSize | Out-String | Write-Host
} else {
    Write-Host "[INFO] No non-ASCII characters detected; proceeding anyway." -ForegroundColor DarkGray
}

# --- 2) Normalise smart punctuation to ASCII ---
$clean = $raw
$repl = @{
    ([char]0x2018) = "'";  # ‘
    ([char]0x2019) = "'";  # ’
    ([char]0x201C) = '"';  # “
    ([char]0x201D) = '"';  # ”
    ([char]0x2013) = '-';  # –
    ([char]0x2014) = '-';  # —
    ([char]0x00A0) = ' ';  # NBSP
}
foreach ($k in $repl.Keys) {
    $clean = $clean -replace [Regex]::Escape([string]$k), [string]$repl[$k]
}

# --- 3) Save back as UTF-8 (no BOM) ---
Set-Content -LiteralPath $Path -Value $clean -Encoding UTF8
Write-Host "[OK] Normalised punctuation and saved: $Path" -ForegroundColor Green

# --- 4) Brace balance quick check ---
$opens  = ([regex]::Matches($clean, '\{')).Count
$closes = ([regex]::Matches($clean, '\}')).Count
Write-Host ("[CHECK] Braces: open={0} close={1}" -f $opens, $closes) -ForegroundColor Cyan
if ($opens -ne $closes) {
    Write-Warning "Brace count mismatch. The parser may still fail; search for unclosed blocks."
}

# --- 5) Parse verification without running the script ---
try {
    [ScriptBlock]::Create($clean) | Out-Null
    Write-Host "[PARSE] OK — script is syntactically valid." -ForegroundColor Green
} catch {
    Write-Error "[PARSE] FAIL: $($_.Exception.Message)"
    throw
}