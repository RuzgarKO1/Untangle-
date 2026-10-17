# Havada top gibi takla — Arianne

Karakter dizlerini göğsüne toplar, kollarıyla bacaklarına kapanır ve sağa doğru öne takla atar. Kızıl saç, şapka, çanta ve mavi bileklik korunur. Aynı air_spin hem yükseliş hem düşüş içindir. İp çizilmedi; kol/bileklik ayrı katmanda, ip katmanı boştur.

| Animasyon | Kare | Hücre | Sheet | FPS | Loop |
|---|---:|---|---|---:|---|
| air_tuck — toplanma | 4 | 64×64 | 4×1 | 16.666667 | Kapalı |
| air_spin — tam takla | 12 | 64×64 | 12×1 | 20 | Açık |
| air_open — açılma | 4 | 64×64 | 4×1 | 16.666667 | Kapalı |

Toplanma ve açılmada her kare 60 ms; toplam 240 ms. Tam dönüşte her kare 50 ms, toplam 600 ms. Sprite sheet boşlukları ve kenar payları 0; kare Duration = 1; Speed Scale = 1.

## Godot 4 aktarımı

Klasörü **Arianne-AirSpin** adıyla proje köküne kopyalayın. AnimatedSprite2D > Sprite Frames alanına Arianne-Air-SpriteFrames.tres bırakıldığında üç animasyon ayarlarıyla gelir. Bu kaynak sadece hava animasyonlarını içerir; mevcut idle/walk/run kaynaklarını doğrudan değiştirirseniz onların yerine geçer. Hepsini tek karakterde kullanmak için mevcut SpriteFrames içinde yukarıdaki üç animasyonu ekleyip PNG sheet’lerinden kareleri alın.

AnimatedSprite2D > Texture > Filter = Nearest, Centered = On, Offset = (0,0), Rotation = 0. Dönüş karelerde çizilidir; ayrıca düğümü döndürmeyin. PNG Import: Compress Mode = Lossless; Mipmaps Generate = Off. GIF dosyaları yalnızca önizlemedir.

## Oyunda ne zaman oynatılır?

Zıplama başladığında air_tuck bir kez, sonra air_spin döngüde oynatılabilir. Son toplanma karesi ile ilk takla karesi aynıdır; aynı pozu ikinci kez bekletmemek için döngüye 1. kareden başlayabilirsiniz (ilk kare 0).

Yükselişten düşüşe geçerken air_spin animasyonunu baştan başlatmayın; mevcut dönüş devam etsin. Kenardan düşüşte doğrudan air_spin kullanılabilir. Sola hareket ederken flip_h ile hem karakter yönü hem dönüş yönü aynalanır. İp bağlıyken sallanma için bu takla yerine ayrı tutunma pozu kullanın.

air_open isteğe bağlıdır: Taklanın dik/toplanmış 0. karesinden çıkarken kullanın. Rastgele dönüş açısından açılmaya geçmek görsel sıçrama oluşturur. Yere inişte animasyonun bitmesini bekleyip fizik hareketini durdurmayın; yere temas anında kendi iniş veya idle/run durumunuza geçin. Bu paket ayrı bir iniş animasyonu içermez.

Gövdeyi döndüren yalnızca görsel olsun; CharacterBody2D ve CollisionShape2D'yi taklayla birlikte döndürmeyin. Mevcut fizik kutusunu koruyabilirsiniz. Toplanırken çarpışma boyutunu da küçültmek oyun mekaniği gerektirir ve bu pakette uygulanmadı.

Godot-Air-Settings.json içindeki rope_anchor konumları 64×64 karenin sol üstüne göredir; Centered açıkken (32,32) çıkarılır. Animasyonlara ait ayrı düzenlenebilir Aseprite belgeleri ve hepsini etiketlerle içeren Arianne-Air-All.aseprite dahildir. Arianne-Air-Preview.aseprite sunum amaçlıdır.

Kontrol: Aseprite’in PNG çıktıları hazırlanan katmanlarla kare kare eşleştirildi; kareler benzersiz, tuval kenarlarında kırpılma yok ve toplanma/takla bağlantısı birebir eşleşiyor. Godot çalışma zamanı testi yapılmadı.
