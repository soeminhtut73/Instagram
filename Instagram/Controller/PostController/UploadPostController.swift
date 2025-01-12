//
//  UploadPostController.swift
//  Instagram
//
//  Created by S M H  on 11/01/2025.
//

import UIKit

class UploadPostController : UIViewController {
    
    //MARK: - Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "venom-7")
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = CustomTextView()
        textView.placeholderText = "Share your thoughts..."
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        return textView
    }()
    
    private let characterCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "0/100"
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureUI()
    }
    
    
    //MARK: - Selector
    
    @objc func didTapCancleButton() {
        dismiss(animated: true)
    }
    
    @objc func didTapShareButton() {
        print("debug: didTapShareButton")
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        
        navigationItem.title = "Upload Post"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapShareButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancleButton))
        
        view.addSubview(imageView)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: 12)
        imageView.setDimensions(height: 180, width: 180)
        imageView.centerX(inView: view)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        view.addSubview(textView)
        textView.delegate = self
        textView.anchor(top: imageView.bottomAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        paddingTop: 16,
                        paddingLeft: 12,
                        paddingRight: 12,
                        height: 64)
        
        view.addSubview(characterCount)
        characterCount.anchor(top: textView.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingRight: 12)
    }
    
    func checkCharacterMaxLength(_ textView: UITextView) {
        if textView.text.count > 100 {
            textView.deleteBackward()
        }
    }
}

extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        characterCount.text = "\(textView.text.count)/100"
        checkCharacterMaxLength(textView)
    }
}
