import UIKit
import AVFoundation
import MediaPlayer

final class ViewController: UIViewController, AVAudioPlayerDelegate, AVPlayerItemMetadataOutputPushDelegate {
    
    var navigationBar = UINavigationBar()
    var play = true
    var changeThemeValue = true
    var shuffle = false
    let pickerTimer = UIDatePicker()
    let sleepTimerLabel = UILabel()
    let metaDataLabel = UILabel()
    var timer = Timer()
    var timerTextLabel = Timer()
    var valueTimer = Double()
    var backgroundView = UIImageView()
    var imageOutlet = UIImageView()
    var backButtonOutlet = UIButton()
    var nextButtonOutlet = UIButton()
    var playOutlet = UIButton()
    var sleepTimerButton = UIButton()
    var themeButton = UIButton()
    var volumeMin = UIImageView()
    var volumeMax = UIImageView()
    var titleImage = UIImage()
    var titleTextLabel = UILabel()
    var favoriteButton = UIButton()
    var shuffleButton = UIButton()
    var shuffleColor = textColor
    weak var myDelegate: AVPlayerItemMetadataOutputPushDelegate?
    var metadataOutput = AVPlayerItemMetadataOutput()
    var updateTextLabelCount = 1
    
    //отвечает за номер радиостанции
    var i = 0 {
        didSet {
            if shuffle {
                var temp = i
                while temp == i {
                    temp = Int.random(in: 0..<databaseRadio.count)
                }
                i = temp
            } else {
                switch i {
                case databaseRadio.count: i = 0
                case -1: i = databaseRadio.count - 1
                default: break
                }
            }
        }
    }
    
    var urlRadio: URL?
    var inetPlayer = AVPlayer()
    var inetPlayerItem: AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        view.addSubview(backgroundView)
        
        //MARK: - загружаем данные: последнюю включенную станцию и цветовую тему
        loadStation()
        loadDataFunc()
        if let temp = saveData[0] as? Int {
            i = temp
        }
        if let temp = saveData[1] as? Bool {
            changeThemeValue = temp
        }
        
