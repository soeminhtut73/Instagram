//
//  ProfileHeaderCell.swift
//  Instagram
//
//  Created by S M H  on 22/12/2024.
//

import UIKit
import SDWebImage

protocol ProfileHeaderCellDelegate: AnyObject {
    func didTapEditProfileFollowButton(_ cell: ProfileHeaderCell, didTapButtonFor user: User)
    
    func didTapFollowerLabel(_ cell: ProfileHeaderCell, didTapButtonFor user: User, type: buttonType)
    
    func didTapFollowingLabel(_ cell: ProfileHeaderCell, didTapButtonFor user: User, type: buttonType)
}

class ProfileHeaderCell: UICollectionReusableView {
    
    //MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            configureUserData()
        }
    }
    
    weak var delegate: ProfileHeaderCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(handleEditProfileFollowButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowerLabelTap))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowingLabelTap))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private var gripButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "grid"), for: .normal)
        return button
    }()
    
    private var listButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "list"), for: .normal)
//        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    private var ribbonButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon"), for: .normal)
//        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    private let topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let bottonDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// configure profileImageView UI
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 0, paddingLeft: 12)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80/2
        
        /// configure nameLable UI
        addSubview(nameLabel)
        nameLabel.centerX(inView: profileImageView)
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        
        /// configure editProfileFollowButton UI
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 24, paddingRight: 24)
        
        /// configure profileAttribute UI
        let stackView = UIStackView(arrangedSubviews: [postLabel, followerLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(left: profileImageView.rightAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12, height: 50)
        stackView.centerY(inView: profileImageView)
        
        /// configure buttonStackView
        let buttonStack = UIStackView(arrangedSubviews: [gripButton, listButton, ribbonButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        
        addSubview(buttonStack)
        buttonStack.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        
        /// top divider
        addSubview(topDivider)
        topDivider.anchor(left: leftAnchor, bottom: buttonStack.topAnchor, right: rightAnchor, height: 0.5)
        
        /// bottom divider
        addSubview(bottonDivider)
        bottonDivider.anchor(top: buttonStack.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    
    @objc func handleEditProfileFollowButton() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapEditProfileFollowButton(self, didTapButtonFor: viewModel.user)
    }
    
    @objc func handleFollowingLabelTap() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapFollowingLabel(self, didTapButtonFor: viewModel.user, type: .followings)
    }
    
    @objc func handleFollowerLabelTap() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapFollowerLabel(self, didTapButtonFor: viewModel.user, type: .followers)
    }
    
    //MARK: - HelperFunctions
    
    func configureUserData() {
        
        guard let viewModel = viewModel else { return }
        
        print("Debug: did call after tap")
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        nameLabel.text = viewModel.fullname
        
        editProfileFollowButton.setTitle(viewModel.followButtonTitle, for: .normal)
        editProfileFollowButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
        editProfileFollowButton.backgroundColor = viewModel.folowButtonBackgroundColor
        
        postLabel.attributedText = viewModel.numberOfPosts
        followerLabel.attributedText = viewModel.numberOfFollowers
        followingLabel.attributedText = viewModel.numberOfFollowings
    }
    
    func attributeStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: " \(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}

enum buttonType: String {
    case followings
    case followers
    
    var buttonText: String {
        switch self {
        case .followers: return "Followers"
        case .followings: return "Followings"
        }
    }
}
