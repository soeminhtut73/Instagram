//
//  RegisterationController.swift
//  Instagram
//
//  Created by S M H  on 12/12/2024.
//

import UIKit

class RegisterationController: UIViewController {
    
    //MARK: - Properties
    
    private var registerationViewModel = RegisterationViewModel()
    private var profileImage: UIImage?
    
    weak var delegate: AuthenticationDelegate?
    
    lazy var uploadProfileImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_photo_white"), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleProfileImageUpload), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Email")
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Password")
        textField.returnKeyType = .next
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Fullname")
        textField.returnKeyType = .next
        return textField
    }()
    
    private let userNameTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Username")
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton()
        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Login In.")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTextFieldChangeALert()
    }
    
    //MARK: - Selector
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        guard let username = userNameTextField.text?.lowercased() else { return }
        guard let image = self.profileImage else { return }
        
        let authCrentials = AuthCredential(email: email, password: password, username: fullname, fullName: username, profileImage: image)
        
        AuthServices.registerUser(withCredential: authCrentials) { error in
            if let error = error {
                print("Debug: Fail to create user: \(error.localizedDescription)")
                return
            }
            
            self.delegate?.didAuthenticate()
            print("Debug: User resister successfully created!")
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleTextFieldChange(sender: UITextField) {
        
        if sender == emailTextField {
            registerationViewModel.email = sender.text
        } else if sender == passwordTextField {
            registerationViewModel.password = sender.text
        } else if sender == fullNameTextField {
            registerationViewModel.fullname = sender.text
        } else if sender == userNameTextField {
            registerationViewModel.username = sender.text
        }
        
        updateFormButton()
    }
    
    @objc func handleProfileImageUpload() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        configureGradientLayer()
        
        view.addSubview(uploadProfileImageButton)
        uploadProfileImageButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: 140, height: 140)
        uploadProfileImageButton.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, userNameTextField, fullNameTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: uploadProfileImageButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        stackView.centerX(inView: view)
        
        view.addSubview(alreadyHaveAnAccountButton)
        alreadyHaveAnAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAnAccountButton.centerX(inView: view)
    }
    
    func configureTextFieldChangeALert() {
        emailTextField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
    }
    
}

//MARK: - Update Form Model

extension RegisterationController: UpdateFormButton {
    func updateFormButton() {
        signUpButton.isEnabled = registerationViewModel.isValid
        signUpButton.backgroundColor = registerationViewModel.buttonBackgroundColor
    }
}

//MARK: - UIImagePickerDelegate

extension RegisterationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = selectedImage
        
        uploadProfileImageButton.layer.cornerRadius = uploadProfileImageButton.frame.height / 2
        uploadProfileImageButton.layer.borderColor = UIColor.black.cgColor
        uploadProfileImageButton.layer.borderWidth = 1
        uploadProfileImageButton.clipsToBounds = true
        uploadProfileImageButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}
