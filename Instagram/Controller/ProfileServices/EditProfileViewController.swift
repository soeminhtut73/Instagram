//
//  EditProfileViewController.swift
//  Instagram
//
//  Created by S M H  on 07/04/2025.
//

import UIKit
import SDWebImage

protocol ProfileUpdateDelegate {
    func didUpdateProfile(_ controller: EditProfileViewController, _ newImageUrl: String, _ username: String)
}

class EditProfileViewController : UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    private var profileImage: UIImage?
    
    var delegate: ProfileUpdateDelegate?
    
    private lazy var profileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo_white"), for: .normal)
        button.tintColor = .label
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.preferredSymbolConfiguration = .init(pointSize: 32, weight: .medium)
        button.addTarget(self, action: #selector(handleProfileImageButtonTap), for: .touchUpInside)
        return button
    }()
    
    private var usernameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Username")
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1.0
        tf.textColor = .label
        return tf
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBarButton()
        configureUI()
        configureData()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - HelperFunctions
    
    func configureData() {
        profileImageButton.setImage(nil, for: .normal)
        profileImageButton.sd_setBackgroundImage(with: URL(string: user.profileImageUrl), for: .normal)
        
        usernameTextField.text = user.username
    }
    
    func configureBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
    }
    
    func configureUI() {
        
        view.addSubview(profileImageButton)
        profileImageButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: 140, height: 140)
        profileImageButton.layer.cornerRadius = 140 / 2
        profileImageButton.centerX(inView: view)
        
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: profileImageButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 32)
        
    }
    
    
    //MARK: - Selector
    
    @objc func handleSave() {
        
        let newUsername = usernameTextField.text
        let newProfileImage = profileImage
        
        let isUsernameChanged = newUsername != user.username
        let isProfileImageChanged = newProfileImage != nil ? true : false
        
        func completeUpdate(profileImageURL: String? = nil) {
            UserServices.updateUserProfile(for: user, username: isUsernameChanged ? newUsername : nil, profileImageURL: profileImageURL) { error in
                print("Debug: profile update completed!")
                
                self.delegate?.didUpdateProfile(self, profileImageURL ?? self.user.profileImageUrl, newUsername ?? self.user.username)
                
                self.showLoader(false)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if isUsernameChanged || isProfileImageChanged {
            showLoader(true)
            
            if let newImage = newProfileImage, isProfileImageChanged {
                print("Debug: oldImageURL : \(user.profileImageUrl)")
                ImageUploader.uploadImage(image: newImage, oldImageURL: user.profileImageUrl, image_path: "profile_images") { imageURL in
                    print("Debug: newImageURL : \(imageURL)")
                    completeUpdate(profileImageURL: imageURL)
                }
            } else {
                completeUpdate()
            }
        }
    }
    
    @objc func handleProfileImageButtonTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = selectedImage
        
        profileImageButton.setImage(nil, for: .normal)
        profileImageButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}
