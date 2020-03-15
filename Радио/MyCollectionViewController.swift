//
//  MyCollectionViewController.swift
//  Радио
//
//  Created by Sergei Sidorenko on 15/03/2020.
//  Copyright © 2020 Sergei Sidorenko. All rights reserved.
//
import UIKit

final class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var backgroundImage = UIImageView()
    var changeThemeValue = Bool()
    var currentStation = Int()
    var addButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewFlag = true
        changeDataBaseRadio = false
        
        if changeThemeValue {
            backgroundImage.image = UIImage(named: "white")
        } else {
            backgroundImage.image = UIImage(named: "black1")
        }
        collectionView?.backgroundView = backgroundImage
        
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
    }
    
    //Добавление станции
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
        let heightCell = (self.view.frame.size.width - 44.0) / 3.0
        return CGSize(width: heightCell, height: heightCell + 20)
    }
    //срабатывает при выборе ячейки
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeDataBaseRadio = false
        saveViewTable(value: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
    
    //расстояния от боков экрана
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
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
        let heightCell = (UIScreen.main.bounds.width - 44.0) / 3.0
        
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
//                print("currentStation - ", currentStation)
                if sourceIndexPath.item == currentStation {
                    saveViewTable(value: destinationIndexPath.item)
                } else {
                    if sourceIndexPath.item < currentStation {
                        currentStation -= 1
                    }
                    if destinationIndexPath.item <= currentStation {
                        currentStation += 1
                    }
                    saveViewTable(value: currentStation)
                }
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
