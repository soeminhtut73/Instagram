//
//  UserListTableViewCell.swift
//  Instagram
//
//  Created by S M H  on 23/03/2025.
//

import UIKit

protocol UserListTableViewCellDelegate: AnyObject {
    func didTapFollowButton(for cell: UserListTableViewCell, toUserId userId: String)
    func didTapUnfollowButton(for cell: UserListTableViewCell, toUserId userId: String)
}

class UserListTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    var user : User? {
        didSet {
            configureData()
        }
    }
    
    var type: buttonType?
    
    weak var delegate: UserListTableViewCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.text = "venom"
        return label
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3
        
        button.addTarget(self, action: #selector(handleFollowButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
            
        profileImageView.setDimensions(height: 45, width: 45)
        profileImageView.layer.cornerRadius = 45 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(usernameLabel)
        usernameLabel.centerY(inView: self)
        usernameLabel.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 8, width: 80, height: 28)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - HelperFunctions
    
    func configureData() {
        
        guard let user = user else { return }
        guard let type = type else { return }
        
        let viewModel = UserListViewModel(user: user, type: type)
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        usernameLabel.text = viewModel.username
        
        followButton.setTitle(viewModel.buttonTitle, for: .normal)
        followButton.backgroundColor = viewModel.buttonBackgroundColor
        followButton.setTitleColor(viewModel.buttonTextColor, for: .normal)
    }
    
    
    //MARK: - selector
    
    @objc func handleFollowButton() {
        guard let user = user else { return }
        
        if user.isFollowed {    // to unfollow
            delegate?.didTapUnfollowButton(for: self, toUserId: user.uid)
        } else {                // to follow
            delegate?.didTapFollowButton(for: self, toUserId: user.uid)
        }
    }
}
