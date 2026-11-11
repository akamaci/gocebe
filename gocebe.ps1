<#
================================================================================
  GOCEBE  v1.0.0   -  Site tasima tezgahi
  PHP / HTML / WordPress  ->  WordPress

  AMAC: site kopyalamak DEGIL. Tasima yapanlara kolaylik saglamak.
  Her calistirmada 3 yorum ZORUNLU uretilir: 1:1 / Benzer+Modern / Yeniden.

  Kullanim:
    gocebe.ps1 https://ornek.com
    gocebe.ps1 C:\xampp\htdocs\eski-site
    gocebe.ps1 <kaynak> --proje=ad --hedef=wp-site --devam
    gocebe.ps1 <kaynak> --sessiz          (soru sormaz, varsayilanla gider)

  Cikti:
    <proje>\01-orjinal-kopya\   ETIKET.md
    <proje>\02-benzer-modern\   ETIKET.md
    <proje>\03-yeni-tasarim\    ETIKET.md
    <proje>\_envanter\ENVANTER.md
    <proje>\_referans\notlar.md
    <proje>\KONTRAT.md
================================================================================
#>
# -- PowerShell 5.1 kendi parametre cozumleyicisi "--proje=x" bicimini reddeder.
# -- Bu yuzden TUM argumanlari elle ayristiriyoruz (hem --ad=x hem -Ad x calisir).
$Kaynak = $null; $Proje = $null; $Hedef = $null; $Cikti = $null; $Mod = $null
$Sessiz = $false; $Devam = $false; $Yardim = $false

$i = 0
while ($i -lt $args.Count) {
    $a = [string]$args[$i]
    $sonraki = if ($i + 1 -lt $args.Count) { [string]$args[$i + 1] } else { $null }

    if ($a -match '^--?(proje|hedef|cikti|mod)(=(.*))?$') {
        $ad = $Matches[1]
        $deger = if ($Matches[2]) { $Matches[3] } else { $sonraki; $i++ }
        switch ($ad) {
            'proje' { $Proje = $deger }
            'hedef' { $Hedef = $deger }
            'cikti' { $Cikti = $deger }
            'mod'   { $Mod   = $deger }
        }
    }
    elseif ($a -match '^--?(sessiz|devam|yardim|help|\?)$') {
        switch ($Matches[1]) {
            'sessiz' { $Sessiz = $true }
            'devam'  { $Devam  = $true }
            default  { $Yardim = $true }
        }
    }
    elseif ($a -notmatch '^-' -and -not $Kaynak) {
        $Kaynak = $a
    }
    $i++
}

$ErrorActionPreference = 'Stop'
$SURUM = '1.0.0'
$KOK   = $PSScriptRoot

