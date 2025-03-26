//
//  CustomTextView.swift
//  Instagram
//
//  Created by S M H  on 11/01/2025.
//

import UIKit

class CustomTextView: UITextView {
    
    //MARK: - Properties
    
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    var placeholderShouldCenterY : Bool = true {
        didSet {
            if placeholderShouldCenterY {
                
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
                
                placeholderLabel.centerY(inView: self)
                
            } else {
                
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 6.5, paddingLeft: 5, paddingRight: 5)
                
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
