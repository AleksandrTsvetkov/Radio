import UIKit


class Data: UIViewController {
    
    static let radio1 = ("http://nashe1.hostingradio.ru/nashepunks.mp3",
                         imageBase[0], "Панки Хой")
    static let radio2 = ("https://nashe1.hostingradio.ru:18000/nashe20-128.mp3",
                         imageBase[1], "Наше 2.0")
    static let radio3 = ("http://nashe1.hostingradio.ru/nasheclassic.mp3",
                         imageBase[2], "Классик рок")
    static let radio4 = ("http://nashe1.hostingradio.ru/nashe-128.mp3",
                         imageBase[2], "Наше радио")
    static let radio5 = ("http://nashe1.hostingradio.ru/nashesongs.mp3",
                         imageBase[2], "Щас спою")
    static let radio6 = ("https://nashe1.hostingradio.ru:18000/ultra-128.mp3",
                         imageBase[3], "Радио ULTRA")
    static let radio7 = ("http://nashe1.hostingradio.ru/best-128.mp3",
                         imageBase[4], "Радио BEST")
    static let radio8 = ("http://nashe1.hostingradio.ru/jazz-128.mp3",
                         imageBase[5], "Радио JAZZ")
    static let radio9 = ("http://nashe1.hostingradio.ru/rock-128.mp3",
                         imageBase[6], "ROCK FM")
    static let radio10 = ("http://rusradio.hostingradio.ru/maximum128.mp3",
                          imageBase[7], "Maximum")
    static let radio11 = ("http://retroserver.streamr.ru:8043/retro128.m3u",
                          imageBase[8], "Ретро FM")
    static let radio12 = ("http://listen10.vdfm.ru:8000/dacha",
                          imageBase[9], "Радио Дача")
    static let radio13 = ("http://ic6.101.ru:8000/a102.m3u",
                          imageBase[10], "Юмор FM")
    static let radio14 = ("http://dorognoe.hostingradio.ru:8000/radio.m3u",
                          imageBase[11], "Дорожное радио")
    static let radio15 = ("http://ic7.101.ru:8000/a202.m3u",
                          imageBase[12], "Comedy Radio")
    static let radio16 = ("http://radiomv.hostingradio.ru/radiomv128.mp3.m3u",
                          imageBase[13], "Милицейская волна")
    static let radio17 = ("http://icecast.vgtrk.cdnvideo.ru/vestifm_mp3_192kbps",
                          imageBase[14], "Вести FM")
    
    
    
    
    static let baseRadio = [radio1, radio2, radio3, radio4, radio5, radio6, radio7,                     radio8, radio9, radio10, radio11, radio12, radio13,                          radio14, radio15, radio16, radio17]
    static let imageBase = ["1","2","3","4","5","6","7","8","9","10","11","12","13",                    "14","15"]
    
    static let size = CGSize(width: 500, height: 500)
    
    static let imageArray = [UIImage(named:"00a")!.crop(size), UIImage(named:"01a")!.crop(size), UIImage(named:"02a")!.crop(size), UIImage(named:"03a")!.crop(size), UIImage(named:"04a")!.crop(size), UIImage(named:"05a")!.crop(size), UIImage(named:"06a")!.crop(size), UIImage(named:"07a")!.crop(size), UIImage(named:"08a")!.crop(size), UIImage(named:"09a")!.crop(size), UIImage(named:"10a")!.crop(size), UIImage(named:"11a")!.crop(size), UIImage(named:"12a")!.crop(size), UIImage(named:"13a")!.crop(size), UIImage(named:"14a")!.crop(size), UIImage(named:"15a")!.crop(size), UIImage(named:"16a")!.crop(size), UIImage(named:"17a")!.crop(size), UIImage(named:"18a")!.crop(size), UIImage(named:"19a")!.crop(size)]

    
}
