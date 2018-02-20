//
//  UserCell.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/18/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase

//Use the custom table view cell for displaying list of users
class UserCell: UITableViewCell {
    
    var message : Message? {
        didSet {
            
             setUpNameAndProfileImage()
             detailTextLabel?.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue
            {
                let date = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                self.timeStampLabel.text = dateFormatter.string(from: date)
            }
        }
    }
    
    private func setUpNameAndProfileImage()
    {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageView = dictionary["profileImageUrl"] as? String{
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageView)
                    }
                }
            }, withCancel: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeStampLabel : UILabel = {
        let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeStampLabel)
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //x,y,w,h
        timeStampLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
       //timeStampLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        timeStampLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeStampLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeStampLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
