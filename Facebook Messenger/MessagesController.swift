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
    
        checkIfUserisLoggedIn()
        
    }
    
    func checkIfUserisLoggedIn()
    {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        }
        else
        {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject]
                {
                    self.navigationItem.title = dictionary["name"] as? String
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

