//
//  ProfileCell.swift
//  Instagram
//
//  Created by S M H  on 22/12/2024.
//

import UIKit
import SDWebImage

class ProfileCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configurePostData()
        }
    }
    
    //MARK: - Lifecycle
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "venom-7")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.fillSuperview() 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - HelperFunction

    func configurePostData() {
        guard let viewModel = viewModel else { return }
        
        imageView.sd_setImage(with: viewModel.imageURL)
    }
}
