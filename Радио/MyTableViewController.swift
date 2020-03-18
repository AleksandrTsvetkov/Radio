//
//  MyTableViewController.swift
//  Радио
//
//  Created by Sergei Sidorenko on 18/03/2020.
//  Copyright © 2020 Sergei Sidorenko. All rights reserved.
//

import UIKit

//протокол для вызова методов основного View
protocol popProtocol {
    func changeTheme()
    func timerButton()
    func shuffleFunc()
    func repeatFunc()
}

final class MyTableViewController: UITableViewController {
    
    var delegate: popProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
    }

    //Размер popView
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 58, height: tableView.contentSize.height)
    }
    
    //высота ячейки - задается по желанию
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var n = 43
        if indexPath.row == 0 {
            n = 7
        }
        return CGFloat(n)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 27, height: 27))
        switch indexPath.row {
        case 1:
            button.setImage(themeImage, for: .normal)
            button.tintColor = .black
        case 2:
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 23)
            button.setImage(UIImage(systemName: "repeat"), for: .normal)
            if repeatValue {
                button.tintColor = .systemRed
            } else {
                button.tintColor = .black
            }
        case 3:
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 23)
            button.setImage(UIImage(systemName: "shuffle"), for: .normal)
            if shuffle {
                button.tintColor = .systemRed
            } else {
                button.tintColor = .black
            }
        case 4:
            button.setImage(UIImage(systemName: "timer"), for: .normal)
            button.tintColor = .black
        default: break
        }
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        button.tag = indexPath.row
        cell.accessoryView = button
        button.addTarget(self, action: #selector(button(_:)), for: .touchUpInside)
        //cell.backgroundColor = UIColor(red: 235/255, green: 225/255, blue: 170/255, alpha: 1.0)
        return cell
    }
    
    @objc
    private func button(_ sender : UIButton!){
        dismiss(animated: true, completion: nil)
        switch sender.tag {
        case 1: delegate?.changeTheme()
        case 2: delegate?.repeatFunc()
        case 3: delegate?.shuffleFunc()
        case 4: delegate?.timerButton()
        default: break
        }
    }
}
