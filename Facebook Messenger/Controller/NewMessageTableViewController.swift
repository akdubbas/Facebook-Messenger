//
//  NewMessageTableViewController.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/6/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {
    
    let cellId = "cellID"
    var users  = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUsers()
    }
    
    func fetchUsers()
    {
     
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                print(user.name!, user.email!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            print("User")
            print(snapshot)
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }

}


class UserCell : UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}














