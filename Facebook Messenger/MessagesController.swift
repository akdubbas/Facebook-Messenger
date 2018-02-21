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
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let newMessageIcon  = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIcon, style: .plain, target: self, action: #selector(handleNewMessage))
    
        checkIfUserisLoggedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        //observeUserMessages()
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    
    func observeUserMessages()
    {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId : String)
    {
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String :AnyObject] {
                let message = Message(dictionary:dictionary)
                /*message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String*/
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                self.attemptReloadOfTimer()
                //we just cancelled our timer
                
            }
            
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTimer()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        print("Schedule a table reload in 0.1 sec")
    }
    
    var timer :Timer?
    //This has to be done to reduce number of relaods and to show the correct Profile user images
    @objc func handleReloadTable()
    {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: {
            (m1,m2) -> Bool in
            
            guard let t1 = m1.timeStamp?.intValue, let t2 = m2.timeStamp?.intValue else{
                return false
            }
            return t1 >  t2
        })
        DispatchQueue.main.async(execute: {
            print("We reloaded the table")
            self.tableView.reloadData()
        })
    }
  
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatLogController(user: user)
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    @objc func handleNewMessage()
    {
        let newMessageController = NewMessageTableViewController()
        newMessageController.messageController = self
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
          fetchUserAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserAndSetUpNavBarTitle()
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some uid is nil
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]
            {
                let user = User(dictionary: dictionary)
                self.setNavBarWithUser(user: user)
            }
            
            print(snapshot)
            
        }, withCancel: nil)
    }
    
    func setNavBarWithUser(user : User)
    {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        let titleView = UIButton()
        titleView.frame = CGRect(x:0,y:0,width:100,height:40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ProfileImage constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        ////nameLabel constraints
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant : 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
 
        self.navigationItem.titleView = titleView
        //titleView.addTarget(self, action: #selector(showChatLogController), for: .touchUpInside)
        
        
        
    }
    
    @objc func showChatLogController(user : User)
    {
        let chatController = ChatLogController(collectionViewLayout : UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
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
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }

}

