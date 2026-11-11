# Kullanım

## Hızlı

```powershell
# Ajan içinde
/gocebe https://ornek.com
/gocebe C:\xampp\htdocs\eski-site

# Terminal
powershell -File gocebe.ps1 https://ornek.com

# Masaüstü: URL'yi Gocebe.bat üzerine sürükle
```

## Parametreler

| Parametre | Ne |
|---|---|
| `<kaynak>` | `https://site.com` · `C:\xampp\htdocs\site` · `.\klasor` |
| `--proje=<ad>` | Proje klasörü (varsayılan: kaynaktan türetilir) |
| `--hedef=<ad>` | Hedef WordPress site adı |
| `--cikti=<yol>` | Çıktı kökü (varsayılan: `.\gocebe-cikti`) |
| `--mod=<1\|2\|3>` | Öncelikli yorum (üçü de kurulur) |
| `--sessiz` | Soru sormaz |
| `--devam` | Yarım kalan projeleri listeler |
| `--yardim` | Yardım |

## Çıktı yapısı

```
gocebe-cikti/<proje>/
├─ KONTRAT.md                 ← imzalanacak sözleşme
├─ 01-orjinal-kopya/ETIKET.md ← ORİJİNAL (1:1)
├─ 02-benzer-modern/ETIKET.md ← MODERN
├─ 03-yeni-tasarim/ETIKET.md  ← YENİ
├─ _envanter/ENVANTER.md      ← platform · font · renk · görsel · 99 KB
└─ _referans/notlar.md        ← 4 genişlik görüntü talimatı
```

## Akış

1. `gocebe.ps1 <kaynak>` → 3 klasör + kontrat + envanter
2. Referans görüntüleri al (4 genişlik × her sayfa)
3. Envanterdeki **kırılım + etkileşim** tablolarını doldur
4. `KONTRAT.md` müşteriye imzalat
5. Üç yorumu üret (Elementor)
6. **%50 kapısı** — yarıda müşteriye göster
7. Kıyas (yan yana) → SEO kontrolü → teslim

## Notlar

- **PowerShell 5.1 + UTF-8 BOM.** `.ps1` dosyasını düzenlersen BOM'u koru, yoksa Türkçe karakterler parse hatası verir.
- Çıktı **UTF-8 (BOM'suz)** yazılır; Not Defteri/Obsidian doğru okur.
- Tarayıcı adımı (referans görüntü + computed style) bu sürümde **elle** yürütülür. v1.1'de otomatikleştirilecek.
