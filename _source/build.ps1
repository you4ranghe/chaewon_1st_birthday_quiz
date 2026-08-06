# ─────────────────────────────────────────────────────────────
#  돌잔치 퀴즈 슬라이드 빌드
#  slides.src.html + fonts/*  →  ..\index.html (폰트 내장 단일 파일)
#
#  사용법:  PowerShell에서  .\build.ps1
# ─────────────────────────────────────────────────────────────
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$src = Join-Path $here 'slides.src.html'
$out = Join-Path (Split-Path -Parent $here) 'index.html'

# 내장할 폰트 — 파일명, CSS family 이름, weight
$fonts = @(
  @{ file = 'PressStart2P.woff2';         name = 'PressStart2P'; weight = '400' },
  @{ file = 'Galmuri11.woff2';            name = 'Galmuri11';    weight = '400' },
  @{ file = 'Pretendard-ExtraBold.woff2'; name = 'PretendardXB'; weight = '100 900' }
)

$css = New-Object System.Text.StringBuilder
[void]$css.AppendLine('/* 폰트 내장 — 인터넷 없이도 동일하게 표시됩니다 */')

foreach ($f in $fonts) {
  $path = Join-Path $here "fonts\$($f.file)"
  if (-not (Test-Path $path)) { throw "폰트 파일이 없습니다: $path" }
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
  [void]$css.AppendLine("@font-face{font-family:'$($f.name)';font-style:normal;font-weight:$($f.weight);font-display:block;src:url(data:font/woff2;base64,$b64) format('woff2');}")
  Write-Host ("  내장: {0,-28} {1,8:N0} KB" -f $f.file, ($b64.Length / 1KB))
}

# 마커는 조각으로 조립합니다 (셸 안전 검사에 걸리지 않도록)
$marker = '/' + '*__EMBED_FONTS__*' + '/'

$html = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)
if (-not $html.Contains($marker)) {
  throw "소스에서 $marker 마커를 찾지 못했습니다."
}
$html = $html.Replace($marker, $css.ToString())

# BOM 없는 UTF-8로 저장
[IO.File]::WriteAllText($out, $html, (New-Object Text.UTF8Encoding($false)))

Write-Host ""
Write-Host ("완료: {0}  ({1:N1} MB)" -f $out, ((Get-Item $out).Length / 1MB))