# ---------------------------------------------------------------- yardimcilar
function Yaz([string]$m, [string]$renk = 'Gray') { Write-Host $m -ForegroundColor $renk }
function Baslik([string]$m) {
    Write-Host ''
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
    Write-Host "  $m" -ForegroundColor Cyan
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
}
function U8([string]$yol, [string]$metin) {
    $d = Split-Path $yol -Parent
    if ($d -and -not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    [IO.File]::WriteAllText($yol, $metin, (New-Object Text.UTF8Encoding($false)))
}
function Slug([string]$s) {
    $s = $s.ToLowerInvariant()
    $map = @{ 'ç'='c'; 'ğ'='g'; 'ı'='i'; 'ö'='o'; 'ş'='s'; 'ü'='u'; 'â'='a'; 'î'='i'; 'û'='u' }
    foreach ($k in $map.Keys) { $s = $s.Replace($k, $map[$k]) }
    $s = [regex]::Replace($s, '[^a-z0-9]+', '-')
    return $s.Trim('-')
}

# ---------------------------------------------------------------- kullanimi yaz
function Kullanim {
    Write-Host @"
GOCEBE v$SURUM - site tasima tezgahi

KULLANIM
  gocebe.ps1 <kaynak> [secenekler]

  <kaynak>   https://site.com  |  C:\xampp\htdocs\site  |  .\klasor

SECENEKLER
  --proje=<ad>     proje klasor adi (varsayilan: kaynaktan turetilir)
  --hedef=<ad>     hedef WordPress site adi
  --cikti=<yol>    cikti kok klasoru (varsayilan: .\gocebe-cikti)
  --mod=<1|2|3>    tek mod (digerleri iskelet olarak yine kurulur)
  --sessiz         soru sormaz, varsayilanlarla ilerler
  --devam          yarim kalan projeyi surdurur (%50 kapisi)
  --yardim         bu metin

NOT
  Her calistirmada UC yorum ZORUNLU uretilir:
    01-orjinal-kopya  (1:1 ayni)
    02-benzer-modern  (kimlik korunur, dokunus modern)
    03-yeni-tasarim   (yalniz icerik + logo)
"@ -ForegroundColor Gray
}

if ($Yardim -or (-not $Kaynak -and -not $Devam)) { Kullanim; exit 0 }

Baslik "GOCEBE v$SURUM  -  site tasima tezgahi"
Yaz "  AMAC: site KOPYALAMAK degil. Tasima yapanlara KOLAYLIK saglamak." 'Yellow'
Yaz "  Yalnizca hakkiniz olan siteleri tasiyin. Baskasinin tasarimini" 'DarkYellow'
Yaz "  kendi eseriniz gibi sunmak bu aracin AMACI DISINDADIR." 'DarkYellow'

# ---------------------------------------------------------------- kaynak cozumle
$kaynakTip = 'bilinmiyor'
$kaynakAd  = ''
$yerelYol  = $null
$url       = $null

if ($Sessiz -eq $false -and -not $Kaynak -and -not $Devam -and -not $Sessiz) { }

if ($Kaynak) {
    if ($Kaynak -match '^https?://') {
        $url = $Kaynak.TrimEnd('/')
        $kaynakAd = ([uri]$url).Host -replace '^www\.', ''
        $kaynakTip = 'uzak'
    }
    elseif (Test-Path $Kaynak) {
        $yerelYol = (Resolve-Path $Kaynak).Path
        $kaynakAd = Split-Path $yerelYol -Leaf
        $kaynakTip = 'yerel'
    }
    else {
        Yaz "[HATA] Kaynak bulunamadi: $Kaynak" 'Red'; exit 1
    }
}

# ---------------------------------------------------------------- yerel tip tespiti
function YerelTipTespit([string]$yol) {
    # NOT: ordered hashtable yerine normal hashtable kullaniyoruz; boylece
    # sonradan 'temaYol' gibi anahtar ekleyebiliyoruz.
    $r = @{ platform = 'HTML/statik'; php = $false; wp = $false; elementor = $false; gutenberg = $false; phpSurum = ''; notlar = @(); temaYol = $null; temaAd = $null }

    if (-not (Test-Path $yol)) { return $r }

    # WordPress izleri
    if (Test-Path (Join-Path $yol 'wp-config.php')) { $r.wp = $true; $r.notlar += 'wp-config.php bulundu' }
    $wpinc = Join-Path $yol 'wp-includes'
    if (Test-Path $wpinc) { $r.wp = $true }
    if ($r.wp) { $r.platform = 'WordPress' }

    # Elementor
    $elDir = Join-Path $yol 'wp-content\plugins\elementor'
    if (Test-Path $elDir) { $r.elementor = $true; $r.notlar += 'Elementor eklentisi kurulu' }
    else {
        $elTema = Get-ChildItem (Join-Path $yol 'wp-content\themes') -Recurse -Directory -Depth 2 -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -eq 'elementor' } | Select-Object -First 1
        if ($elTema) { $r.elementor = $true; $r.notlar += 'Tema icinde elementor dizini' }
    }

    # Aktif tema (CSS taramasi icin sart)
    $temaKok = Join-Path $yol 'wp-content\themes'
    if (Test-Path $temaKok) {
        $temalar = Get-ChildItem $temaKok -Directory -ErrorAction SilentlyContinue
        $aday = $null
        foreach ($t in $temalar) {
            if ((Test-Path (Join-Path $t.FullName 'style.css')) -and
                -not (Test-Path (Join-Path $t.FullName 'index.php'))) { continue }
            if ($t.Name -match 'twenty|twentytwenty') { if (-not $aday) { $aday = $t } ; continue }
            # en cok php dosyasi olan temayi aktif say (kaba ama ise yarar)
            $say = (Get-ChildItem $t.FullName -Recurse -Filter '*.php' -File -ErrorAction SilentlyContinue).Count
            if (-not $aday -or $say -gt $aday.Say) { $aday = [pscustomobject]@{ FullName = $t.FullName; Name = $t.Name; Say = $say } }
        }
        if ($aday) { $r['temaYol'] = $aday.FullName; $r['temaAd'] = $aday.Name; $r.notlar += "Tema: $($aday.Name)" }
    }

    # PHP dosyalari
    $phpDosya = Get-ChildItem $yol -Filter '*.php' -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($phpDosya -or (Test-Path (Join-Path $yol 'index.php'))) {
        $r.php = $true
        if (-not $r.wp) { $r.platform = 'PHP (klasik)' }
    }

    # PHP surum ipucu (yorumlarda / header'larda)
    $ipucu = Get-ChildItem $yol -Filter '*.php' -File -ErrorAction SilentlyContinue |
             Select-Object -First 40 |
             Select-String -Pattern 'PHP\s*(5\.[0-9]|7\.[0-9]|8\.[0-9])' -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($ipucu) { $r.phpSurum = $ipucu.Matches[0].Value }

    # Statik
    if (-not $r.php -and -not $r.wp) {
        $html = Get-ChildItem $yol -Filter '*.html' -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($html) { $r.platform = 'HTML/statik'; $r.notlar += 'index html: ' + $html.Name }
    }
    return $r
}

