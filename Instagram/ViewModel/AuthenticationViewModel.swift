//
//  AuthenticationViewModel.swift
//  Instagram
//
//  Created by S M H  on 15/12/2024.
//

import UIKit

protocol UpdateFormButton {
    func updateFormButton()
}

protocol AuthenticationViewModel {
    var isValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    
    var isValid: Bool {
        guard let email, let password else { return false }
        return !email.isEmpty && !password.isEmpty
    }
    
    var buttonBackgroundColor: UIColor {
        isValid ? UIColor.systemPurple.withAlphaComponent(0.7) : UIColor.systemPurple.withAlphaComponent(0.3)
    }
}

struct RegisterationViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var isValid: Bool {
        guard let email, let password, let fullname, let username else { return false }
        return !email.isEmpty && !password.isEmpty && !fullname.isEmpty && !username.isEmpty
    }
    
    var buttonBackgroundColor: UIColor {
        isValid ? UIColor.systemPurple.withAlphaComponent(0.7) : UIColor.systemPurple.withAlphaComponent(0.3)
    }
    
}
