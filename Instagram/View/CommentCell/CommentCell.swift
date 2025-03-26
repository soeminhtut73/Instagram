//
//  CommentCell.swift
//  Instagram
//
//  Created by S M H  on 22/01/2025.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel : CommentViewModel? {
        didSet {
            configureData()
        }
    }
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .darkGray
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private let commentLabel = UILabel()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40/2
        
        commentLabel.numberOfLines = 0
        addSubview(commentLabel)
        commentLabel.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        commentLabel.anchor(right: rightAnchor, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - HelperFunction
    
    func configureData() {
        guard let viewModel = viewModel else { return }
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        commentLabel.attributedText = viewModel.commentText()
    }
}
