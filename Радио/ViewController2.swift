import UIKit

final class ViewController2: UIViewController {
    
 //   var settingsButton = UIButton()
    var titleText = UILabel()
    var stationText = UITextView()
    var addButton = UIButton()
    var removeButton = UIButton()
    var changeThemeValue = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if changeThemeValue {
            //установки светлой темы
            stationText.backgroundColor = UIColor(red: 170.0/255.0, green: 205.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            view.backgroundColor = UIColor(red: 110.0/255.0, green: 205.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        } else {
            //установки темной темы
            stationText.backgroundColor = UIColor(red: 25.0/255.0, green: 55.0/255.0, blue: 80.0/255.0, alpha: 1.0)
            view.backgroundColor = UIColor(red: 13.0/255.0, green: 30.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        }
        
//        //кнопка "настройки" в навигатор баре
//        settingsButton.frame = CGRect(x: 0, y: 0, width: 28, height: 26)
//        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
//        settingsButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
//        settingsButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
//        settingsButton.addTarget(self, action: #selector(nextViewFunc), for: .touchUpInside)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
      //  navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .done, target: self, action: #selector(exit))
        
        //располагаем элементы на View
        titleText.frame = CGRect(x: 25, y: 100, width: 220, height: 30)
        titleText.textColor = textColor
        titleText.font = UIFont.boldSystemFont(ofSize: 26)
        titleText.text = "Список станций:"
        view.addSubview(titleText)
        
        stationText.frame = CGRect(x: 0, y: 150, width: self.view.bounds.width, height: self.view.bounds.height - 150)
        stationText.textColor = textColor
        stationText.isEditable = false
        stationText.isSelectable = false
        stationText.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(stationText)
        
        addButton.frame = CGRect(x: self.view.bounds.width - 55, y: 100, width: 28, height: 27)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .red
        addButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        addButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        addButton.addTarget(self, action: #selector(addFunc), for: .touchUpInside)
        view.addSubview(addButton)
        
        removeButton.frame = CGRect(x: self.view.bounds.width - 105, y: 100, width: 30, height: 30)
        removeButton.setImage(UIImage(systemName: "minus"), for: .normal)
        removeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        removeButton.addTarget(self, action: #selector(removeFunc), for: .touchUpInside)
        view.addSubview(removeButton)
        
        printStation()
        
    }
    
    //выводим названия станций
    private func printStation() {
        stationText.text = ""
        var n = 1
        for value in databaseRadio {
            stationText.text += "     " + String(n) + "  " + value.2 + "\n"
            n += 1
        }
        
        if databaseRadio.count > 1 {
            removeButton.tintColor = .red
            removeButton.isEnabled = true
        } else {
            removeButton.tintColor = .gray
            removeButton.isEnabled = false
        }
    }
    
    //добавить станцию
    @objc func addFunc () {
        
        let alertController = UIAlertController(title: "Добавить станцию", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
               textField.placeholder = "Название станции"
               textField.autocapitalizationType = .words
           }
        let saveAction = UIAlertAction(title: "Готово", style: UIAlertAction.Style.default, handler: { alert -> Void in
               let firstTextField = String(alertController.textFields?[0].text ?? "")
               let secondTextField = String(alertController.textFields?[1].text ?? "")
            if firstTextField.count != 0 && secondTextField.count != 0 {
                databaseRadio.append(("http://" + secondTextField, "", firstTextField))
                saveStation()
                self.printStation()
            }
           })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: {
               (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
               textField.placeholder = "Без http://"
           }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //удалить станцию
    @objc func removeFunc () {
        let alertController = UIAlertController(title: "Удалить станцию", message: "Введите номер станции", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Готово", style: .default) { (action) in
            let text = alertController.textFields![0] as UITextField
            if Int(text.text!) != nil {
                if Int(text.text!)! <= databaseRadio.count {
                    databaseRadio.remove(at: Int(text.text!)! - 1)
                    saveStation()
                    self.printStation()
                }
            }
        }
        
        let action2 = UIAlertAction(title: "Отмена", style: .default) { (action) in
        }
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.keyboardType = .numberPad})
        alertController.addAction(action2)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //назад
    @objc func exit () {
        self.navigationController?.popViewController(animated: true)
    }



}
