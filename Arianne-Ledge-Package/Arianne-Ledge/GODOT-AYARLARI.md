# Takladan köşeye tutunma ve platforma çıkma

| Animasyon | Kare | FPS | Loop | Sheet |
|---|---:|---:|---|---|
| ledge_catch | 6 | 16.666667 | Kapalı | 6×1 |
| ledge_hang | 4 | 5 | Açık | 4×1 |
| ledge_climb | 8 | 12.5 | Kapalı | 8×1 |

Üç üretim sheet’i şeffaftır; **her hücre 128×128**. Karakter mevcut animasyonlarla aynı piksel boyutundadır; tuval hareket alanını kapsamak için genişletildi. Boşluk ve kenar payı 0. Speed Scale=1; kare Duration=1. Texture Filter=Nearest; PNG Import Lossless, mipmaps kapalı. Platform yalnızca Arianne-Ledge-Preview dosyalarında görünür; oyun assetlerine çizilmedi.

## Oynatma sırası

air_spin → ledge_catch → ledge_hang → ledge_climb → idle/run.

Yakalamayı bir kez oynatıp bitince asılma döngüsünde kalın. Oyuncu yukarı çıkma komutu verdiğinde ledge_climb bir kez oynasın. Yakalamanın son karesi, asılmanın ilk karesi ve çıkışın ilk karesi birebir aynı poza bağlanır.

## Takladan geçiş

Yakalamanın ilk karesi önceki air_spin animasyonunun **0. karesinin** aynı pikselleridir; 128×128 tuvale (28,47) ofsetiyle yerleştirilmiştir. Bu giriş dik/toplanmış faz için hazırlandı; her takla açısından aynı derecede kesintisiz geçiş sağlamaz. Kenarı algıladığınızda fiziksel tutunmayı geciktirmeyin; görseli bu giriş pozuna alın veya dönüş fazına özel ek geçişler kullanın. Önizleme tam dönüşten sonra bu faza girer.

## Kenara hizalama

Sağa bakan animasyonlarda platformun üst-sol köşesi tuvalde **(76,64)** noktasıdır. Her Aseprite belgesinde ledge_anchor adlı slice bu noktayı işaretler. Bir Node2D'yi gerçek dünya köşesine yerleştirip altında sadece bu animasyonları gösteren AnimatedSprite2D kullanabilirsiniz. Centered=On, Position=(0,0), Offset=(-12,0) iken işaretlenen köşe Node2D'nin merkezine oturur. Başlangıçta normal karakter görselini gizleyip bu görseli açın.

Mevcut 64×64 air_spin görselinin merkezi, bu sağa bakan girişte kenara göre (-16,15) konumundadır. Çıkış tamamlandığında mevcut 64×64 idle görselinin merkezi kenara göre **(14,-29)** konumuna oturur; görseli bu noktaya hizalayarak normal animasyonlara dönebilirsiniz. Bu değerler sıfır Offset ve Centered açık normal sprite içindir; karakter kökünü farklı konumlandırdıysanız uyarlayın. Son çıkış karesi, mevcut idle karesinin (58,3) ofsetiyle yerleştirilmiş birebir kopyasıdır.

Sola tutunmada görseli ve hizalama değerlerinin X bileşenlerini birlikte aynalayın. Yalnızca flip_h açıp aynı Offset'i bırakmak kenarı kaydırır: solda Offset=(12,0), giriş merkezi=(16,15), bitiş merkezi=(-14,-29).

Bu animasyonlarda gövdenin köşeye göre hareketi karelerin içine çizilidir. Ayrı görsel düğümü köşede sabit tutun; ayrıca aynı yolu görsele tween uygulayarak ikinci kez hareket ettirmeyin. Oyun karakterinin fiziksel hareketi, yer/baş boşluğu kontrolü ve çarpışma çözümü ayrı yapılmalıdır. Buradaki merkez koordinatları çarpışma açısından doğrulanmış bir hareket rotası değildir.

## Dosyalar ve kontrol

Animasyon başına katmanlı Aseprite, PNG sheet ve GIF bulunur. Arianne-Ledge-All.aseprite üç bölümü etiketlerle tek belgede içerir. Preview belgesi/sunumu platformla birlikte tüm hareketi gösterir; oyun için ayrı sheet’leri kullanın. Kol/bileklik, çanta, saç/şapka ve bacaklar ayrı katmanlarda; ip katmanı boştur.

Aseprite'in dışa aktardığı kareler hazırlanan katmanlarla piksel piksel karşılaştırıldı. Yakalama/asılma/çıkış bağlantı pozları doğrulandı. Godot entegrasyonu ve köşe algılama kodu bu pakete dahil değildir; çalışma zamanı testi yapılmadı.
