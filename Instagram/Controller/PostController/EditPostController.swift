//
//  UpdatePostController.swift
//  Instagram
//
//  Created by S M H  on 11/04/2025.
//

import UIKit
import SDWebImage

protocol PostUpdateDelegate {
    func didUpdatePost(_ controller: EditPostController, _ postImageUrl: String, _ caption: String)
}

class EditPostController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    var post: Post
    var newPostImage: UIImage?
    var originalText: String = ""
    
    var delegate: PostUpdateDelegate?
    
    private lazy var postImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostImageTap)))
        return image
    }()
    
    private var captionTextView: UITextView = {
        let textView = CustomTextView()
        textView.textColor = .label
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.placeholderShouldCenterY = false
        return textView
    }()
    
    private var charaterCount: UILabel = {
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
        configureData()
    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Handler & Selectors
    
    @objc func didTapCancleButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSaveButton() {
        let newPostImage = newPostImage
        let newCaptionText = captionTextView.text
        
        let isPostImageChange = newPostImage != nil ? true : false
        let isNewCaptionTextChange = newCaptionText != originalText
        
        func completeUpdate(imageURL: String? = nil) {
            PostServices.updatePost(forPost: post.postID, newPostImageURL: imageURL, newCaption: isNewCaptionTextChange ? newCaptionText : nil) { error in
                print("Debug: profile update completed!")
                
                self.delegate?.didUpdatePost(self, imageURL ?? self.post.imageURL, newCaptionText ?? self.post.caption)
                
                self.showLoader(false)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if isPostImageChange || isNewCaptionTextChange {
            showLoader(true)
            
            if let newPostImage, isPostImageChange {
                ImageUploader.uploadImage(image: newPostImage, oldImageURL: post.imageURL, image_path: "post_images") { imageURL in
                    completeUpdate(imageURL: imageURL)
                }
            } else {
                completeUpdate()
            }
        }
    }
    
    @objc func handlePostImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    //MARK: - HelperFunctions
    
    func configureUI() {
        navigationItem.title = "Edit Post"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancleButton))
        
        view.addSubview(postImage)
        postImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 14)
        postImage.setDimensions(height: 250, width: 250)
        postImage.centerX(inView: view)
        postImage.clipsToBounds = true
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: postImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingRight: 12, height: 64)
        
        view.addSubview(charaterCount)
        charaterCount.anchor(top: captionTextView.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingRight: 12)
    }
    
    func configureData() {
        let url = URL(string: post.imageURL)
        postImage.sd_setImage(with: url)
        captionTextView.text = post.caption
        originalText = post.caption
        
    }
    
    func checkCharacterMaxLength(_ captionText: UITextView) {
        if captionText.text.count > 100 {
            captionText.deleteBackward()
        }
    }
}

//MARK: - UITextViewDelegate

extension EditPostController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        charaterCount.text = "\(textView.text.count)/100"
        checkCharacterMaxLength(textView)
    }
}

//MARK: - UIImagePickerDelegate

extension EditPostController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.newPostImage = selectedImage
        
        postImage.image = nil
        postImage.image = selectedImage.withRenderingMode(.alwaysOriginal)
        
        dismiss(animated: true)
    }
}
