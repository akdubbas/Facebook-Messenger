//
//  LoginViewController.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/4/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var messagesController: MessagesController?
    
    lazy var uploadPhoto : UIImageView = {
        let imageView  = UIImageView()
        imageView.image = UIImage(named : "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfilePicture)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
   
    
    lazy var loginRegisterSegmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items : ["Login", "Register"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = UIColor.white
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return control
    }()
    //InputviewContainer
    let inputsContainerView : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    return view
    }()
    
    //Register Button
    
     lazy var registerButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r : 80,g : 101,b : 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Name"
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    let emailTextField : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Email"
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    let passwordTextField : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Password"
        textfield.isSecureTextEntry = true
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    
    
    let nameSeperatorView : UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(r : 220,g : 220, b : 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeperatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r : 220,g : 220, b : 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor  = UIColor(r : 61,g : 91,b : 151)
        
        
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        view.addSubview(uploadPhoto)
        view.addSubview(loginRegisterSegmentedControl)
        
        
        setUpInputContainerView()
        setUpRegisterButtonContraints()
        setUpImageViewContraints()
        setUpSegementedControlContraints()
        
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setUpImageViewContraints()
    {
        uploadPhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uploadPhoto.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        uploadPhoto.widthAnchor.constraint(equalToConstant: 150).isActive = true
        uploadPhoto.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    
    func setUpSegementedControlContraints()
    {
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    var inputContainerHeightViewConstraint : NSLayoutConstraint?
    var nameTextFieldHeightViewConstraint  : NSLayoutConstraint?
    var emailTextFieldHeightViewConstraint : NSLayoutConstraint?
    var passwordTextFieldHeightViewConstraint : NSLayoutConstraint?
    
    func setUpInputContainerView()
    {
        //add x,y,width,height constraints
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerHeightViewConstraint = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightViewConstraint?.isActive = true
        
        //Add all Text fields to input container view and constraints
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        //Contraints for nameTextField
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightViewConstraint = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightViewConstraint?.isActive = true
        
        //Contraints for nameSeperatorView
        nameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //Contraints for emailTextField
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightViewConstraint = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightViewConstraint?.isActive = true
        
        //Contraints for emailSeperatorView
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Contraints for passwordTextField
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.topAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightViewConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightViewConstraint?.isActive = true
        
    }
    
    func setUpRegisterButtonContraints()
    {
        //add x,y,width,height constraints
        
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    @objc func handleLoginRegisterChange()
    {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        
        inputContainerHeightViewConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightViewConstraint?.isActive = false
        nameTextFieldHeightViewConstraint = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier : loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightViewConstraint?.isActive = true
        
        emailTextFieldHeightViewConstraint?.isActive = false
        emailTextFieldHeightViewConstraint = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightViewConstraint?.isActive = true
        
        passwordTextFieldHeightViewConstraint?.isActive = false
        passwordTextFieldHeightViewConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightViewConstraint?.isActive = true
    }
    
    @objc func handleLoginRegister()
    {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }
        else{
            handleRegister()
        }
    }
    
    func handleLogin()
    {
        guard var email = emailTextField.text,var password = passwordTextField.text else {
            print("Empty email and Password")
            return
        }
        email = "ab@gmail.com"
        password = "123456"
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user,error) in
            
            if(error != nil)
            {
                print("Invalid Login : Error \(error!)")
            }
           self.messagesController?.fetchUserAndSetUpNavBarTitle()
           self.dismiss(animated: true, completion: nil)

            
        })
    }
  
    
    

}

extension UIColor {
    
    convenience init(r : CGFloat,g : CGFloat,b : CGFloat) {
        self.init(red: r/255,green : g/255, blue : b/255, alpha : 1)
    }

}
