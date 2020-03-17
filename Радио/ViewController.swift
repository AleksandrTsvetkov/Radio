import UIKit
import AVFoundation
import MediaPlayer
import Network

//проверка наличия интернета
final class NetworkReachability {
    var pathMonitor: NWPathMonitor!
    var path: NWPath?
    lazy var pathUpdateHandler: ((NWPath) -> Void) = { path in
        self.path = path
        if path.status == NWPath.Status.satisfied {
            internetValue = true
        } else if path.status == NWPath.Status.unsatisfied {
            internetValue = false
        } else if path.status == NWPath.Status.requiresConnection {
            internetValue = true
        }
    }
    let backgroudQueue = DispatchQueue.global(qos: .background)
    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        pathMonitor.start(queue: backgroudQueue)
    }
    private func isNetworkAvailable() -> Bool {
        if let path = self.path {
            if path.status == NWPath.Status.satisfied {
            return true
            }
        }
       return false
    }
}

final class ViewController: UIViewController, AVPlayerItemMetadataOutputPushDelegate {

    var play = true
    var changeThemeValue = true
    var shuffle = false
    var repeatValue = false
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
    var repeatButton = UIButton()
    var shuffleColor = textColor
    var repeatColor = textColor
    var metadataOutput = AVPlayerItemMetadataOutput()
    var networkReachability = NetworkReachability()
    var checkInetTimer = Timer()
    var inetPlayer = AVPlayer()
    var volumeTimer = Timer()
    var volumeValue: Float = 0
    var playback = false
    
