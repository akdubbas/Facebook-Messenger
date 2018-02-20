//
//  ChatLogController.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/12/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase


class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    var messages = [Message]()
    //the user to which the message should be sent to
    var user : User? {
        didSet {
            navigationItem.title = user?.name ?? "Dummy"
            observeMessages()
        }
    }
    lazy var inputTextField : UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter message.."
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setUpInputComponents()
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        setUpChatCell(cell: cell,message: message)
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        return cell
    }
    
    private func setUpChatCell(cell : ChatMessageCell,message : Message)
    {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl )
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing message
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else{
            cell.bubbleView.backgroundColor = UIColor(r : 240, g : 240, b : 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 28
        }
        
        return CGSize(width : view.frame.width, height : height)
    }
    private func estimateFrameForText(text:String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string : text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    func observeMessages()
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //Search for the messageId first with the logged in User Id
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            //search for all the messages(with messaged Id's) recieved by the logged in user
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
                guard let dictionary = snapshot.value as? [String :AnyObject] else {
                    return
                }
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                
                if message.chatPartnerId() == self.user?.id {
                self.messages.append(message)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                }
                
                
                
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    func setUpInputComponents()
    {
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)
        
    //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type : .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant : 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLine)
        
        //x,y,w,h
        seperatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
   
        
    }
    
    @objc func handleSendMessage()
    {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp  = Int(Date().timeIntervalSince1970)
        let values : [String :AnyObject] = ["text":inputTextField.text! as AnyObject,"toId" : toId as AnyObject,"fromId" : fromId as AnyObject,"timeStamp":timeStamp as AnyObject]
        //childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!)
            recipientUserMessagesRef.updateChildValues([messageId:1])
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
