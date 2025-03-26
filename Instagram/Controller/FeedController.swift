//
//  FeedController.swift
//  Instagram
//
//  Created by S M H  on 08/12/2024.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {
    
    //MARK: - Properties
    
    var posts = [Post]()
    
    var post : Post? {
        didSet {
            checkIfUserLikePost()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPosts()
    }
    
    //MARK: - API
    
    // fetchPost initialize
    func fetchPosts() {
        guard post == nil else { return }
        
        PostServices.fetchPostWithLastTimeSeen() { posts in
            self.posts = []
            self.posts = posts
            self.checkIfUserLikePosts()
        }
    }
    
    // check userDidLike on each post
    func checkIfUserLikePosts() {
        let group = DispatchGroup()
        
        self.posts.forEach { post in
            group.enter()
            
            PostServices.checkIfUserLikePost(with: post) { didLike in
                if let index = self.posts.firstIndex(where: { $0.postID == post.postID }) {
                    self.posts[index].didLike = didLike
                }
                group.leave()
            }
        }
        
        // Notify when all API calls are completed
        group.notify(queue: .main) {
            self.collectionView.reloadData()  // Reload data after all API calls complete
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikePost() {
        let group = DispatchGroup()
        group.enter()
        
        guard let post = post else { return }
        
        PostServices.checkIfUserLikePost(with: post) { didLike in
            self.post?.didLike = didLike
            group.leave()
        }
        
        // Notify when all API calls are completed
        group.notify(queue: .main) {
            self.collectionView.reloadData()  // Reload data after all API calls complete
            
        }
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        
        navigationItem.title = "Feed"
        
        collectionView.backgroundColor = .white
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if post == nil {
            let barButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            barButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),
                                              .foregroundColor: UIColor.black], for: .normal)
            
            navigationItem.leftBarButtonItem = barButton
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        }
    }
    
    //MARK: - Selector
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
            UserDefaultManager.shared.clearUserData()
            
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        } catch {
            print("Debug: Error signing out")
        }
    }
    
    @objc func handleRefreshControl() {
        collectionView.refreshControl?.beginRefreshing()
        fetchPosts()
    }
}

//MARK: - UICollectionView Datasource

extension FeedController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        // for single view at the profileView
        if let post = post {
            cell.postViewModel = PostViewModel(post: post)
        } else {
            // for multiple view at th e main feedView
            cell.postViewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return cell
    }
}

//MARK: - UICollectionViewFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /// 8 for padding profileImageView, 40 for image, 8 for paddingBottom
        /// 50 for padding likeLabel section
        /// 60 for comment section
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        
        return CGSize(width: width, height: height)
    }
}

//MARK: - FeedCell Delegate

extension FeedController: FeedCellDelegate {
    
    func didTapUsernameButton(_ cell: FeedCell, for uid: String) {
        UserServices.getUser(uid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapLikeButton(_ cell: FeedCell, for post: Post) {
        
        cell.postViewModel?.post.didLike.toggle()
        
        if post.didLike {
            
            // didLike true, proceed to unlike a post
            print("Debug: proceed to unlike.")
            
            cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            cell.likeButton.tintColor = .black
            
            PostServices.unlikePost(with: post) { error in
                if let error = error {
                    print("Debug: Error unlike post : \(error.localizedDescription)")
                }
            }
            
        } else {
            
            // didLike false, proceed to like a post
            cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            cell.likeButton.tintColor = .red
            
            PostServices.likePost(with: post) { error in
                if let error = error {
                    print("Debug: Error like post : \(error.localizedDescription)")
                }
                
                NotificationServices.uploadNotification(toUid: post.ownerID, type: .like, post: post)
            }
        }
    }
    
    func didTapCommentButton(_ cell: FeedCell, for post: Post) {
        
        let vc = CommentController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