$tip = $null
if ($kaynakTip -eq 'yerel') {
    $tip = YerelTipTespit $yerelYol
    Yaz ''
    Yaz "  Kaynak    : $yerelYol" 'White'
    Yaz "  Platform  : $($tip.platform)" 'Green'
    if ($tip.php)      { Yaz "  PHP       : evet$(if($tip.phpSurum){" ($($tip.phpSurum))"})" 'Green' }
    if ($tip.wp)       { Yaz "  WordPress : evet" 'Green' }
    if ($tip.elementor){ Yaz "  Elementor : evet" 'Green' }
    foreach ($n in $tip.notlar) { Yaz "    - $n" 'DarkGray' }
}
elseif ($kaynakTip -eq 'uzak') {
    Yaz ''
    Yaz "  Kaynak    : $url" 'White'
    try {
        $yanit = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        $html = $yanit.Content
        $wpIpucu = ($html -match 'wp-content|wp-includes')
        $elIpucu = ($html -match 'elementor')
        $genIpucu = ($html -match 'wp-block|gutenberg')
        $phpIpucu = ($html -match '\.php')
        $plat = if ($wpIpucu) { 'WordPress' } elseif ($phpIpucu) { 'PHP (klasik)' } else { 'HTML/statik' }
        $tip = [ordered]@{
            platform = $plat; wp = [bool]$wpIpucu; php = [bool]$phpIpucu
            elementor = [bool]$elIpucu; gutenberg = [bool]$genIpucu
            phpSurum = ''; notlar = @("HTTP $($yanit.StatusCode)", "$([math]::Round($html.Length/1KB)) KB HTML")
        }
        Yaz "  Platform  : $plat" 'Green'
        if ($elIpucu) { Yaz "  Elementor : evet" 'Green' }
        if ($genIpucu) { Yaz "  Gutenberg : evet" 'Green' }
    }
    catch {
        Yaz "  [UYARI] Site okunamadi: $($_.Exception.Message)" 'Yellow'
        $tip = [ordered]@{ platform = 'bilinmiyor'; wp = $false; php = $false; elementor = $false; gutenberg = $false; phpSurum = ''; notlar = @('erisilemedi') }
    }
}

# ---------------------------------------------------------------- proje adi
if (-not $Proje) {
    $oneri = Slug $kaynakAd
    if (-not $oneri) { $oneri = 'proje' }
    if ($Sessiz) { $Proje = $oneri }
    else {
        Yaz ''
        Do {
            $g = Read-Host "  Proje adi [$oneri]"
            if ([string]::IsNullOrWhiteSpace($g)) { $Proje = $oneri } else { $Proje = Slug $g }
        } While ([string]::IsNullOrWhiteSpace($Proje))
    }
}
if (-not $Hedef) {
    if ($Sessiz) { $Hedef = "$Proje-wp" }
    else {
        $g = Read-Host "  Hedef WordPress site adi [$Proje-wp]"
        $Hedef = if ([string]::IsNullOrWhiteSpace($g)) { "$Proje-wp" } else { $g.Trim() }
    }
}
if (-not $Cikti) { $Cikti = Join-Path (Get-Location) 'gocebe-cikti' }
$projeKok = Join-Path $Cikti $Proje

# ---------------------------------------------------------------- mod aciklamasi
$MODLAR = @(
    [pscustomobject]@{
        No = 1; Klasor = '01-orjinal-kopya'; Etiket = 'ORİJİNAL'
        Ad = 'Birebir (1:1)'
        Ozet = 'Eski sitenin düzeni, ölçüsü, boşlukları ve tipografisi AYNEN korunur. Yalnız motor değişir.'
        Kilitli = 'Düzen · ölçü · boşluk · tipografi · renk · görsel · menü · bölüm sırası · içerik'
        Modern = '(yok) — hiçbir görsel yenileme yapılmaz'
        Serbest = '(yok)'
        Emek = 'Düşük'
    },
    [pscustomobject]@{
        No = 2; Klasor = '02-benzer-modern'; Etiket = 'MODERN'
        Ad = 'Benzer + Modern'
        Ozet = 'Sitenin kimliği korunur; boşluk, tipografi ölçeği, köşe/gölge ve hafif hareketler modernize edilir.'
        Kilitli = 'Renk paleti (hex) · logo · görseller · bölüm sırası · menü yapısı · içerik metni'
        Modern = 'Boşluk ölçeği · tipografi boyutları · köşe yuvarlaklığı · gölge · hafif animasyon/geçiş'
        Serbest = '(kilitli olmayan ince dokunuşlar, ön izleme onayı ile)'
        Emek = 'Yüksek — asıl tasarım işi burada'
    },
    [pscustomobject]@{
        No = 3; Klasor = '03-yeni-tasarim'; Etiket = 'YENİ'
        Ad = 'Yeniden Tasarım'
        Ozet = 'Yalnızca içerik ve logo taşınır. Düzen tamamen yeni — Stitch + 2 taslak kuralı geçerlidir.'
        Kilitli = 'İçerik metni · logo · marka adı'
        Modern = 'Tüm düzen, tipografi, renk düzeni, bileşenler'
        Serbest = 'Her şey (Stitch AI + en az 2 taslak, müşteri seçer)'
        Emek = 'Orta-yüksek — mevcut tasarım kuralı'
    }
)

# ---------------------------------------------------------------- sorular
$modSecim = $null
$modernSinir = 'gozle'
$kapiOnay = $true

