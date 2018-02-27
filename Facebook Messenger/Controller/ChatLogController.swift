//
//  ChatLogController.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/12/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    var messages = [Message]()
    var textAndImage : Bool?
    var containerViewBottomAnchor : NSLayoutConstraint?
    let cellId = "cellId"
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        setKeyBoardObservers()
    }
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.addSubview(self.inputTextField)
        
        
        let sendButton = UIButton(type : .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named : "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor,constant : 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLine)
        
        //x,y,w,h
        seperatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //we selected a video
            handleVideoSelectedForUrl(url: videoUrl)
            
        }
        else{
            //we selected an image
            handleImageSelectedForInfo(info: info as [String:AnyObject])
        }
        
       dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url : URL)
    {
        let filename = UUID().uuidString + ".mov"
        let uplaodTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if(error != nil)
            {
                print("Failed to upload the video", error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                self.textAndImage = videoUrl.isEmpty
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl : url){
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage,completion: {(imageUrl) in
                        let properties : [String : AnyObject] = ["imageUrl": imageUrl as AnyObject,"imageWidth" : thumbnailImage.size.width as AnyObject,"imageHeight" : thumbnailImage.size.height as AnyObject,"videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                        
                    })
                    
                }
                
                
                
                
            }
        })
        uplaodTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
            //print(snapshot.progress?.completedUnitCount)
        }
        uplaodTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForFileUrl(fileUrl : URL) -> UIImage?
    {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info : [String : AnyObject])
    {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOrginalImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let profileImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image : profileImage, completion: {(imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl,image : profileImage)
            })
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(image : UIImage,completion : @escaping (_ imageUrl : String) -> ())
    {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                    //self.sendMessageWithImageUrl(imageUrl: imageUrl,image : image)
                }
                
            })
        }
    }

    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    func setKeyBoardObservers()
    {
        //Move the container view upside whenever the Keyboard is shown on ChatLogController
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow()
    {
        if messages.count > 0 {
        let indexPath  = NSIndexPath(item: self.messages.count - 1, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleKeyBoardWillShow(notification : NSNotification)
    {
        //print(notification.userInfo!)
        //Get the height of Keyboard from userInfo
        
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func handleKeyBoardWillHide(notification : NSNotification)
    {
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        let message = messages[indexPath.row]
        cell.message = message
        cell.textView.text = message.text
        setUpChatCell(cell: cell,message: message)
        
        
        if let text = message.text {
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }
        else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
      
        cell.playButton.isHidden = message.videoUrl == nil
        return cell
    }
    
    private func setUpChatCell(cell : ChatMessageCell,message : Message)
    {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl )
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            //hide the bubbleView if image is in
            cell.bubbleView.backgroundColor = UIColor.clear
            
        }
        else{
            cell.messageImageView.isHidden = true
            
            
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
        
        let message = messages[indexPath.row]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 28
        }
        else if message.imageUrl != nil{
            height = 120
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width :  width, height : height)
    }
    private func estimateFrameForText(text:String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string : text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    func observeMessages()
    {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        //Search for the messageId first with the logged in User Id
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            //search for all the messages(with messaged Id's) recieved by the logged in user
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
                guard let dictionary = snapshot.value as? [String :AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                
                /*message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String*/
                
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    if self.messages.count > 0 {
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                })
                
                
            }, withCancel: nil)
        }, withCancel: nil)
        
    }

    @objc func handleSendMessage()
    {
        
        let properties : [String :AnyObject] = ["text":inputTextField.text! as AnyObject]
        if let text = inputTextField.text{
                textAndImage = text.isEmpty
        }
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl : String,image : UIImage)
    {
        let properties : [String : AnyObject] = ["imageUrl": imageUrl as AnyObject,"imageWidth" : image.size.width as AnyObject,"imageHeight" : image.size.height as AnyObject]
        textAndImage = imageUrl.isEmpty
        sendMessageWithProperties(properties: properties)
       
    }
    
    private func sendMessageWithProperties(properties : [String : AnyObject])
    {
        if let isMessageContentEmpty = textAndImage {
        if(!isMessageContentEmpty){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp  = Int(Date().timeIntervalSince1970)
        
        var values : [String :AnyObject] = ["toId" : toId as AnyObject,"fromId" : fromId as AnyObject,"timeStamp":timeStamp as AnyObject]
        
        //append properties to dictionary on to values (When image is sent)
        properties.forEach ({ values[$0] = $1})
    
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId:1])
            
        }
        }
        }
        else{
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    var startingFrame : CGRect?
    var blackBackgroudView : UIView?
    var startingImageView : UIImageView?
    
    func performZoomInForStartingImageView(startingImageView : UIImageView)
    {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.clear
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            self.blackBackgroudView = UIView(frame : keyWindow.frame)
            self.blackBackgroudView?.backgroundColor = UIColor.black
            self.blackBackgroudView?.alpha = 0
            keyWindow.addSubview(self.blackBackgroudView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroudView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.height
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
     
    }
    
    @objc func handleZoomOut(tapGesture : UITapGestureRecognizer)
    {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroudView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed : Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
 
            
        }
    }
}
