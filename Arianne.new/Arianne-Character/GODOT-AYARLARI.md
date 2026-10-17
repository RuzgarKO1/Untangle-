# Arianne — Godot 4 aktarım rehberi

Açılış sahnesindeki kıvrık şapka, kızıl saç, deri sırt çantası ve kısa mor tunik temel alındı. Koşu kollar arkada pozunu korur. Orijinal dosyalar değiştirilmedi. Klasörde ayrı bir yürüme dosyası bulunmadığından walk yeni çizildi. Aseprite’in betik sistemiyle katmanlı belgeler oluşturuldu ve PNG/GIF dosyaları Aseprite ile dışa aktarıldı.

| Animasyon | Kare | Kare süresi | Godot Speed (FPS) | Sheet sütun × satır | Loop |
|---|---:|---:|---:|---|---|
| idle | 4 | 250 ms | 4 | 4 × 1 | Açık |
| walk | 8 | 100 ms | 10 | 8 × 1 | Açık |
| run | 8 | 80 ms | 12.5 | 8 × 1 | Açık |

## Hazır kurulum

1. ZIP içindeki **Arianne-Character** klasörünü Godot projenizin köküne kopyalayın. Böylece res://Arianne-Character/ yolu oluşmalı; klasörün adını değiştirmeyin.
2. Mevcut AnimatedSprite2D düğümünde Sprite Frames alanına Arianne-SpriteFrames.tres dosyasını bırakın. Üç animasyon ve FPS değerleri hazırdır. İsterseniz Arianne-Visual.tscn dosyasını karakter sahnenize alt sahne olarak ekleyin; bu yalnızca görseldir, hareket/fizik kodu içermez.
3. AnimatedSprite2D > Texture > Filter değerini **Nearest** yapın. Hazır görsel sahnede ayarlıdır. Speed Scale = 1, Centered = On, Offset = (0,0), Rotation = 0 kullanın.
4. PNG dosyalarının Import panelinde Compress > Mode = **Lossless**, Mipmaps > Generate = **Off**; Reimport. Şeffaf arka planı koruyun. GIF dosyaları yalnızca önizleme içindir.
5. Gerçek oyun boyutunda Scale = (1,1) ile başlayın. Büyütmeniz gerekirse (2,2) veya (3,3) gibi tam sayı ölçek kullanın. Hareket hızı ile animasyon FPS’si ayrı ayarlardır; FPS fizik hızını belirlemez.

## Elle kurulum

AnimatedSprite2D > Sprite Frames > New SpriteFrames. idle, walk ve run isimlerini oluşturun. Her birinde Add frames from a Sprite Sheet ile ilgili PNG’yi seçin. idle için Horizontal=4 Vertical=1; walk ve run için Horizontal=8 Vertical=1. Tüm kareleri soldan sağa seçin. Her kare **64×64**; kenar boşluğu ve aralık **0**. Yukarıdaki FPS değerlerini girin, Loop açık, tüm karelerde Duration=1.0 olsun. Texture Filter, PNG Import panelinde değil AnimatedSprite2D/CanvasItem tarafında ayarlanır.

## İp ve katmanlar

Her belgede bacaklar, uzak kol, gövde, çanta, saç/şapka, yakın kol/bileklik ve boş ip katmanı ayrıdır. Arianne-All.aseprite üç animasyonu idle/walk/run etiketleriyle tek belgede içerir; diğer .aseprite dosyaları animasyon başına ayrıdır.

**animation-settings.json** içindeki rope_anchor listesi kare başına kahverengi bilekliğin merkezini verir. Nokta elin ucunda değildir. PNG’nin sol üstü (0,0); Centered açık ve Offset sıfırken Marker2D konumu için bu noktadan (32,32) çıkarın. Sola bakarken flip_h kullanıyorsanız yerel X işaretini de ters çevirin. AnimatedSprite2D'nin yerel dönüşümünden global konuma dönüştürerek ipin ucunu takip ettirin. Yeni tasarım eski bileklik koordinatlarını kullanmaz.

PNG sheet kolu içerir; V ile tutunma sırasında kolu ayrı oynatmak için Aseprite’te Near arm and bracelet katmanını ayrıca dışa aktarın ve gövde sheet’inde gizleyin. Bu paket idle/walk/run görsellerini hazırlar; tutunma pozu ve ip fiziği içermez.

## Doğrulama

Aseprite’in dışa aktardığı her kare çizilen katmanların birleşimiyle piksel piksel karşılaştırıldı; 64×64 hücreler, kare sayıları, süreler, şeffaflık ve tekrarsız pozlar kontrol edildi. Godot kaynakları hazırlandı; bu bilgisayarda Godot çalıştırılarak sahne testi yapılmadı.

Resmî belgeler:
- https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html
- https://docs.godotengine.org/en/stable/classes/class_canvasitem.html
