import UIKit

final class ViewController2: UIViewController {
    
 //   var settingsButton = UIButton()
    var backgroundView = UIImageView()
    var titleText = UILabel()
    var stationTable = UITableView()
    var addButton = UIButton()
    var editButton = UIButton()
    var changeThemeValue = Bool()
    var currentStation = Int()
    var identifier = "MyCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewFlag = true
        
        if changeThemeValue {
            backgroundView.image = UIImage(named: "black")
        } else {
            backgroundView.image = UIImage(named: "black1")
        }
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        view.addSubview(backgroundView)
        
        //кнопки в навигатор баре
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.addTarget(self, action: #selector(addFunc), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: addButton)
        
        editButton.setImage(UIImage(systemName: "rectangle.grid.1x2"), for: .normal)
        editButton.addTarget(self, action: #selector(editTable), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItems = [item2, item1]
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .done, target: self, action: #selector(exit))
        
        //располагаем элементы на View
        stationTable = UITableView(frame: CGRect(x: 0, y: 150, width: view.bounds.width, height: view.bounds.height - 150), style: .plain)
        stationTable.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        
        //подписываем на делегат и dataSource
        stationTable.delegate = self
        stationTable.dataSource = self
        
        //маска подгоняет размеры ячеек
        stationTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(stationTable)
        
        titleText.frame = CGRect(x: 25, y: 100, width: 220, height: 30)
        titleText.textColor = textColor
        titleText.font = UIFont.boldSystemFont(ofSize: 26)
        titleText.text = "Список станций:"
        view.addSubview(titleText)
        
        saveViewTable(value: currentStation)
        
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
                self.stationTable.reloadData()
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
    
    @objc func editTable() {
        stationTable.isEditing = !stationTable.isEditing
    }
    
//    //назад
//    @objc func exit () {
//        self.navigationController?.popViewController(animated: true)
//    }
}

extension ViewController2: UITableViewDataSource, UITableViewDelegate {
    
    //высота ячейки - задается по желанию
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databaseRadio.count
    }
    //заполняем таблицу данными из массива станций
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let value = databaseRadio[indexPath.row].2
        if indexPath.row < 6 {
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 0.1)
        } else {
            cell.backgroundColor = .clear
        }
        cell.textLabel?.text = value
        return cell
    }
    
    //удаление станций
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if databaseRadio.count > 1 {
            databaseRadio.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            saveStation()
        }
    }
    
    //перетягивание ячеек
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = databaseRadio[sourceIndexPath.row]
        databaseRadio.remove(at: sourceIndexPath.row)
        databaseRadio.insert(item, at: destinationIndexPath.row)
        tableView.reloadData()
        saveStation()
    }
    
    //срабатывает при выборе ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveViewTable(value: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}
