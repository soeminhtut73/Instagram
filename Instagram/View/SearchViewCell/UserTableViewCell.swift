//
//  UserCellTableViewCell.swift
//  Instagram
//
//  Created by S M H  on 29/12/2024.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            
            profileImageView.sd_setImage(with: URL(string: user.profileImageUrl))
            usernameLabel.text = user.username
            fullname.text = user.fullName
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "venom-7")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 14)
//        label.text = "Eddie"
        return label
    }()
    
    private let fullname: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14)
//        label.text = "Black Ranger"
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, fullname])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
