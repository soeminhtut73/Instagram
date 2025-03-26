//
//  CommentInputAccessoryView.swift
//  Instagram
//
//  Created by S M H  on 25/01/2025.
//

import UIKit

protocol CommentInputAccessoryViewDelegate : AnyObject {
    func didTapPostButton(_ inputView : CommentInputAccessoryView,with commentText : String)
}

class CommentInputAccessoryView : UIView {
    
    //MARK: - Properties
    
    private let commentTextView : CustomTextView = {
        let textView = CustomTextView()
        textView.placeholderText = "Enter Comment..."
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .systemBackground
        textView.isScrollEnabled = false
        textView.placeholderShouldCenterY = false
        return textView
    }()
    
    private let postButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
        return button
    }()
    
    weak var delegate : CommentInputAccessoryViewDelegate?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        // adjust the CommentAccessoryView's Dimension to superView's Dimension
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(postButton)
        postButton.anchor(top: topAnchor, right: rightAnchor, paddingRight: 8)
        postButton.setDimensions(height: 50, width: 50)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: postButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8)
        
        let divider = UIView()
        divider.backgroundColor = .gray
        addSubview(divider)
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // prevent the view from superView constraint stretch
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //MARK: - Helper Functions
    
    func clearTextView(){
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
        
    }
    
    //MARK: - Selector
    
    @objc private func handlePostButton(){
        delegate?.didTapPostButton(self, with: commentTextView.text)
    }
}

/* # logic implementation CommentAccessoryView
 
    - create CommentAccessoryView custom view for comment input textView section
    - create accessoryView func in commentController.
    - ovveride the CommentAccessoryView in inputAccessoryView
    - ovveride the canBecomeFirstResponder to true
    
    - ovveride intrinsicContentSize to zero to still remain the original size in superView
 
 */
