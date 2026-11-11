# GÖÇEBE v1.0.0

> **AMAÇ: SİTE KOPYALAMAK DEĞİL.**
> **AMAÇ: PHP / HTML / WordPress sitelerini modern motora taşıyanlara KOLAYLIK SAĞLAMAK.**
>
> GÖÇEBE bir kopyalama aracı değildir. Bir **taşıma tezgâhı**dır:
> eski siteyi **ölçer**, **üç ayrı yorum** üretir (birebir · benzer+modern · yeniden),
> ve kararı **müşteriye** bırakır. Hangi yorumun beğenileceğini araç değil, **site sahibi** bilir.
>
> **Yasal sınır (araç içinde yazılı):** yalnızca **hakkına sahip olunan** siteler taşınır.
> Başkasının tasarımını kendi eseri gibi sunmak bu aracın amacı **dışındadır** ve desteklenmez.

---

## Neden var

Gerçek bir ders:

> PHP 5.4 ile yazılmış bir site WordPress'e taşındı. **1 hafta** sürdü.
> Müşteri **memnun olmadı**: *"Eskisine benzer yönler muhafaza edilmeliydi."*
>
> Sorun yetenek değildi. **Sorun:** hiçbir yerde "neyin korunacağı" **yazılı değildi**
> ve müşteri sonucu **ancak 1 hafta sonra** gördü.

GÖÇEBE bu iki hatayı kapatır:

1. **Yazılı kontrat** — hangi öğe kilitli, hangisi modernize (imzalanır)
2. **%50 kapısı** — taşımanın yarısında müşteri görür
3. **Üç yorum birden** — "beğenmedim" yerine "şunu seçelim"

---

## Ne üretir

Her çalıştırmada **zorunlu üç çıktı**:

| # | Klasör | Etiket | Ne korunur |
|---|---|---|---|
| 1 | `01-orjinal-kopya/` | **ORİJİNAL** | Her şey: düzen, ölçü, boşluk, tipografi. Sadece motor değişir |
| 2 | `02-benzer-modern/` | **MODERN** | Renk, logo, görsel, bölüm sırası, marka hissi |
| 3 | `03-yeni-tasarim/` | **YENİ** | Sadece içerik + logo |

Her klasörün içinde `ETIKET.md` vardır — **hangi yorum olduğu yazılıdır**.
Müşteriye sunumda alt alta: *"1. Orijinalinize birebir · 2. Modern dokunuş · 3. Yeni tasarım"*.

Ayrıca:
- `_envanter/ENVANTER.md` — font, renk, kırılım, varlık, etkileşim
- `_referans/` — 4 genişlikte ekran görüntüsü (eski sitenin kanıtı)
- `KONTRAT.md` — imzalanacak tablo

---

## Nasıl çalışır

```bash
# Ajan içinde
/gocebe https://ornek.com
/gocebe C:\xampp\htdocs\eski-site
/gocebe --devam              # %50 kapısından devam

# Terminal
gocebe.ps1 https://ornek.com

# Masaüstü: URL'yi Gocebe.bat üzerine sürükle
```

**Desteklenen kaynaklar:** PHP (5.x–8.x) · düz HTML · WordPress (Elementor/Gutenberg/klasik) · statik klasör

---

## Dürüst sınırlar

| Yapılır | Yapılmaz |
|---|---|
| Envanter çıkarma (font/renk/kırılım/varlık) | "Tek komutla mükemmel Elementor" |
| 4 genişlikte referans görüntü | Piksel mükemmel otomatik taşıma |
| Üç klasör + etiket + kontrat iskeleti | Müşteri onayı yerine geçmek |
| 99 KB / alt metin / Rank Math kontrolü | Tasarım kararı vermek (o Stitch + müşteri) |

**Otomatik kurulum ~%80'dir.** Kalan %20 elden yapılır — ve `KONTRAT.md` bunu gizlemez.

---

## Lisans

MIT · taşıma yapan ajanslar ve geliştiriciler için.
