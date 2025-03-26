//
//  UploadPostController.swift
//  Instagram
//
//  Created by S M H  on 11/01/2025.
//

import UIKit

protocol UploadPostControllerDelegate: AnyObject {
    func didUploadPost(_ controller: UploadPostController)
}

class UploadPostController : UIViewController {
    
    //MARK: - Properties
    
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            postImage.image = selectedImage
        }
    }
    
    var user : User?
    
    weak var delegate: UploadPostControllerDelegate?
    
    private let postImage: UIImageView = {
        let postImage           = UIImageView()
        postImage.contentMode   = .scaleAspectFill
        postImage.clipsToBounds = true
        return postImage
    }()
    
    private let captionText: UITextView = {
        let captionText = CustomTextView()
        captionText.placeholderText             = "Share your thoughts..."
        captionText.font                        = .systemFont(ofSize: 15)
        captionText.textColor                   = .label
        captionText.placeholderShouldCenterY    = false
        return captionText
    }()
    
    private let characterCount: UILabel = {
        let label               = UILabel()
        label.font              = .systemFont(ofSize: 16)
        label.textColor         = .secondaryLabel
        label.textAlignment     = .center
        label.text              = "0/100"
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
    
    @objc func didTapSaveButton() {
        
        guard let image = postImage.image else { return }
        
        guard let user = user else { return }
        
        showLoader(true)
        
        PostServices.uploadPost(user: user, image: image, caption: captionText.text) { error in
            
            self.showLoader(false)
            
            if let error = error {
                print("Debug: Error uploading post : \(error.localizedDescription)")
                return
            }
            self.delegate?.didUploadPost(self)
        }
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        
        navigationItem.title = "Upload Post"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancleButton))
        
        view.addSubview(postImage)
        postImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: 12)
        postImage.setDimensions(height: 180, width: 180)
        postImage.centerX(inView: view)
        postImage.layer.cornerRadius = 10
        postImage.clipsToBounds = true
        
        view.addSubview(captionText)
        captionText.delegate = self
        captionText.anchor(top: postImage.bottomAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        paddingTop: 16,
                        paddingLeft: 12,
                        paddingRight: 12,
                        height: 64)
        
        view.addSubview(characterCount)
        characterCount.anchor(top: captionText.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingRight: 12)
    }
    
    func checkCharacterMaxLength(_ captionText: UITextView) {
        if captionText.text.count > 100 {
            captionText.deleteBackward()
        }
    }
}

extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ captionText: UITextView) {
        characterCount.text = "\(captionText.text.count)/100"
        checkCharacterMaxLength(captionText)
    }
}