    //отвечает за номер радиостанции
    var stationNumber = 0 {
        didSet {
            if shuffle {
                var temp = stationNumber
                while temp == stationNumber {
                    temp = Int.random(in: 0..<databaseRadio.count)
                }
                stationNumber = temp
            } else if repeatValue {
                switch stationNumber {
                case 6: stationNumber = 0
                case -1: stationNumber = 5
                default: break
                }
            }
            switch stationNumber {
            case databaseRadio.count: stationNumber = 0
            case -1: stationNumber = databaseRadio.count - 1
            default: break
            }
            //запоминание последней включенной станции
            saveData[0] = stationNumber
            saveDataFunc()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //загружаем базу станций
        loadStation()
        //згаружаем последние настройки приложения
        loadDataFunc()
        
        if let temp = saveData[0] as? Int {
            stationNumber = temp
        }
        if let temp = saveData[1] as? Bool {
            changeThemeValue = temp
        }
        if let temp = saveData[2] as? Bool {
            repeatValue = temp
        }
        if let temp = saveData[3] as? Bool {
            shuffle = temp
        }
        
        changeStation(stationNumber)
        setupRemoteTransportControls()
        changeTheme(changeThemeValue)
        createViewElements()
        
        if repeatValue {
            repeatValue = !repeatValue
            repeatFunc()
        }
        if shuffle {
            shuffle = !shuffle
            shuffleFunc()
        }
        
        //подключаем фоновое воспроизведение
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            //следим за ошибками аудиосессии
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        } catch {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if tableViewFlag {
            if let temp = UserDefaults.standard.array(forKey: "fromViewTable") {
                fromViewTable = temp
                if let value = fromViewTable[0] as? Int {
                    if value > 5 && repeatValue {
                        repeatFunc()
                    }
//                    print("старое занчение - ", stationNumber)
//                    print("Новое занчение - ", value)
//                    print(currentStationChange)
                    if currentStationChange && value != stationNumber {
                        stationNumber = value
                    } else if value != stationNumber && !changeDataBaseRadio {
                        stationNumber = value
                        changeStation(stationNumber)
                    } else if currentStationChange && value == stationNumber {
                        stationNumber = value
                        changeStation(stationNumber)
                    }
                }
            }
        }
        tableViewFlag = !tableViewFlag
        currentStationChange = false
    }
    
    //ставим pause при звонке и play по окончанию звонка
    @objc func handleInterruption (notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began { // при звонке .began срабатывает всегда
            inetPlayer.pause()
        } else if type == .ended { // а вот когда звонок заканчивается, .ended не срабатывает
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Ошибок больше нет, можно включать play
                    volumeValue = 0
                    inetPlayer.play()
                    //плавная громкость
                    volumeTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(volumeUp), userInfo: nil, repeats: true)
                }
            }
        }
    }

    //плавная громкость
    @objc func volumeUp () {
        if volumeValue <= 1.0 {
            inetPlayer.volume = volumeValue
            volumeValue += 0.01
            volumeValue = volumeValue * 1.2
        } else {
            inetPlayer.volume = 1.0
            volumeTimer.invalidate()
        }
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
        sleepTimerButton.tintColor = textColor
        themeButton.tintColor = textColor
        
        if shuffle {
            shuffleButton.tintColor = .systemRed
        } else {
            shuffleButton.tintColor = textColor
        }
        
        if repeatValue {
            repeatButton.tintColor = .systemRed
        } else {
            repeatButton.tintColor = textColor
        }
        
        if play {
            playOutlet.setImage(imagePause, for: .normal)
        } else {
            playOutlet.setImage(imagePlay, for: .normal)
        }
        
        changeThemeValue = !changeThemeValue
    }

    
    //MARK: - функция смены станций и старта плеера
    private func changeStation (_ value: Int) {
//        var valueTemp = 0
//        if value > databaseRadio.count {
//            valueTemp = 0
//            i = 0
//        } else {
//            valueTemp = value
//        }
        
        checkInetTimer.invalidate()
        playback = false
        
        titleTextLabel.text = databaseRadio[value].2
        
        let urlRadio = URL(string: String(databaseRadio[value].0))
        let inetPlayerItem = AVPlayerItem(url: urlRadio ?? URL(string: "http://www.ru")!)
        metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: .main)
        inetPlayerItem.add(metadataOutput)
        inetPlayer = AVPlayer(playerItem: inetPlayerItem)

        if play {
            titleImage = UIImage(named: databaseRadio[value].1) ?? UIImage(named: "default")!
            startAnimation()
            //inetPlayerItem.preferredForwardBufferDuration = 10
            inetPlayer.play()
            inetPlayer.volume = 0
            
            //проверяем наличие интернета каждые 1 сек
            checkInetTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(checkInternetConnection), userInfo: nil, repeats: true)
            
            //Надпись "Загружаю..."
            updateTextLabel()
            
        } else {
            inetPlayer.pause()
            metaDataLabel.text = ""
            //передаем в команд-центр ""
            setupNowPlaying(title: titleTextLabel.text!, setImage: titleImage, artist: metaDataLabel.text)
            stopAnimation()
            playback = false
        }
    }
    
    //реакция - если пропал или появился интернет
    @objc private func checkInternetConnection() {
    
        switch internetValue {
        case false where internetNow:
            imageOutlet.layer.borderWidth = 6
            imageOutlet.layer.borderColor = UIColor.red.cgColor
            metaDataLabel.textColor = .red
            playOutlet.isEnabled = false
            metaDataLabel.text = "Проблемы с интернетом"
            playOutlet.setImage(imagePlay, for: .normal)
            
            //передаем эту запись в команд центр
            setupNowPlaying(title: titleTextLabel.text!, setImage: titleImage, artist: metaDataLabel.text)
            
        case true where !internetNow:
            changeStation(stationNumber)
            imageOutlet.layer.borderWidth = 2
            imageOutlet.layer.borderColor = UIColor.white.cgColor
            metaDataLabel.textColor = textColor
            playOutlet.isEnabled = true
            playOutlet.setImage(imagePause, for: .normal)
        
        default: break
        }

        internetNow = internetValue
    }
    
    //MARK: - надпись "Загружаю..."  пока не началось воспроизведение
    private func updateTextLabel () {
        if inetPlayer.reasonForWaitingToPlay?.rawValue != nil {
            metaDataLabel.text = "Загружаю..."
        } else {
            if let tempImage = UIImage(named: databaseRadio[stationNumber].1) {
                imageOutlet.image = tempImage
            } else {
                imageOutlet.startAnimating()
            }
        }
        //передаем в команд-центр надпись "Загружаю..."
        setupNowPlaying(title: titleTextLabel.text!, setImage: titleImage, artist: metaDataLabel.text)
    }
    
    
    //MARK: - Вывод метаданных в команд центре
    //загрузка метадаты
    internal func metadataOutput (_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if let temp = groups.first?.items.first?.value as? String {
            metaDataLabel.text = temp
        } else {
            metaDataLabel.text = ""
        }
        
        //плавная громкость при включении станции
        if !playback {
            volumeValue = 0
            volumeTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(volumeUp), userInfo: nil, repeats: true)
            playback = true
        }
        
        //передаем что играем в команд-центр
        setupNowPlaying(title: titleTextLabel.text!, setImage: titleImage, artist: metaDataLabel.text)
    }
    
    //настройка и вывод метаданных в команд-центр
    private func setupNowPlaying (title: String, setImage: UIImage?, artist: String?){
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
    @objc func timerButton (_ sender: Any) {
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
        } else {
            playOutlet.setImage(UIImage(named: "pause1.png")!, for: .highlighted)
            playOutlet.setImage(imagePause, for: .normal)
        }
        play = !play
        changeStation(stationNumber)
    }
    
    @objc func forwardButton (_ sender: Any) {
        stationNumber += 1
        changeStation(stationNumber)
    }
    
    @objc func backwardButton (_ sender: Any) {
        stationNumber -= 1
        changeStation(stationNumber)
    }
    
    //MARK: - Настройка кнопок управления в команд центре
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.inetPlayer.rate == 0.0 && internetValue {
                self.playButton((Any).self)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.inetPlayer.rate == 1.0 && internetValue {
                self.playButton((Any).self)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.stationNumber += 1
            self.changeStation(self.stationNumber)
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.stationNumber -= 1
            self.changeStation(self.stationNumber)
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
        if UIImage(named: databaseRadio[stationNumber].1) == nil {
            imageOutlet.image = UIImage(named: "01a")!
        } else {
            imageOutlet.image = UIImage(named: databaseRadio[stationNumber].1)
        }
    }
    private func stopAnimation() {
        imageOutlet.stopAnimating()
        imageOutlet.animationImages = nil
        if UIImage(named: databaseRadio[stationNumber].1) == nil {
            imageOutlet.image = UIImage(named: "01a")!
        } else {
            imageOutlet.image = UIImage(named: databaseRadio[stationNumber].1)
        }
    }
    
    //перенести станцию в начало списка
    @objc func favoriteFunc () {
        databaseRadio.insert(databaseRadio[stationNumber], at: 0)
        databaseRadio.remove(at: stationNumber + 1)
        saveStation()
        let alertController = UIAlertController(title: "", message: " Станция перенесена в начало списка", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        stationNumber = 0
    }
    
    //включаем/отключаем shuffle
    @objc func shuffleFunc () {
        if repeatValue {
            repeatFunc()
        }
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
        saveData[3] = shuffle
        saveDataFunc()
        shuffleButton.tintColor = shuffleColor
    }
    
    //включаем/отключаем repeat
    @objc func repeatFunc () {
        if shuffle {
            shuffleFunc()
        }
        repeatValue = !repeatValue
        if repeatValue {
            repeatColor = .systemRed
            repeatButton.layer.shadowOpacity = 1.0
            repeatButton.layer.shadowRadius = 10
        } else {
            repeatColor = textColor
            repeatButton.layer.shadowOpacity = 0
            repeatButton.layer.shadowRadius = 0
        }
        if stationNumber >= 6 {
            stationNumber = 0
            changeStation(stationNumber)
        }
        saveData[2] = repeatValue
        saveDataFunc()
        repeatButton.tintColor = repeatColor
    }

    //переход на следующий view
    @objc func nextViewFunc (_ sender: Any) {
        //настройки для правильного отображения CollectionViewController
        let flowLayout = UICollectionViewFlowLayout()
        let myCollectionViewController = MyCollectionViewController(collectionViewLayout: flowLayout)
        myCollectionViewController.changeThemeValue = changeThemeValue
        myCollectionViewController.currentStation = stationNumber
        self.navigationController?.pushViewController(myCollectionViewController, animated: true)
    }
    
    //MARK: - располагаем элементы на вью контроллере
    fileprivate func createViewElements() {
        
        //Делаем навигатор бар прозрачным
        navigationBar = (navigationController?.navigationBar)!
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        let size = view.bounds.width * 0.68
        imageOutlet.frame = CGRect(x: (view.bounds.width - size) / 2, y: view.bounds.height * 0.187, width: size, height: size)
        imageOutlet.layer.cornerRadius = size / 2
        imageOutlet.contentMode = .scaleAspectFit
        imageOutlet.backgroundColor = UIColor(red: 13.0/255.0, green: 30.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        imageOutlet.clipsToBounds = true
        imageOutlet.layer.borderWidth = 2
        imageOutlet.layer.borderColor = UIColor.white.cgColor
        
        backButtonOutlet.frame = CGRect(x: view.bounds.width * 0.187, y: view.bounds.height * 0.745, width: 40, height: 44)
        backButtonOutlet.setImage(UIImage(named: "back.png"), for: .highlighted)
        backButtonOutlet.addTarget(self, action: #selector(backwardButton), for: .touchUpInside)
        
        nextButtonOutlet.frame = CGRect(x: view.bounds.width * 0.709, y: view.bounds.height * 0.745, width: 40, height: 44)
        nextButtonOutlet.setImage(UIImage(named: "for.png"), for: .highlighted)
        nextButtonOutlet.addTarget(self, action: #selector(forwardButton), for: .touchUpInside)
        
        playOutlet.frame = CGRect(x: view.bounds.width / 2 - 20, y: view.bounds.height * 0.745, width: 40, height: 44)
        playOutlet.setImage(UIImage(named: "pause1.png"), for: .highlighted)
        playOutlet.addTarget(self, action: #selector(playButton), for: .touchUpInside)
        
        sleepTimerLabel.frame = CGRect(x: view.bounds.width / 2 - 130, y: view.bounds.height * 0.055, width: 260, height: 25)
        sleepTimerLabel.textAlignment = .center
        sleepTimerLabel.textColor = .systemRed
        
        metaDataLabel.frame = CGRect(x: view.bounds.width / 2 - 100, y: view.bounds.height * 0.6, width: 200, height: 60)
        metaDataLabel.numberOfLines = 2
        metaDataLabel.textAlignment = .center
        metaDataLabel.adjustsFontSizeToFitWidth = true
        
        volumeMin.frame = CGRect(x: view.bounds.width * 0.11, y: view.bounds.height * 0.88, width: 22, height: 22)
        volumeMin.image = UIImage(systemName: "speaker.1.fill")
        volumeMin.tintColor = UIColor.darkGray
        
        volumeMax.frame = CGRect(x: view.bounds.width * 0.805, y:  view.bounds.height * 0.878, width: 32, height: 24)
        volumeMax.image = UIImage(systemName: "speaker.3.fill")
        volumeMax.tintColor = UIColor.darkGray
        
        titleTextLabel.frame = CGRect(x: view.bounds.width / 2 - 115, y: view.bounds.height * 0.1, width: 230, height: 40)
        titleTextLabel.textAlignment = .center
        titleTextLabel.adjustsFontSizeToFitWidth = true
        titleTextLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleTextLabel.textColor = textColor
        
        favoriteButton.frame = CGRect(x: view.bounds.width * 0.77, y: view.bounds.height * 0.53, width: 40, height: 40)
        favoriteButton.backgroundColor = .systemRed
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.clipsToBounds = true
        favoriteButton.addTarget(self, action: #selector(favoriteFunc), for: .touchUpInside)
        
        //Кнопки навигатор контроллера
        themeButton.frame = CGRect(x: 0, y: 0, width: 27, height: 26)
        themeButton.setImage(themeImage, for: .normal)
        themeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        themeButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        themeButton.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: themeButton)
        
        sleepTimerButton.frame = CGRect(x: 0, y: 0, width: 26, height: 25)
        sleepTimerButton.setImage(UIImage(systemName: "timer"), for: .normal)
        sleepTimerButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        sleepTimerButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        sleepTimerButton.addTarget(self, action: #selector(timerButton), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: sleepTimerButton)
        
        shuffleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 0)
        shuffleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        shuffleButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        shuffleButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        shuffleButton.tintColor = textColor
        let item3 = UIBarButtonItem(customView: shuffleButton)
        
        //пример создания тени к Image, еще код в методе shuffleFunc
        shuffleButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        shuffleButton.layer.shadowColor = UIColor.white.cgColor
        shuffleButton.addTarget(self, action: #selector(shuffleFunc), for: .touchUpInside)
        
        repeatButton.frame = CGRect(x: 0, y: 0, width: 30, height: 0)
        repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        repeatButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        repeatButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        repeatButton.tintColor = textColor
        let item4 = UIBarButtonItem(customView: repeatButton)
        
        navigationItem.leftBarButtonItems = [item1, item2]
        navigationItem.rightBarButtonItems = [item3, item4]
        
        //пример создания тени к Image, еще код в методе shuffleFunc
        repeatButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        repeatButton.layer.shadowColor = UIColor.white.cgColor
        repeatButton.addTarget(self, action: #selector(repeatFunc), for: .touchUpInside)
        
        let arrayViews = [backgroundView, imageOutlet, backButtonOutlet, nextButtonOutlet, playOutlet, sleepTimerLabel, metaDataLabel, volumeMin, volumeMax, titleTextLabel, favoriteButton, shuffleButton, repeatButton]
        for views in arrayViews {
            view.addSubview(views)
        }
        let volumeSlider = UIView(frame: CGRect(x: view.bounds.width * 0.187, y: view.bounds.height * 0.8829, width: view.bounds.width * 0.6, height: 25))
        
        //настройка слайдера громкости
        volumeSlider.tintColor = .systemRed
        self.view.addSubview(volumeSlider)
        let volumeView = MPVolumeView(frame: volumeSlider.bounds)
        volumeView.showsRouteButton = false
        volumeSlider.addSubview(volumeView)
        
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
    }
}
