# Problem Tanımı

## Problem

Geliştirici olarak kullanılan bir Mac zamanla sessizce dolar:

- Denemek için indirilip bir daha açılmayan uygulamalar ve geride bıraktıkları kalıntılar,
- Xcode DerivedData, eski simulator'lar, DeviceSupport dosyaları,
- Terk edilmiş projelerdeki `node_modules`, Rust `target`, Python sanal ortamları,
- Paket yöneticisi ve Docker önbellekleri,
- Downloads'ta biriken, kurulumu çoktan yapılmış DMG/PKG'ler ve unutulmuş büyük dosyalar.

Bunları elle bulmak zahmetli, neyin silinmesinin güvenli olduğunu bilmek zordur. Mevcut araçlar ya genel kullanıcıya odaklıdır, ya ücretli ve ağırdır, ya da yalnızca tek bir işi yapar.

## Hedef kullanıcı

**Birincil:** macOS üzerinde iOS/web/backend geliştiren, diski düzenli dolan ve neyin güvenle silinebileceğini bilmek isteyen geliştirici (ilk kullanıcı: proje sahibi).

**İkincil:** Açık kaynak araçları tercih eden, şeffaflık bekleyen ileri düzey Mac kullanıcıları.

## Başarı ne demek?

- Mac'in "temizlik zamanı" geldiğini kullanıcı değil, Ferah fark eder.
- Kullanıcı her öneride *neden* sorusunun cevabını görür ve güvenle onaylar.
- Hiçbir zaman istenmeyen bir dosya kaybolmaz.
