//
//  CustomTextField.swift
//  Instagram
//
//  Created by S M H  on 14/12/2024.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        font = .systemFont(ofSize: 14)
        borderStyle = .none
        textColor = .label
        keyboardAppearance = .dark
//        backgroundColor = UIColor(white: 1, alpha: 0.1)
//        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor(white: 1, alpha: 0.5)])
        backgroundColor = .systemBackground
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.label])
        setHeight(50)
        layer.cornerRadius = 10
        leftViewMode = .always
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        autocorrectionType = .no
        autocapitalizationType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
