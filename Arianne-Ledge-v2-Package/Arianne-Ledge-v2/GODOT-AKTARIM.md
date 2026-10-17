# Tutunma animasyonları — sürüm 2

Karakterin gövdesi kayaya yaklaştırıldı. Asılmada ağırlık kollarda, dizler rahat ve ayaklar kaya yüzeyine yakın. Çıkış sırası: küçük bir hazırlık → dirsekleri bükerek yukarı çekilme → göğüs/kalçayı kenarın üstüne taşıma → avuçlarla bastırma → bacakları arkadan toplama → doğrulma. İlk adımda ayağını yukarı fırlatma kaldırıldı.

Kareler yine 128×128. Karakterin piksel boyutu, köşe işareti (76,64), ledge sprite Offset=(-12,0) ve son idle hizası değişmedi. Oyunda kullandığın iki betiği değiştirmene gerek yok. Kodun kare sayısını kaynaktan okuduğu için 12 karelik climb süresine uyum sağlar. Koddan FPS ayarı eklenmedi.

LedgeSprite içindeki animasyonların eski karelerini kaldırıp ilgili PNG’den yenilerini ekle:
- ledge_catch: Horizontal=6, Vertical=1; Loop kapalı.
- ledge_hang: Horizontal=4, Vertical=1; Loop açık.
- ledge_climb: **Horizontal=12**, Vertical=1; Loop kapalı. Eski sürüm 8 kareydi, yeni sheet’i 8 parçaya bölme.

Her hücre 128×128; boşluk/kenar payı 0. Texture Filter=Nearest. FPS’leri SpriteFrames panelinden kendin ayarla. Önizlemede catch 60 ms/kare, hang 200 ms/kare, climb 70 ms/kare kullanıldı; oyun için bunları elle değiştirebilirsin. Kare Duration değerlerini 1 bırak.

Arianne-Ledge-Preview.gif ve .aseprite örnek platform içerir. Üretim PNG’leri şeffaftır; platform içermez. Her animasyonun düzenlenebilir katmanlı Aseprite belgesi ve hepsini içeren All belgesi dahildir. Kol/bileklik ayrı, ip katmanı boştur.

Native Aseprite PNG çıktıları kare kare karşılaştırıldı; yakalama/asılma/çıkış uç pozları, son idle pozu ve kırpılma kontrol edildi. Godot sahnesinde çalıştırma testi yapılmadı. Bu değişiklik fizik gövdesinin hareket rotasını değiştirmez; görsel animasyonu yeniler.
