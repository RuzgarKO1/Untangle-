# Sabit görsel ve koşuya geçiş

**Arianne-Standing.png:** Şeffaf 64×64, mevcut idle animasyonunun ilk karesi. Oyun için bunu kullanın. Arianne-Standing-512.png aynı görselin pikselleri yumuşatılmadan 8 kat büyütülmüş kopyasıdır. Düzenlenebilir sürümü Arianne-Standing.aseprite.

**Arianne-RunStart.png:** 6 sütun × 1 satır; her kare 64×64; aralık ve kenar boşluğu 0. AnimatedSprite2D içinde run_start adında animasyon oluşturun. Speed (FPS) = 16.666667; Loop = Off; her kare Duration = 1. Toplam 360 ms. Aseprite belgesinde her kare 60 ms.

İlk kare mevcut Arianne idle karesiyle, son kare mevcut Arianne run animasyonunun 0. karesiyle birebir aynıdır. Geçiş bitince run animasyonunu 12.5 FPS ile oynatın. Aynı pozu iki kere bekletmemek için run'a 1. kareden başlayın (Godot'ta ilk kare 0 olarak sayılır). `play("run")` ardından `set_frame_and_progress(1, 0.0)` kullanılabilir. run_start oynarken her fizik karesinde idle/run seçerek geçişi bölmeyin; animation_finished gelene kadar bu durumu koruyun.

Tüm görsellerde Texture Filter = Nearest, Speed Scale = 1, Centered = On, Offset = (0,0). PNG Import: Compress Mode = Lossless, Mipmaps Generate = Off.

Bileklik ve kol ayrı katmanda korunur. Godot-RunStart.json içindeki rope_anchor konumları karelerin sol üstüne göre kahverengi bileklik merkezidir. Centered sprite için (32,32) çıkarın.

Arianne-RunStart.gif yalnızca geçişin döngülü önizlemesidir; oyundaki animasyonu döngüye almayın. Arianne-Transition-Preview.gif ise bekleme → geçiş → üç koşu turunu gösterir. Arianne-Transition-Preview.aseprite bu sunumun düzenlenebilir kopyasıdır; oyun için RunStart belgesini kullanın.

Aseprite PNG çıktıları hazırlanan tüm karelerle piksel piksel karşılaştırıldı; iki uç poz ve süreler doğrulandı. Godot çalışma zamanı testi yapılmadı.
