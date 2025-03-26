//
//  NotificationTableViewCell.swift
//  Instagram
//
//  Created by S M H  on 22/02/2025.
//

import UIKit

protocol NotificationTableViewCellDelegate : AnyObject {
    
    func didTapFollowButton(_ cell: NotificationTableViewCell, toUserId userId: String)
    
    func didTapUnfollowButton(_ cell: NotificationTableViewCell, toUserId userId: String)
    
    func didTapPostImage(_ cell: NotificationTableViewCell, toPostId postId: String)
}

class NotificationTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel : NotificationViewModel? {
        didSet {
            configureData()
        }
    }
    
    weak var delegate : NotificationTableViewCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "venom-7")
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handlePostImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
        
        return imageView
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleFollowButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 45, width: 45)
        profileImageView.layer.cornerRadius = 45/2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        contentView.addSubview(postImageView)
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 8, width: 40, height: 40)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 8, width: 80, height: 28)
        
        addSubview(infoLabel)
        infoLabel.centerY(inView: profileImageView)
        infoLabel.anchor(left: profileImageView.rightAnchor, right: followButton.leftAnchor, paddingLeft: 8, paddingRight: 8)
        
//        followButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    
    func configureData() {
        guard let viewModel = viewModel else { return }
        
        postImageView.isHidden = viewModel.shouldHidePostImageButton
        followButton.isHidden = !viewModel.shouldHidePostImageButton
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        postImageView.sd_setImage(with: viewModel.postImageUrl)
        infoLabel.attributedLabel(firstPart: viewModel.username, secondPart: viewModel.labelText, timestamp: viewModel.timestampString)
        
        followButton.setTitle(viewModel.followButtonText, for: .normal)
        followButton.backgroundColor = viewModel.followButtonBackgroundColor
        followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
    }
    
    //MARK: - Selector
    
    @objc func handleFollowButtonTapped() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.isFollow {
            // need to unfollow
            delegate?.didTapUnfollowButton(self, toUserId: viewModel.user.uid)
        } else {
            // need to follow
            delegate?.didTapFollowButton(self, toUserId: viewModel.user.uid)
        }
    }
    
    @objc func handleUnfollowButtonTapped() {
        
    }
    
    @objc func handlePostImageViewTapped() {
        guard let postID = viewModel?.notification.postId else { return }
        
        delegate?.didTapPostImage(self, toPostId: postID)
    }
    
}
