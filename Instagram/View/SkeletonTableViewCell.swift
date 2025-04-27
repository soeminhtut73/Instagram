import UIKit
import SkeletonView

class SkeletonTableViewCell: UITableViewCell {
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isSkeletonable = true
        return imageView
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.isSkeletonable = true
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        button.isSkeletonable = true
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        contentView.addSubview(profileImageView)
        profileImageView.setDimensions(height: 45, width: 45)
        profileImageView.layer.cornerRadius = 45 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        contentView.addSubview(usernameLabel)
        usernameLabel.centerY(inView: self)
        usernameLabel.setDimensions(height: 40, width: 200)
        usernameLabel.layer.cornerRadius = 20
        usernameLabel.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.layer.cornerRadius = 14
        followButton.anchor(right: rightAnchor, paddingRight: 8, width: 80, height: 28)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
