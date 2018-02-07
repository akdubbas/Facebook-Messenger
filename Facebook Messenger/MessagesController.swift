//
//  ViewController.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/4/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase
class MessagesController: UITableViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let newMessageIcon  = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIcon, style: .plain, target: self, action: #selector(handleNewMessage))
    
        checkIfUserisLoggedIn()
        
    }
    
    @objc func handleNewMessage()
    {
        let newMessageController = NewMessageTableViewController()
        let navController = UINavigationController(rootViewController : newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserisLoggedIn()
    {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return 
            
        }
        else
        {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject]
                {
                    let user = User(dictionary: dictionary)
                    //self.setupNavBarWithUser(user)
                }
                
                print(snapshot)
                
            }, withCancel: nil)
                
            
        }
    }
    
   

    @objc func handleLogout()
    {
        do{
            try Auth.auth().signOut()
                
        }
            catch let logoutError{
            print(logoutError)
            }
        
        let loginController = LoginViewController()
        present(loginController, animated: true, completion: nil)
    }

}

