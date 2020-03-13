import UIKit

public var databaseRadio: [(String, String, String)] = []
public var saveDataRadio: [String] = []
public var fromViewTable: [Any] = []
public var saveData : [Any] = []
public var textColor = UIColor()
public var imageBack = UIImage()
public var imageNext = UIImage()
public var imagePlay = UIImage()
public var imagePause = UIImage()
public var themeImage = UIImage()
public var backgroundImage = UIImage()
public var internetValue = true
public var internetNow = true
public var tableViewFlag = false

//сохранение данных
func saveDataFunc () {
    UserDefaults.standard.set(saveData, forKey: "start")
    UserDefaults.standard.synchronize()
}

//загрузка данных
func loadDataFunc () {
    if let loadUser = UserDefaults.standard.array(forKey: "start") {
        saveData = loadUser
    }
    if saveData.count < 3 {
        saveData.removeAll()
        saveData.append(0)
        saveData.append(false)
        saveData.append(false)
    }
}

//сохранение данных для перехода на View2
func saveViewTable (value: Int) {
    fromViewTable.removeAll()
    fromViewTable.append(value)
    UserDefaults.standard.set(fromViewTable, forKey: "fromViewTable")
}


//сохранение базы станций
func saveStation () {
    saveDataRadio.removeAll()
    for j in 0..<databaseRadio.count {
        saveDataRadio.append(databaseRadio[j].0)
        saveDataRadio.append(databaseRadio[j].1)
        saveDataRadio.append(databaseRadio[j].2)
    }
    UserDefaults.standard.set(saveDataRadio, forKey: "Station")
    UserDefaults.standard.synchronize()
}

//загрузка базы станций
func loadStation () {
    var tempBase: [Any] = []
    if let loadUser = UserDefaults.standard.array(forKey: "Station") {
        tempBase = loadUser
    }
    //если сохраненных станций нет - загружаем свою базу
    if tempBase.count == 0 {
        databaseRadio = Data.baseRadio
    }
        for n in 0..<(tempBase.count / 3) {
            if n == databaseRadio.count {
                databaseRadio.append(("", "", ""))
            }
            if let temp = tempBase[3 * n] as? String {
                databaseRadio[n].0  = temp
            }
            if let temp = tempBase[1 + 3 * n] as? String {
                databaseRadio[n].1  = temp
            }
            if let temp = tempBase[2 + 3 * n] as? String {
                databaseRadio[n].2  = temp
            }
        }
}

//  Код для цвета текста в статус баре не работает без добавления строчки в plist.info.
//  Этой строки нет её надо именно добавить с помощью плюсика. View controller-based status bar appearance = NO.
//темная тема
func darkThemeFunc (_ value: Bool) {
    if value {
        UIApplication.shared.statusBarStyle = .lightContent
        textColor = .white
        imageBack = UIImage(named: "backwardDark.png")!
        imageNext = UIImage(named: "forwardDark.png")!
        imagePlay = UIImage(named: "playDark.png")!
        imagePause = UIImage(named: "pauseDark.png")!
        themeImage = UIImage(systemName: "sun.max.fill")!
        backgroundImage = UIImage(named: "black.jpg")!        
    } else {
        UIApplication.shared.statusBarStyle = .default
        textColor = .black
        imageBack = UIImage(named: "backward.png")!
        imageNext = UIImage(named: "forward.png")!
        imagePlay = UIImage(named: "play.png")!
        imagePause = UIImage(named: "pause.png")!
        themeImage = UIImage(systemName: "moon.stars.fill")!
        backgroundImage = UIImage(named: "white.jpg")!
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navViewController = UINavigationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //создаем Navigation Controller
        let view1 = ViewController()
        navViewController = UINavigationController(rootViewController: view1)
        
        //цвет кнопок в навигатор баре по умолчанию
        UINavigationBar.appearance().tintColor = .white
                
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navViewController
        
        //цвет подложки
        self.window?.backgroundColor = UIColor(red: 110.0/255.0, green: 180.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