        //Делаем навигатор бар прозрачным
        navigationBar = (navigationController?.navigationBar)!
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        //MARK: - подключаем свайпы к imageView
        imageOutlet.isUserInteractionEnabled = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
        swipeLeft.direction = .left
        imageOutlet.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
        swipeRight.direction = .right
        imageOutlet.addGestureRecognizer(swipeRight)
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextViewFunc))
        imageOutlet.addGestureRecognizer(tap)
        
        
        changeStation(i)
        setupRemoteTransportControls()
        changeTheme(changeThemeValue)
        
        //MARK: - располагаем элементы на вью контроллере
        let size = view.bounds.width - 120
        imageOutlet.frame = CGRect(x: (view.bounds.width - size) / 2, y: 140, width: size, height: size)
        imageOutlet.layer.cornerRadius = size / 2
        imageOutlet.contentMode = .scaleAspectFit
        imageOutlet.backgroundColor = UIColor(red: 13.0/255.0, green: 30.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        imageOutlet.clipsToBounds = true
        imageOutlet.layer.borderWidth = 2
        imageOutlet.layer.borderColor = UIColor.white.cgColor
        view.addSubview(imageOutlet)
        
        backButtonOutlet.frame = CGRect(x: 70, y: 496, width: 40, height: 44)
        backButtonOutlet.setImage(UIImage(named: "back.png"), for: .highlighted)
        backButtonOutlet.addTarget(self, action: #selector(backwardButton), for: .touchUpInside)
        view.addSubview(backButtonOutlet)
        
        nextButtonOutlet.frame = CGRect(x: self.view.bounds.width - 109, y: 496, width: 40, height: 44)
        nextButtonOutlet.setImage(UIImage(named: "for.png"), for: .highlighted)
        nextButtonOutlet.addTarget(self, action: #selector(forwardButton), for: .touchUpInside)
        view.addSubview(nextButtonOutlet)
        
        playOutlet.frame = CGRect(x: self.view.bounds.width / 2 - 20, y: 496, width: 40, height: 44)
        playOutlet.setImage(UIImage(named: "pause1.png"), for: .highlighted)
        playOutlet.addTarget(self, action: #selector(playButton), for: .touchUpInside)
        view.addSubview(playOutlet)
        
        sleepTimerLabel.frame = CGRect(x: self.view.bounds.width / 2 - 130, y: 35, width: 260, height: 25)
        sleepTimerLabel.textAlignment = .center
        sleepTimerLabel.textColor = .systemRed
        view.addSubview(sleepTimerLabel)
        
        metaDataLabel.frame = CGRect(x: self.view.bounds.width / 2 - 100, y: 400, width: 200, height: 60)
        metaDataLabel.numberOfLines = 2
        metaDataLabel.textAlignment = .center
        metaDataLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(metaDataLabel)
        
        volumeMin.frame = CGRect(x: 40, y: 588, width: 22, height: 22)
        volumeMin.image = UIImage(systemName: "speaker.1.fill")
        volumeMin.tintColor = UIColor.darkGray
        view.addSubview(volumeMin)
        
        volumeMax.frame = CGRect(x: self.view.bounds.width - 73, y: 586, width: 32, height: 24)
        volumeMax.image = UIImage(systemName: "speaker.3.fill")
        volumeMax.tintColor = UIColor.darkGray
        view.addSubview(volumeMax)
        
        titleTextLabel.frame = CGRect(x: self.view.bounds.width / 2 - 115, y: 70, width: 230, height: 40)
        titleTextLabel.textAlignment = .center
        titleTextLabel.adjustsFontSizeToFitWidth = true
        titleTextLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleTextLabel.textColor = textColor
        view.addSubview(titleTextLabel)
        
        //Кнопки навигатор контроллера
        themeButton.frame = CGRect(x: 0, y: 0, width: 27, height: 26)
        themeButton.setImage(themeImage, for: .normal)
        themeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        themeButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        themeButton.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: themeButton)
        
        sleepTimerButton.frame = CGRect(x: 0, y: 0, width: 27, height: 26)
        sleepTimerButton.setImage(UIImage(systemName: "timer"), for: .normal)
        sleepTimerButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        sleepTimerButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        sleepTimerButton.addTarget(self, action: #selector(timerButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sleepTimerButton)
        
        favoriteButton.frame = CGRect(x: 295, y: 365, width: 40, height: 40)
        favoriteButton.backgroundColor = .systemRed
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.clipsToBounds = true
        favoriteButton.addTarget(self, action: #selector(favoriteFunc), for: .touchUpInside)
        view.addSubview(favoriteButton)
        
        shuffleButton.frame = CGRect(x: 45, y: 375, width: 37, height: 25)
        shuffleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        shuffleButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        shuffleButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        shuffleButton.tintColor = textColor
        //пример создания тени к Image, еще код в методе shuffleFunc
        shuffleButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        shuffleButton.layer.shadowColor = UIColor.white.cgColor
        shuffleButton.addTarget(self, action: #selector(shuffleFunc), for: .touchUpInside)
        view.addSubview(shuffleButton)
        
        changeVolume()
        
        //подключаем фоновое воспроизведение
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }
    
    //MARK: - кнопка смена темы
    @objc func changeTheme (_ sender: Any) {
        if self.inetPlayer.rate == 0.0 {
            playOutlet.setImage(UIImage(named: "play1.png")!, for: .highlighted)
        } else {
            playOutlet.setImage(UIImage(named: "pause1.png")!, for: .highlighted)
        }
            
        darkThemeFunc(changeThemeValue)
        saveData[1] = changeThemeValue
        saveDataFunc()
        
        backgroundView.image = backgroundImage
        metaDataLabel.textColor = textColor
        titleTextLabel.textColor = textColor
        backButtonOutlet.setImage(imageBack, for: .normal)
        nextButtonOutlet.setImage(imageNext, for: .normal)
        themeButton.setImage(themeImage, for: .normal)
        
        if shuffle {
            shuffleButton.tintColor = .systemRed
        } else {
            shuffleButton.tintColor = textColor
        }
        
        if play {
            playOutlet.setImage(imagePause, for: .normal)
        } else {
            playOutlet.setImage(imagePlay, for: .normal)
        }
        
        //меняем цвет Title навигатор бара
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        
        changeThemeValue = !changeThemeValue
    }

    //MARK: - настройка слайдера громкости
    private func changeVolume() {
        let volumeSlider = UIView(frame: CGRect(x: 70, y: 589, width: 230, height: 25))
        volumeSlider.tintColor = .systemRed
        self.view.addSubview(volumeSlider)
        let volumeView = MPVolumeView(frame: volumeSlider.bounds)
        volumeView.showsRouteButton = false
        volumeSlider.addSubview(volumeView)
    }
    
    //MARK: - функция смены станций и старта плеера
    private func changeStation (_ value: Int) {
        var valueTemp = 0
        if value > databaseRadio.count {
            valueTemp = 0
            i = 0
        } else {
            valueTemp = value
        }
        
        //запоминание последней включенной станции
        saveData[0] = valueTemp
        saveDataFunc()
        titleTextLabel.text = databaseRadio[valueTemp].2
        
        urlRadio = URL(string: String(databaseRadio[valueTemp].0))
        inetPlayerItem = AVPlayerItem(asset: AVAsset(url: urlRadio ?? URL(string: "http://www.ru")!))
        
        metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        inetPlayerItem.add(metadataOutput)
        inetPlayer = AVPlayer(playerItem: inetPlayerItem)
        
        if play {
            if let temp = UIImage(named: databaseRadio[valueTemp].1) {
                titleImage = temp
            } else {
                titleImage = UIImage(named: "default")!
            }
            startAnimation()
            inetPlayer.play()
            
            //обновляем метаданные для команд-центра
            updateTextLabelCount = 1
            timerTextLabel = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(updateTextLabel), userInfo: nil, repeats: true)
            
        } else {
            inetPlayer.pause()
            metaDataLabel.text = ""
            stopAnimation()
        }
    }
    
    
    //MARK: - проверка началось ли воспроизведение и замена надписи "Загружаю..."
    @objc func updateTextLabel () {
        if inetPlayer.reasonForWaitingToPlay?.rawValue != nil {
            metaDataLabel.text = "Загружаю..."
        } else {
            if UIImage(named: databaseRadio[i].1) == nil {
                imageOutlet.startAnimating()
            } else {
                imageOutlet.image = UIImage(named: databaseRadio[i].1)
            }
        }
        updateTextLabelCount += 1
        if updateTextLabelCount == 5 {
            timerTextLabel.invalidate()
        }
        //показываем что играем в команд-центре
        setupNowPlaying(title: titleTextLabel.text!, setImage: titleImage, artist: metaDataLabel.text)
    }
    
    
    //MARK: - Вывод метаданных в команд центре
    
    // Функция вывода метадаты
    internal func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let item = groups.first?.items.first
        if let temp = item?.value(forKeyPath: "value") as? String {
            metaDataLabel.text = temp
        } else {
            metaDataLabel.text = ""
        }
    }

    
    //настройка метаданных
    private func setupNowPlaying(title: String, setImage: UIImage?, artist: String?){
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if let text = artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = text
        }
        if let image = setImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - Установка таймера сна
    @objc func timerButton(_ sender: Any) {
        pickerTimer.datePickerMode = .countDownTimer
        pickerTimer.frame = CGRect(x: 50, y: 40, width: 200, height: 150)
        
        let alertController = UIAlertController(title: "Тамер сна\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Готово", style: .default) { (action) in
            self.timer.invalidate()
            self.valueTimer = self.pickerTimer.countDownDuration
            self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .default) { (action) in
            self.timer.invalidate()
            self.sleepTimerLabel.text = ""
        }
        
        alertController.view.addSubview(self.pickerTimer)
        alertController.addAction(cancel)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func updateTimer () {
    
        let hour = Int(valueTimer / 3600)
        let min = Int(valueTimer / 60) - hour * 60
        let sec = Int(valueTimer) - hour * 3600 - min * 60
        var hourStr = String(hour)
        var minStr = String(min)
        var secSrt = String(sec)
        
        if hour < 10 {
            hourStr = "0" + String(hour)
        }
        if min < 10 {
            minStr = "0" + String(min)
        }
        if sec < 10 {
            secSrt = "0" + String(sec)
        }
        
        sleepTimerLabel.text = "Таймер сна: " + hourStr + "ч " + minStr + "м " + secSrt + "c"
        valueTimer -= 1

        if valueTimer == 0 {
            timer.invalidate()
            sleepTimerLabel.text = ""
            if self.inetPlayer.rate == 1.0 {
                playButton((Any).self)
            }
        }
    }
    
    //MARK: - Кнопки управления в приложении
    @objc func playButton (_ sender: Any) {
        if play {
            playOutlet.setImage(UIImage(named: "play1.png")!, for: .highlighted)
            playOutlet.setImage(imagePlay, for: .normal)
            play = !play
            changeStation(i)
        } else {
            playOutlet.setImage(UIImage(named: "pause1.png")!, for: .highlighted)
            playOutlet.setImage(imagePause, for: .normal)
            play = !play
            changeStation(i)
        }
    }
    
    @objc func forwardButton (_ sender: Any) {
        i += 1
        changeStation(i)
    }
    
    @objc func backwardButton (_ sender: Any) {
        i -= 1
        changeStation(i)
    }
    
    //MARK: - Настройка кнопок управления в команд центре
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.inetPlayer.rate == 0.0 {
                self.playButton((Any).self)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.inetPlayer.rate == 1.0 {
                self.playButton((Any).self)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.i += 1
            self.changeStation(self.i)
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.i -= 1
            self.changeStation(self.i)
            return .success
        }
    }
    
    //переключение станций свайпом
    @objc func getSwipeAction (gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            backwardButton((Any).self)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            forwardButton((Any).self)
        }
    }
    
    private func startAnimation () {
        imageOutlet.animationImages = Data.imageArray
        imageOutlet.animationDuration = 1.0
        imageOutlet.animationRepeatCount = 0
        if UIImage(named: databaseRadio[i].1) == nil {
            imageOutlet.image = UIImage(named: "01a")!
        } else {
            imageOutlet.image = UIImage(named: databaseRadio[i].1)
        }
    }
    private func stopAnimation() {
        imageOutlet.stopAnimating()
        imageOutlet.animationImages = nil
        if UIImage(named: databaseRadio[i].1) == nil {
            imageOutlet.image = UIImage(named: "01a")!
        } else {
            imageOutlet.image = UIImage(named: databaseRadio[i].1)
        }
    }
    
    //перенести станцию в начало списка
    @objc func favoriteFunc () {
        databaseRadio.insert(databaseRadio[i], at: 0)
        databaseRadio.remove(at: i+1)
        saveStation()
        let alertController = UIAlertController(title: "", message: " Станция перенесена в начало списка", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        i = 0
    }
    
    //включаем/отключаем shuffle
    @objc func shuffleFunc () {
        shuffle = !shuffle
        if shuffle {
            shuffleColor = .systemRed
            shuffleButton.layer.shadowOpacity = 1.0
            shuffleButton.layer.shadowRadius = 10
        } else {
            shuffleColor = textColor
            shuffleButton.layer.shadowOpacity = 0
            shuffleButton.layer.shadowRadius = 0
        }
        shuffleButton.tintColor = shuffleColor
    }

    //переход на следующий view
    @objc func nextViewFunc (_ sender: Any) {
        let view2 = ViewController2()
        view2.changeThemeValue = changeThemeValue
        self.navigationController?.pushViewController(view2, animated: true)
    }
}
