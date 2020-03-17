//
//  MyCollectionViewController.swift
//  Радио
//
//  Created by Sergei Sidorenko on 15/03/2020.
//  Copyright © 2020 Sergei Sidorenko. All rights reserved.
//
import UIKit

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var backgroundImage = UIImageView()
    var changeThemeValue = Bool()
    var backColor = UIColor()
    var currentStation = Int()
    var addButton = UIButton()
    var textLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewFlag = true
        changeDataBaseRadio = false
        
        if changeThemeValue {
            backgroundImage.image = UIImage(named: "white")
            backColor = UIColor(red: 193/255, green: 205/255, blue: 247/255, alpha: 1.0)
        } else {
            backgroundImage.image = UIImage(named: "black1")
            backColor = UIColor(red: 12/255, green: 30/255, blue: 44/255, alpha: 1.0)
        }
        
        let view1 = UIViewController()
        addChild(view1)
        view1.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 120)
        view1.view.backgroundColor = backColor
        view.addSubview(view1.view)
        
        textLabel.frame = CGRect(x: 10, y: 70, width: 250, height: 50)
        textLabel.text = "Радиостанции"
        textLabel.textColor = textColor
        textLabel.font = UIFont.boldSystemFont(ofSize: 32)
        view1.view.addSubview(textLabel)
        
        collectionView?.backgroundView = backgroundImage
        collectionView?.frame = CGRect(x: 0, y: 120, width: view.frame.size.width, height: view.frame.size.height-120)
        //расстояния между ячейками и от краев экрана
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionView!.collectionViewLayout = layout
        
        //кнопки в навигатор баре
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.addTarget(self, action: #selector(addFunc), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)

        //регистрируем ячейку подписываемся на делегаты
        collectionView!.register(myViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dragInteractionEnabled = true
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        
        saveViewTable(value: currentStation)
        
        //подключаем долгий тап
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        collectionView?.addGestureRecognizer(longPress)
    }
    
    //долгий тап на ячейке
    @objc func handleLongPress (gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .began {
            return
        }
        let p = gesture.location(in: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            if databaseRadio.count > 1 {
                deleteFunc(indexPath)
            }
        }
    }
    
    //MARK: - Добавление станции
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
                self.collectionView.reloadData()
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

    //MARK: - удаление станции
    private func deleteFunc (_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Удалить станцию?\n", message: databaseRadio[indexPath.row].2, preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Да", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            databaseRadio.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
            saveStation()
           })
        let cancelAction = UIAlertAction(title: "нет", style: UIAlertAction.Style.default, handler: {
               (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    //количество ячеек
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return databaseRadio.count
    }
    //содержание ячеек
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! myViewCell
        let image = UIImage(named: databaseRadio[indexPath.row].1) ?? UIImage(named: "default")
        let value = databaseRadio[indexPath.row].2
        cell.imageView.image = image
        cell.nameLabel.text = value
        
        return cell
    }
    //размер ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightCell = (self.view.frame.size.width - 20.0) / 3.0
        return CGSize(width: heightCell, height: heightCell + 20)
    }
    //срабатывает при выборе ячейки
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        saveViewTable(value: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - класс ячейки
final class myViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private func setupView() {
        backgroundColor = .white
        let heightCell = (UIScreen.main.bounds.width - 20.0) / 3.0
        
        //расположение Label в ячейке
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: ["label" : nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(heightCell))-[label]|", options: [], metrics: nil, views: ["label" : nameLabel]))
        
        //расположение ImageView
        addSubview(imageView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image]|", options: [], metrics: nil, views: ["image" : imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]-(20)-|", options: [], metrics: nil, views: ["image" : imageView]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Drag & Drop
extension MyCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = databaseRadio[indexPath.row]
        return [dragItem]
    }
}

extension MyCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            collectionView.performBatchUpdates({
                let temp = databaseRadio[sourceIndexPath.item]
                databaseRadio.remove(at: sourceIndexPath.item)
                databaseRadio.insert(temp, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                var k = currentStation
//                print("currentStation - ", currentStation)
                if sourceIndexPath.item == currentStation {
                    k = destinationIndexPath.item
                } else {
                    if sourceIndexPath.item < currentStation && destinationIndexPath.item == currentStation {
                        k -= 1
                    }
                    if sourceIndexPath.item > currentStation && destinationIndexPath.item <= currentStation {
                        k += 1
                    }
                }
                if currentStation != k {
                    currentStationChange = true
                }
                currentStation = k
                saveViewTable(value: currentStation)
//                print("sourceIndexPath.item - ", sourceIndexPath.item)
//                print("destinationIndexPath.item - ", destinationIndexPath.item)
//                print("Сохранил - ", currentStation)
                changeDataBaseRadio = true
                saveStation()
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
