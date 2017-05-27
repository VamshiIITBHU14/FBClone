//
//  OtherControllers.swift
//  FacebookClone
//
//  Created by Vamshi Krishna on 27/05/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import Foundation
import UIKit

class FriendRequestsController:UITableViewController{
    
    static let cellId = "cellId"
    static let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Friend Requests"
        tableView.separatorColor = UIColor.returnRGBColor(r: 229, g: 231, b: 235, alpha: 1)
        tableView.sectionHeaderHeight = 26
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: FriendRequestsController.cellId)
        tableView.register(RequestHeader.self, forHeaderFooterViewReuseIdentifier: FriendRequestsController.headerId)
        tableView.allowsSelection = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestsController.cellId, for: indexPath) as! FriendRequestCell
        if indexPath.row % 3 == 0 {
            cell.nameLabel.text = "Mark Zuckerberg"
            cell.requestImageView.image = UIImage(named: "zuckprofile")
        } else if indexPath.row % 3 == 1 {
            cell.nameLabel.text = "Steve Jobs"
            cell.requestImageView.image = UIImage(named: "steve_profile")
        } else {
            cell.nameLabel.text = "Mahatma Gandhi"
            cell.requestImageView.image = UIImage(named: "gandhi_profile")
        }
        
        cell.imageView?.backgroundColor = UIColor.black
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendRequestsController.headerId) as! RequestHeader
        
        if section == 0 {
            header.nameLabel.text = "FRIEND REQUESTS"
        } else {
            header.nameLabel.text = "PEOPLE YOU MAY KNOW"
        }
        
        return header
    }
}

class RequestHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "FRIEND REQUESTS"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(white: 0.4, alpha: 1)
        return label
    }()
    
    let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.returnRGBColor(r: 229, g: 231, b: 235, alpha: 1)
        return view
    }()
    
    func setupViews(){
        addSubview(nameLabel)
        addSubview(bottomBorderView)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: nameLabel)
        addConstraintsWithFormat(format: "H:|[v0]|", views: bottomBorderView)
        addConstraintsWithFormat(format: "V:|[v0][v1(0.5)]|", views: nameLabel,bottomBorderView)
    }
    
}

class FriendRequestCell:UITableViewCell{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let requestImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .blue
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let confirmButton:UIButton = {
        let button = UIButton()
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.returnRGBColor(r: 87, g: 143, b: 255, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.layer.cornerRadius = 2
        return button
    }()
    
    let deleteButton:UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(UIColor(white: 0.3, alpha: 1), for: .normal)
        button.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 2
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        return button
    }()
    
    func setupViews(){
        addSubview(nameLabel)
        addSubview(requestImageView)
        addSubview(confirmButton)
        addSubview(deleteButton)
        
        addConstraintsWithFormat(format: "H:|-16-[v0(52)]-8-[v1]|", views: requestImageView, nameLabel)
        addConstraintsWithFormat(format: "V:|-4-[v0]-4-|", views: requestImageView)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-[v1(24)]-8-|", views: nameLabel, confirmButton)
        addConstraintsWithFormat(format: "H:|-76-[v0(80)]-8-[v1(80)]", views: confirmButton, deleteButton)
        addConstraintsWithFormat(format: "V:[v0(24)]-8-|", views: deleteButton)
    }
}
