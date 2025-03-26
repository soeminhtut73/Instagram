//
//  ResetPasswordController.swift
//  Instagram
//
//  Created by S M H  on 15/03/2025.
//

import UIKit

protocol ResetPasswordControllerDelegate {
    func didTapResetPasswordButton(_ controller: ResetPasswordController)
}

class ResetPasswordController : UIViewController {
    
    //MARK: - Properties
    
    var delegate : ResetPasswordControllerDelegate?
    
    private var resetPasswordViewModel = ResetPasswordViewModel()
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Instagram_logo_white")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = CustomTextField(placeholder: "Email")
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)
        button.layer.cornerRadius = 10
        button.setHeight(50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleResetPasswordButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextFieldChange()
    }
    
    //MARK: - Helper Functions
    
    private func configureUI() {
        configureGradientLayer()
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        view.addSubview(iconImageView)
        iconImageView.centerX(inView: view)
        iconImageView.setDimensions(height: 150, width: 210 )
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, resetPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 32, paddingRight: 32)
    }
    
    private func configureTextFieldChange() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
    //MARK: - API
    
    
    //MARK: - Selector
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        
        if let email = sender.text {
            resetPasswordViewModel.email = email
        }
        
        updateFormButton()
    }
    
    @objc func handleResetPasswordButton() {
        guard let email = emailTextField.text else { return }
        
        showLoader(true)
        
        AuthServices.resetPassword(withEmail: email) { error in
            
            self.showLoader(false)
            
            if let error = error {
                self.showMessage(withTitle: "Error", message: "\(error.localizedDescription)")
            }
            
            self.delegate?.didTapResetPasswordButton(self)
        }
    }
}

extension ResetPasswordController : UpdateFormButton {
    func updateFormButton() {
        resetPasswordButton.isEnabled = resetPasswordViewModel.isValid
        resetPasswordButton.backgroundColor = resetPasswordViewModel.buttonBackgroundColor
    }
}