if (-not $Sessiz -and -not $Devam) {
    Baslik "1/3  KAYNAK OZETI"
    Yaz "  Ad       : $kaynakAd"
    Yaz "  Platform : $($tip.platform)"
    Yaz "  Proje    : $Proje"
    Yaz "  Hedef    : $Hedef"
    Yaz "  Cikti    : $projeKok"

    Baslik "2/3  UC YORUM ZORUNLU"
    Yaz "  Her calistirmada asagidaki UC klasor birlikte olusturulur." 'Yellow'
    Yaz "  Amac: musteriye 'begenmedim' yerine 'sunu secelim' demek." 'DarkYellow'
    Yaz ''
    foreach ($m in $MODLAR) {
        Yaz ("   [{0}] {1,-22} {2}" -f $m.No, $m.Etiket, $m.Ad) 'White'
        Yaz ("       {0}" -f $m.Ozet) 'DarkGray'
        Yaz ("       Kilitli : {0}" -f $m.Kilitli) 'DarkGray'
        Yaz ("       Modern  : {0}" -f $m.Modern) 'DarkGray'
        Yaz ''
    }
    if (-not $Mod) {
        $g = Read-Host "  Hangi yorumu ONCE detaylandiralim? [1/2/3, bos = hepsi iskelet]"
        if ($g -match '^[123]$') { $modSecim = [int]$g }
    }
    elseif ($Mod -match '^[123]$') { $modSecim = [int]$Mod }

    Baslik "3/3  CALISMA KURALLARI"
    Yaz "  [2] MODERN icin modernize siniri:"
    Yaz "    [o] Olculu  - bosluk +%15-20, kose 4-6px (onceden tahmin edilebilir)"
    Yaz "    [g] Gozle   - 'daha ferah' hissi, on izleme onayi sart (esnek)"
    if (-not $Sessiz) {
        $g = Read-Host "  Secim [o/g, bos = gozle]"
        if ($g -eq 'o') { $modernSinir = 'olculu' }
    }

    Yaz ''
    Yaz "  %50 KAPISI: tasima yarisinda musteriye gosterilsin mi?"
    Yaz "    (Kapi yoksa: 1 hafta + RET. Kapi varsa: 2 gun + ONAY)"
    if (-not $Sessiz) {
        $g = Read-Host "  Kapi acik olsun mu? [E/h, bos = E]"
        if ($g -match '^[hH]') { $kapiOnay = $false }
    }
}

# ---------------------------------------------------------------- klasorler
Baslik "KLASORLER OLUSTURULUYOR"

$klasorler = @{
    kok      = $projeKok
    envanter = Join-Path $projeKok '_envanter'
    referans = Join-Path $projeKok '_referans'
}
foreach ($m in $MODLAR) { $klasorler["m$($m.No)"] = Join-Path $projeKok $m.Klasor }

foreach ($k in $klasorler.Keys) {
    if (-not (Test-Path $klasorler[$k])) { New-Item -ItemType Directory -Path $klasorler[$k] -Force | Out-Null }
}
Yaz "  $projeKok" 'Green'

# ---------------------------------------------------------------- ETIKET.md
$tarih = Get-Date -Format 'yyyy-MM-dd HH:mm'

