import Paparazzo
import ImageSource

final class ItemProvider {
    
    func remoteItems() -> [MediaPickerItem] {
        let urlStrings = [
            "http://www.catgallery.ru/kototeka/wp-content/uploads/2015/04/Foto-podborka-kosoglazyih-kotikov-3.jpg",
            "https://i.ytimg.com/vi/IRSsqnJPBrs/maxresdefault.jpg",
            "http://fonday.ru/images/tmp/16/7/original/16710fBjLzqnJlMXhoFHAG.jpg",
            "http://www.velvet.by/files/userfiles/19083/ekrk.jpg",
            "http://www.gorn.lv/wp-content/uploads/2016/09/27_Gorn_viesistabas_skapis-gramatas-details-900x1200.jpg"
        ]
        
        return urlStrings
            .compactMap(URL.init)
            .map { url in
                MediaPickerItem(
                    image: RemoteImageSource(url: url),
                    source: .camera
                )
            }
    }
    
}
