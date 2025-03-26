//
//  CommentController.swift
//  Instagram
//
//  Created by S M H  on 21/01/20  25.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentController: UICollectionViewController {
    
    //MARK: - Properties
    
    private let post: Post
    
    private var comments = [Comment]()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let size = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let view = CommentInputAccessoryView(frame: size)
        view.delegate = self
        return view
    }()
    
    //MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        fetchComments()
    }
    
    // #set the inputAccessoryView to commentInputView
    override var inputAccessoryView: UIView? {
        return commentInputView
    }
    
    // #set the becomeFirstResponder to commentInputView
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Helper Functions
    
    func configureCollectionView() {
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // bounce the view even smaller than view.bounds
        // dismiss the keyboard interactive with scroll
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    //MARK: - API
    
    func fetchComments() {
        CommentServices.fetchComments(with: post.postID) { comments in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - Selector
    
    
}

//MARK: - CollectionView DataSource

extension CommentController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        
        return cell
    }
}

//MARK: - CollectionView Delegate

extension CommentController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comment = comments[indexPath.row]
        let userID = comment.uid
        
        UserServices.getUser(uid: userID) { user in
            let vc = ProfileController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - CollectionViewDelegateFlowLayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    
    // set the cell custom height base on commentText count
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height + 32
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
}

//MARK: - CommentInputAccessoryViewDelegate

extension CommentController: CommentInputAccessoryViewDelegate {
    
    func didTapPostButton(_ inputView: CommentInputAccessoryView, with commentText: String) {
        print("Debug: commentText : \(commentText)")
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        showLoader(true)
        
        CommentServices.uploadComments(comment: commentText, postID: post.postID, user: user) { error in
            
            self.showLoader(false)
            
            /// add notification for postOwner
            NotificationServices.uploadNotification(toUid: self.post.ownerID, type: .comment, post: self.post)
            
            print("Debug: uploadComments success!")
        }
        
        inputView.clearTextView()
    }
}