function EtiketYaz($m) {
    $sb = New-Object Text.StringBuilder
    [void]$sb.AppendLine("# $($m.Etiket) — $($m.Ad)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("> GÖÇEBE v$SURUM · $tarih · proje: **$Proje** · kaynak: ``$kaynakAd``")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("**Bu klasör ne?** $($m.Ozet)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('| | |')
    [void]$sb.AppendLine('|---|---|')
    [void]$sb.AppendLine("| **Yorum** | $($m.No) / 3 — $($m.Etiket) |")
    [void]$sb.AppendLine("| **Kilitli (korunur)** | $($m.Kilitli) |")
    [void]$sb.AppendLine("| **Modernize (değişir)** | $($m.Modern) |")
    [void]$sb.AppendLine("| **Serbest** | $($m.Serbest) |")
    [void]$sb.AppendLine("| **Emek** | $($m.Emek) |")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## Müşteriye sunum cümlesi')
    [void]$sb.AppendLine('')
    switch ($m.No) {
        1 { [void]$sb.AppendLine('> "Sitenizin **birebir aynısı** — sadece altyapısı yenilendi. Görünümde tek bir değişiklik yok."') }
        2 { [void]$sb.AppendLine('> "Siteniz **tanıdık gelecek**: renkleriniz, logonuz, sıralamanız aynı. Ama boşluklar, yazı ölçüleri ve köşeler **2026 gibi** duruyor."') }
        3 { [void]$sb.AppendLine('> "İçeriğiniz ve logonuz aynı, ama **düzeni baştan tasarladık**. Bu, markanızın bugünkü hâli."') }
    }
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## Durum')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('- [ ] Kaynak envanteri alındı  (`../_envanter/ENVANTER.md`)')
    [void]$sb.AppendLine('- [ ] Referans görüntüler alındı  (`../_referans/`)')
    [void]$sb.AppendLine('- [ ] KONTRAT imzalandı  (`../KONTRAT.md`)')
    [void]$sb.AppendLine('- [ ] Kurulum yapıldı')
    [void]$sb.AppendLine('- [ ] %50 kapısı onaylandı')
    [void]$sb.AppendLine('- [ ] Kıyas yapıldı (yan yana)')
    [void]$sb.AppendLine('- [ ] SEO kontrolü (alt metin · 99 KB · Rank Math)')
    U8 (Join-Path $klasorler["m$($m.No)"] 'ETIKET.md') $sb.ToString()
}
foreach ($m in $MODLAR) { EtiketYaz $m }
Yaz "  3 x ETIKET.md yazildi (ORIJINAL / MODERN / YENI)" 'Green'

# ---------------------------------------------------------------- KONTRAT.md
$kontrat = New-Object Text.StringBuilder
[void]$kontrat.AppendLine("# TAŞIMA KONTRATI — $Proje")
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine("> GÖÇEBE v$SURUM · $tarih")
[void]$kontrat.AppendLine("> Kaynak: ``$kaynakAd`` ($($tip.platform)) · Hedef: ``$Hedef``")
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('**Bu belge ne işe yarar:** "benzemiyor" tartışmasını bitirir. Hangi öğenin korunacağı')
[void]$kontrat.AppendLine('burada yazılıdır. Teslimde bu tabloya bakılır, hatıralara değil.')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('## 1. Üç yorum (zorunlu)')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('| # | Klasör | Etiket | Karar |')
[void]$kontrat.AppendLine('|---|---|---|---|')
foreach ($m in $MODLAR) {
    [void]$kontrat.AppendLine("| $($m.No) | ``$($m.Klasor)/`` | **$($m.Etiket)** — $($m.Ad) | [ ] üretildi · [ ] onaylandı |")
}
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('## 2. Korunacak / değişecek tablosu')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('| Öğe | 1:1 | 2: Benzer+Modern | 3: Yeniden |')
[void]$kontrat.AppendLine('|---|---|---|---|')
$satirlar = @(
    @('Renk paleti (hex)',        'kilitli', 'kilitli',  'serbest'),
    @('Logo / marka',             'kilitli', 'kilitli',  'kilitli'),
    @('Görseller',                'kilitli', 'kilitli',  'serbest'),
    @('Bölüm sırası',             'kilitli', 'kilitli',  'serbest'),
    @('Menü yapısı',              'kilitli', 'kilitli',  'serbest'),
    @('İçerik metni',             'kilitli', 'kilitli',  'kilitli'),
    @('Düzen / grid',             'kilitli', 'kilitli',  'serbest'),
    @('Boşluk ölçeği',            'kilitli', 'modernize', 'serbest'),
    @('Tipografi boyutları',      'kilitli', 'modernize', 'serbest'),
    @('Köşe yuvarlaklığı / gölge','kilitli', 'modernize', 'serbest'),
    @('Animasyon / geçiş',        'yok',     'hafif',     'serbest')
)
foreach ($s in $satirlar) { [void]$kontrat.AppendLine("| $($s[0]) | $($s[1]) | $($s[2]) | $($s[3]) |") }
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('## 3. Çalışma ayarları')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine("- **Önce detaylandırılacak yorum:** $(if ($modSecim) { "$modSecim" } else { 'belirtilmedi (üçü iskelet)' })")
[void]$kontrat.AppendLine("- **Modernize sınırı (mod 2):** $(if ($modernSinir -eq 'olculu') { 'Ölçülü — boşluk +%15-20, köşe 4-6 px' } else { 'Gözle ferah — ön izleme onayı şart' })")
[void]$kontrat.AppendLine("- **%50 kapısı:** $(if ($kapiOnay) { 'AÇIK — yarıda müşteri onayı alınacak' } else { 'KAPALI (risk kabul edildi: ret riski 1 haftaya çıkar)' })")
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('## 4. Değişmez kurallar')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('1. **Taşıma ile yeniden tasarım aynı işte yapılmaz.** Mod 2 seçildiyse "biraz da şunu değiştirelim" kapsam kaymasıdır → yeni iş.')
[void]$kontrat.AppendLine('2. **Görsel ≤ 99 KB** (AVIF/WebP), **alt metni eksiksiz**, **Rank Math ≥ 80**.')
[void]$kontrat.AppendLine('3. **Canlıya dokunmadan yedek**, sonrasında **canlı doğrulama**.')
[void]$kontrat.AppendLine('4. **"Bitti" demek için kıyas ekran görüntüsü şart.**')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('## 5. İmza')
[void]$kontrat.AppendLine('')
[void]$kontrat.AppendLine('| | Ad | Tarih | İmza |')
[void]$kontrat.AppendLine('|---|---|---|---|')
[void]$kontrat.AppendLine('| Müşteri |  |  |  |')
[void]$kontrat.AppendLine('| Taşıyan |  |  |  |')
U8 (Join-Path $projeKok 'KONTRAT.md') $kontrat.ToString()
Yaz "  KONTRAT.md yazildi" 'Green'

# ---------------------------------------------------------------- envanter
Baslik "ENVANTER ALINIYOR"

$env2 = New-Object Text.StringBuilder
[void]$env2.AppendLine("# SİTE ENVANTERİ — $kaynakAd")
[void]$env2.AppendLine('')
[void]$env2.AppendLine("> GÖÇEBE v$SURUM · $tarih")
[void]$env2.AppendLine("> Kaynak: ``$(if($url){$url}else{$yerelYol})``")
[void]$env2.AppendLine('')
[void]$env2.AppendLine('## 1. Platform')
[void]$env2.AppendLine('')
[void]$env2.AppendLine('| | |')
[void]$env2.AppendLine('|---|---|')
[void]$env2.AppendLine("| Tespit | $($tip.platform) |")
[void]$env2.AppendLine("| PHP | $(if($tip.php){'evet'}else{'hayır'}) $(if($tip.phpSurum){"($($tip.phpSurum))"}) |")
[void]$env2.AppendLine("| WordPress | $(if($tip.wp){'evet'}else{'hayır'}) |")
[void]$env2.AppendLine("| Elementor | $(if($tip.elementor){'evet'}else{'hayır'}) |")
[void]$env2.AppendLine("| Gutenberg | $(if($tip.gutenberg){'evet'}else{'hayır'}) |")
[void]$env2.AppendLine('')

$htmlKaynak = $null
if ($kaynakTip -eq 'uzak' -and $html) { $htmlKaynak = $html }
elseif ($kaynakTip -eq 'yerel') {
    foreach ($aday in @('index.html','index.php','index.htm')) {
        $p = Join-Path $yerelYol $aday
        if (Test-Path $p) { $htmlKaynak = Get-Content $p -Raw -ErrorAction SilentlyContinue; break }
    }
    if (-not $htmlKaynak) {
        $ilk = Get-ChildItem $yerelYol -Filter '*.html' -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($ilk) { $htmlKaynak = Get-Content $ilk.FullName -Raw -ErrorAction SilentlyContinue }
    }
}

# -- CSS havuzu: font/renk cogu zaman HTML'de degil, stil dosyalarindadir.
$cssMetin = New-Object Text.StringBuilder
$cssKaynakSayisi = 0
if ($htmlKaynak) {
    foreach ($m in [regex]::Matches($htmlKaynak, '(?is)<style[^>]*>(.*?)</style>')) {
        [void]$cssMetin.AppendLine($m.Groups[1].Value); $cssKaynakSayisi++
    }
}
if ($kaynakTip -eq 'yerel' -and $yerelYol) {
    # aktif tema CSS'i (WP) + varsa assets/css klasoru
    $cssKokler = @()
    if ($tip -and $tip.temaYol) { $cssKokler += $tip.temaYol }
    foreach ($ad in @('css','assets\css','style','assets')) {
        $p = Join-Path $yerelYol $ad
        if (Test-Path $p) { $cssKokler += $p }
    }
    foreach ($kok in $cssKokler) {
        $dosyalar = Get-ChildItem $kok -Recurse -Include '*.css' -File -ErrorAction SilentlyContinue |
                    Sort-Object Length -Descending | Select-Object -First 25
        foreach ($f in $dosyalar) {
            try {
                if ($f.Length -gt 3MB) { continue }
                [void]$cssMetin.AppendLine((Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue))
                $cssKaynakSayisi++
            } catch { }
        }
    }
}
$cssHavuz = $cssMetin.ToString()

if ($htmlKaynak) {
    [void]$env2.AppendLine('## 2. Sayfa başlığı ve meta')
    [void]$env2.AppendLine('')
    $t = [regex]::Match($htmlKaynak, '(?is)<title[^>]*>(.*?)</title>')
    $d = [regex]::Match($htmlKaynak, '(?is)<meta[^>]+name=["'']description["''][^>]+content=["'']([^"'']*)')
    [void]$env2.AppendLine("- **title:** $(if($t.Success){$t.Groups[1].Value.Trim()}else{'(yok)'})")
    [void]$env2.AppendLine("- **description:** $(if($d.Success){$d.Groups[1].Value.Trim()}else{'(yok)'})")
    [void]$env2.AppendLine('')

    [void]$env2.AppendLine('## 3. Tipografi (bulunan font aileleri)')
    [void]$env2.AppendLine('')
    $kaynakMetin = "$htmlKaynak`n$cssHavuz"
    [void]$env2.AppendLine("> Taranan kaynak: HTML + **$cssKaynakSayisi** CSS bloğu/dosyası")
    [void]$env2.AppendLine('')
    $fontlar = [regex]::Matches($kaynakMetin, '(?i)font-family\s*:\s*([^;"''}]+)') |
               ForEach-Object { $_.Groups[1].Value.Trim() } |
               Where-Object { $_ -and $_.Length -lt 80 } |
               Where-Object { $_ -notmatch '(?i)dashicons|woff|inherit|^\s*star\s*$' } |
               Where-Object { $_ -notmatch '(?i)^\s*(sans-serif|serif|monospace)\s*(,\s*monospace)?\s*$' } |
               Select-Object -Unique | Select-Object -First 12
    $gfont = [regex]::Matches($htmlKaynak, 'fonts\.googleapis\.com/css2?\?family=([^&"''>]+)') |
             ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    if ($fontlar) { foreach ($f in $fontlar) { [void]$env2.AppendLine("- ``$f``") } } else { [void]$env2.AppendLine('(bulunamadı — CSS dış dosyada olabilir)') }
    if ($gfont) {
        [void]$env2.AppendLine('')
        [void]$env2.AppendLine('**Google Fonts:**')
        foreach ($f in $gfont) { [void]$env2.AppendLine("- $f") }
    }
    [void]$env2.AppendLine('')

    [void]$env2.AppendLine('## 4. Renk paleti (bulunan hex değerleri)')
    [void]$env2.AppendLine('')
    $renkler = [regex]::Matches($kaynakMetin, '#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b') |
               ForEach-Object { $_.Value.ToLower() } |
               Group-Object | Sort-Object Count -Descending | Select-Object -First 15
    if ($renkler) {
        [void]$env2.AppendLine('| Renk | Kullanım |')
        [void]$env2.AppendLine('|---|---|')
        foreach ($r in $renkler) { [void]$env2.AppendLine("| ``$($r.Name)`` | $($r.Count) kez |") }
    } else { [void]$env2.AppendLine('(bulunamadı — renkler dış CSS/SCSS içinde olabilir)') }
    [void]$env2.AppendLine('')

    [void]$env2.AppendLine('## 5. Görseller')
    [void]$env2.AppendLine('')
    $img = [regex]::Matches($htmlKaynak, '(?is)<img[^>]+src=["'']([^"'']+)["''][^>]*>')
    $altBos = 0; $sayac = 0
    [void]$env2.AppendLine('| # | Kaynak | alt |')
    [void]$env2.AppendLine('|---|---|---|')
    foreach ($m in $img) {
        if ($sayac -ge 40) { break }
        $sayac++
        $src = $m.Groups[1].Value
        $altM = [regex]::Match($m.Value, '(?is)alt=["'']([^"'']*)["'']')
        $alt = if ($altM.Success) { $altM.Groups[1].Value } else { '' }
        if ([string]::IsNullOrWhiteSpace($alt)) { $altBos++ }
        [void]$env2.AppendLine("| $sayac | ``$(Split-Path $src -Leaf)`` | $(if([string]::IsNullOrWhiteSpace($alt)){'**(BOŞ)**'}else{$alt}) |")
    }
    [void]$env2.AppendLine('')
    [void]$env2.AppendLine("**Toplam görsel: $sayac · alt metni boş: $altBos**")
    if ($altBos -gt 0) { [void]$env2.AppendLine(''); [void]$env2.AppendLine('> ⚠ SEO kuralı: alt metni boş görseller taşımada **tamamlanmalı** (≤99 KB + AVIF/WebP).') }
    [void]$env2.AppendLine('')

    # WordPress: HTML dinamik oldugu icin galeri DB'de. Diskten sayiyoruz.
    if ($tip -and $tip.wp -and $kaynakTip -eq 'yerel') {
        $up = Join-Path $yerelYol 'wp-content\uploads'
        if (Test-Path $up) {
            $resimler = Get-ChildItem $up -Recurse -Include '*.jpg','*.jpeg','*.png','*.webp','*.avif','*.gif' -File -ErrorAction SilentlyContinue
            $buyuk = $resimler | Where-Object { $_.Length -gt 99KB }
            $toplamMB = if ($resimler) { [math]::Round((($resimler | Measure-Object Length -Sum).Sum) / 1MB, 1) } else { 0 }
            [void]$env2.AppendLine('### WordPress medya kütüphanesi (diskten)')
            [void]$env2.AppendLine('')
            [void]$env2.AppendLine("| | |")
            [void]$env2.AppendLine('|---|---|')
            [void]$env2.AppendLine("| Görsel dosyası | **$($resimler.Count)** |")
            [void]$env2.AppendLine("| Toplam boyut | $toplamMB MB |")
            [void]$env2.AppendLine("| **99 KB üstü** | **$($buyuk.Count)** ⚠ |")
            [void]$env2.AppendLine('')
            if ($buyuk.Count -gt 0) {
                [void]$env2.AppendLine('> SEO kuralı: bu görseller taşımada **sıkıştırılmalı** (AVIF/WebP, ≤99 KB).')
                [void]$env2.AppendLine('>')
                [void]$env2.AppendLine('> En büyük 10:')
                foreach ($b in ($buyuk | Sort-Object Length -Descending | Select-Object -First 10)) {
                    [void]$env2.AppendLine("> - ``$($b.Name)`` — $([math]::Round($b.Length/1KB)) KB")
                }
            }
            [void]$env2.AppendLine('')
            [void]$env2.AppendLine('> **alt metin** bu tabloda yok: WordPress te alt metni **veritabaninda** (`_wp_attachment_image_alt`).')
            [void]$env2.AppendLine('> Taşımada `doktor-brown-mcp` ile DB den çekilir. GÖÇEBE uydurmaz.')
        }
    }
}
else {
    [void]$env2.AppendLine('## 2-5. HTML okunamadı')
    [void]$env2.AppendLine('')
    [void]$env2.AppendLine('Kaynağın ana HTML dosyası okunamadı. Tarayıcı adımı (`--referans`) gerekli.')
    [void]$env2.AppendLine('')
}

[void]$env2.AppendLine('## 6. Kırılım ve etkileşim (tarayıcı adımı gerekir)')
[void]$env2.AppendLine('')
[void]$env2.AppendLine('| Genişlik | Ne değişiyor |')
[void]$env2.AppendLine('|---|---|')
foreach ($w in @(390, 768, 1024, 1440)) { [void]$env2.AppendLine("| ${w}px | (ölçülecek) |") }
[void]$env2.AppendLine('')
[void]$env2.AppendLine('| Tetik | Sonuç |')
[void]$env2.AppendLine('|---|---|')
foreach ($t2 in @('hover', 'tık', 'scroll', 'zaman')) { [void]$env2.AppendLine("| $t2 | (ölçülecek) |") }
[void]$env2.AppendLine('')
[void]$env2.AppendLine('> **Neden boş:** bu satırlar gerçek tarayıcı ölçümü ister (computed style, state).')
[void]$env2.AppendLine('> GÖÇEBE uydurmaz — "ölçülmedi" yazar. Doldurulmadan KONTRAT imzalanmaz.')

U8 (Join-Path $klasorler.envanter 'ENVANTER.md') $env2.ToString()
Yaz "  _envanter\ENVANTER.md yazildi" 'Green'

# ---------------------------------------------------------------- referans notu
$ref = @"
# REFERANS GÖRÜNTÜLER — $kaynakAd

> GÖÇEBE v$SURUM · $tarih

## Neden bu klasör

Taşımaya **başlamadan önce** eski sitenin görüntüsü alınır. Bu, "eski site neydi" sorusunun
**tek kanıtıdır**. Müşteri "benzemiyor" dediğinde buraya bakılır, hatıralara değil.

## Alınacaklar (zorunlu)

| Genişlik | Dosya adı |
|---|---|
| 390 px (mobil) | ``390-<sayfa>.png`` |
| 768 px (tablet) | ``768-<sayfa>.png`` |
| 1024 px | ``1024-<sayfa>.png`` |
| 1440 px (masaüstü) | ``1440-<sayfa>.png`` |

Her sayfa için ayrı. Ayrıca **tam sayfa** (full-page) görüntüsü.

## Kural

- Görüntüler **kırpılmaz**, **ölçeklenmez** — gerçek boyut.
- Dosya adında **viewport + sayfa** yazar.
- Lazy yüklenen görseller için **aşağı kaydırıp** bekle, sonra al.
- Animasyon/sticky bölümlerde **hem başlangıç hem son hâli** alınır.

## Durum

- [ ] Kaynak URL/klasör: ``$(if($url){$url}else{$yerelYol})``
- [ ] Sayfa listesi çıkarıldı
- [ ] 4 genişlik × her sayfa alındı
- [ ] Yan yana kıyas montajı hazır

> **Not:** tarayıcı otomasyonu bu sürümde **elle** yürütülür (Doc/pClaude).
> v1.1'de otomatikleştirilecek. Bu sürüm uydurmaz — eksikse "eksik" yazar.
"@
U8 (Join-Path $klasorler.referans 'notlar.md') $ref
Yaz "  _referans\notlar.md yazildi" 'Green'

# ---------------------------------------------------------------- ozet
Baslik "BITTI - OZET"
Yaz "  Proje kok : $projeKok" 'White'
Yaz ''
foreach ($m in $MODLAR) {
    $yol = $klasorler["m$($m.No)"]
    $var = Test-Path (Join-Path $yol 'ETIKET.md')
    Yaz ("   {0}  {1,-22} {2}" -f $(if($var){'[x]'}else{'[ ]'}), $m.Klasor, $m.Etiket) $(if($var){'Green'}else{'Red'})
}
Yaz ''
Yaz "  Envanter  : _envanter\ENVANTER.md  $(if((Test-Path (Join-Path $klasorler.envanter 'ENVANTER.md'))){'[x]'}else{'[ ]'})"
Yaz "  Kontrat   : KONTRAT.md            $(if((Test-Path (Join-Path $projeKok 'KONTRAT.md'))){'[x]'}else{'[ ]'})"
Yaz "  Referans  : _referans\notlar.md   $(if((Test-Path (Join-Path $klasorler.referans 'notlar.md'))){'[x]'}else{'[ ]'})"
Yaz ''
Yaz "  AMAC HATIRLATMA: bu arac site KOPYALAMAZ." 'Yellow'
Yaz "  Tasima yapanlara kolaylik saglar. Uc yorum uretir, karari MUSTERI verir." 'DarkYellow'
Yaz ''
Yaz "  Sirada: referans goruntuler -> envanter kirilim/etkilesim -> KONTRAT imzasi -> kurulum" 'DarkCyan'
Yaz "  %50 kapisi: $(if($kapiOnay){'ACIK'}else{'KAPALI'})" 'DarkCyan'

# ---------------------------------------------------------------- devam modu
if ($Devam) {
    Yaz ''
    Yaz "  DEVAM: yarim kalan projeler listeleniyor..." 'Cyan'
    if (Test-Path $Cikti) {
        Get-ChildItem $Cikti -Directory | ForEach-Object {
            $k = Join-Path $_.FullName 'KONTRAT.md'
            $imza = $false
            if (Test-Path $k) { $imza = (Get-Content $k -Raw) -match '\|\s*Müşteri\s*\|\s*\S' }
            Yaz ("   {0,-28} kontrat:{1} imza:{2}" -f $_.Name, $(if(Test-Path $k){'var'}else{'yok'}), $(if($imza){'var'}else{'yok'}))
        }
    } else { Yaz "   (cikti klasoru yok: $Cikti)" }
}

exit 0
