//
//  FeedCell.swift
//  Instagram
//
//  Created by S M H  on 10/12/2024.
//

import UIKit
import FirebaseAuth
import SDWebImage

protocol FeedCellDelegate : AnyObject {
    func didTapPostImageView(_ cell: FeedCell, for postImage: UIImage)
    
    func didTapCommentButton(_ cell: FeedCell, for post: Post)
    
    func didTapLikeButton(_ cell: FeedCell, for post: Post)
    
    func didTapUsernameButton(_ cell: FeedCell, for uid: String)
    
    func didTapEditButton(_ cell: FeedCell, for post: Post)
    
    func didTapPlayButton(_ cell: FeedCell, for post: Post)
}

class FeedCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var postViewModel: PostViewModel? {
        didSet {
            configurePostViewModelData()
        }
    }
    
    weak var delegate : FeedCellDelegate?
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.addTarget(self, action: #selector (handleUsernameButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        let img = UIImage(systemName: "slider.horizontal.3")
        button.tintColor = .black
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(handleEditButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "venom-7")

        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePostImageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let img = UIImage(systemName: "play.fill")
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.setImage(img, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handlePayButtonPressed), for: .touchUpInside)
        return button
    }()
    
    public lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.addTarget(self, action: #selector (handleLikeButtonPressed), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    public lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.addTarget(self, action: #selector (handleCommentButtonPressed), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    public lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send2"), for: .normal)
        button.addTarget(self, action: #selector (handleShareButtonPressed), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    private var likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 13)
//        label.text = "12 likes"
        return label
    }()
    
    private var captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "Someone comment for this!"
        return label
    }()
    
    private var postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "2 days ago."
        return label
    }()
    
    //MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        /// set layout for profileImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,
                                left: leftAnchor,
                                paddingTop: 12,
                                paddingLeft: 12,
                                width: 40,
                                height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        /// set layout for username button
        addSubview(usernameButton)
        usernameButton.anchor(left: profileImageView.rightAnchor, paddingLeft: 12)
        usernameButton.centerY(inView: profileImageView)
        
        addSubview(editButton)
        editButton.setDimensions(height: 36, width: 36)
        editButton.anchor(right: rightAnchor, paddingRight: 10)
        editButton.centerY(inView: profileImageView)
        
        /// set layout for postImageView
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor,
                             left: leftAnchor,
                             paddingTop: 8)
        postImageView.centerX(inView: self)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        addSubview(playButton)
        playButton.setDimensions(height: 50, width: 50)
        playButton.centerX(inView: postImageView)
        playButton.centerY(inView: postImageView)
        
        /// set layout for buttons stackView
        configureStackView()
        
        /// set layout for likeLabel stackView
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor,
                          left: leftAnchor,
                          paddingTop: -4,
                          paddingLeft: 8)
        
        /// set layout for captionLabel stackView
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor,
                            left: leftAnchor,
                            paddingTop: 8,
                            paddingLeft: 8)
        
        /// set layout for postTimeLabel stackView
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor,
                             left: leftAnchor,
                             paddingTop: 8,
                             paddingLeft: 8)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    
    @objc func handlePostImageViewTapped() {
        guard let postImage = postImageView.image else { return }
        
        delegate?.didTapPostImageView(self, for: postImage)
    }
    
    @objc func handleUsernameButtonPressed() {
        guard let viewModel = postViewModel else { return }
        
        delegate?.didTapUsernameButton(self, for: viewModel.post.ownerID)
    }
    
    @objc func handleLikeButtonPressed() {
        guard let viewModel = postViewModel else { return }
        
        delegate?.didTapLikeButton(self, for: viewModel.post)
    }
    
    @objc func handleCommentButtonPressed() {
        guard let viewModel = postViewModel else { return }
        
        delegate?.didTapCommentButton(self, for: viewModel.post)
    }
    
    @objc func handleShareButtonPressed() {
        print("handleShareButtonPressed")
    }
    
    @objc func handleEditButtonPressed() {
        guard let viewModel = postViewModel else { return }
        
        delegate?.didTapEditButton(self, for: viewModel.post)
    }
    
    @objc func handlePayButtonPressed() {
        guard let viewModel = postViewModel else { return }
        
        delegate?.didTapPlayButton(self, for: viewModel.post)
    }
    
    //MARK: - Helper Functions
    
    func configureStackView() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, width: 120, height: 50)
    }
    
    // get the data from viewModel and implement in view
    func configurePostViewModelData() {
        guard let viewModel = postViewModel else { return }
        
        editButton.isHidden = viewModel.hideEditButton
        playButton.isHidden = viewModel.hidePlayButton
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        usernameButton.setTitle(viewModel.username, for: .normal)
        postImageView.sd_setImage(with: viewModel.imageURL)
        
        captionLabel.text = viewModel.caption
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        likesLabel.text = "\(viewModel.likeLabel)"
    }
}

