//
//  LoginController.swift
//  Instagram
//
//  Created by S M H  on 12/12/2024.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func didAuthenticate()
}

class LoginController: UIViewController {
    
    //MARK: - Properties
    
    private var loginViewModel = LoginViewModel()
    
    weak var delegate: AuthenticationDelegate?
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Instagram_logo_white")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Email")
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Password")
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.attributedTitle(firstPart: "Forgot your password?", secondPart: "Reset Here.")
        button.addTarget(self, action: #selector(handleForgotPasswordButtoon), for: .touchUpInside)
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign Up.")
        button.addTarget(self, action: #selector(handleCreateAccountButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTextFieldChangedAlert()
    }
    
    //MARK: - Selectors
    
    @objc func handleLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        DispatchQueue.main.async {
            AuthServices.logUserIn(email: email, password: password) { result, error in
                if let error = error {
                    print("Debug: Error logging user in: \(error.localizedDescription)")
                }
                
                print("Debug: User Login Successful!")
                self.delegate?.didAuthenticate()
            }
        }
    }
    
    @objc func handleCreateAccountButton() {
        let controller = RegisterationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleForgotPasswordButtoon() {
        print("Forgot password button.")
    }
    
    @objc func textDidChange(sender: UITextField) {
        
        if sender == emailTextField {
            loginViewModel.email = sender.text
        } else if sender == passwordTextField {
            loginViewModel.password = sender.text
        }
        
        updateFormButton()
    }
    
    //MARK: - helperFunctions
    
    func configureUI() {
        /// configure gradientBackground
        configureGradientLayer()
        
        /// configure navigationBar
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        /// configure Brand Logo Header
        view.addSubview(iconImageView)
        iconImageView.centerX(inView: view)
        iconImageView.setDimensions(height: 150, width: 210 )
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        /// configure stackView for email, password, login btn, create new account btn
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(createAccountButton)
        createAccountButton.centerX(inView: view)
        createAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureTextFieldChangedAlert() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

//MARK: - UpdateFormButton Protocol

extension LoginController: UpdateFormButton {
    func updateFormButton() {
        loginButton.isEnabled = loginViewModel.isValid
        loginButton.backgroundColor = loginViewModel.buttonBackgroundColor
    }
}
