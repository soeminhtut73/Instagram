//
//  FeedController.swift
//  Instagram
//
//  Created by S M H  on 08/12/2024.
//

import UIKit
import FirebaseAuth
import UserNotifications
import AVKit
import AVFoundation

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {
    
    //MARK: - Properties
    
    var posts = [Post]()
    
    var panGesture: UIGestureRecognizer?
    
    var scrollView: UIScrollView?
    
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
    
    /// present full image for imageCell got tap
    /// - Parameter image: for select image passing
    func presentFullScreenImage(_ image: UIImage) {
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let backgroundView = UIView(frame: window.bounds)
            backgroundView.backgroundColor = .black
            backgroundView.layer.cornerRadius = 44
            backgroundView.alpha = 0
            window.addSubview(backgroundView)
            
            let scrollView = UIScrollView(frame: backgroundView.bounds)
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 3.0
            scrollView.delegate = self
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = scrollView.bounds
            imageView.isUserInteractionEnabled = true
            scrollView.addSubview(imageView)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            scrollView.addGestureRecognizer(doubleTap)

            self.scrollView = scrollView
            
            backgroundView.addSubview(scrollView)
            window.addSubview(backgroundView)
            
            UIView.animate(withDuration: 0.3) {
                backgroundView.alpha = 1
            }
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanToDismiss(_:)))
            imageView.addGestureRecognizer(panGesture)
            self.panGesture = panGesture
            
            backgroundView.tag = 999
        }
    }
    
    func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Present the video player
        DispatchQueue.main.async {
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    //MARK: - Selector & Handler
    
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
    
    @objc func handlePanToDismiss(_ gesture: UIPanGestureRecognizer) {
        
        guard scrollView?.zoomScale == 1 else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let backgroundView = window.viewWithTag(999) else { return }
        
        let translation = gesture.translation(in: window)
        let absX = abs(translation.x)
        let absY = abs(translation.y)
        
        let percentX = absX / window.bounds.width
        let percentY = absY / window.bounds.height
        
        switch gesture.state {
        case .changed:
            // Move image with the pan gesture
            backgroundView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            
            // Fade based on the greater of X or Y movement
            let fadeFactor = max(percentX, percentY)
            backgroundView.alpha = 1 - fadeFactor
            
        case .ended, .cancelled:
            if percentX > 0.1 || percentY > 0.1 {
                UIView.animate(withDuration: 0.25, animations: {
                    let x = translation.x != 0 ? translation.x * 3 : 0
                    let y = translation.y != 0 ? translation.y * 3 : 0
                    backgroundView.transform = CGAffineTransform(translationX: x, y: y)
                    backgroundView.alpha = 0
                }) { _ in
                    backgroundView.removeFromSuperview()
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    backgroundView.transform = .identity
                    backgroundView.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    @objc func handleRefreshControl() {
        collectionView.refreshControl?.beginRefreshing()
        fetchPosts()
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let scrollView = gesture.view as! UIScrollView
        
        if scrollView.zoomScale == 1 {
            // Zoom in to tapped point
            let pointInView = gesture.location(in: scrollView.subviews.first!)
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale, center: pointInView, scrollView: scrollView)
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            // Zoom out to original scale
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView) -> CGRect {
        let size = scrollView.bounds.size
        let width = size.width / scale
        let height = size.height / scale
        let originX = center.x - (width / 2)
        let originY = center.y - (height / 2)
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private func handleEdit() {
        guard let post = post else { return }
        let vc = EditPostController(post: post)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleDelete() {
        print("Debug: Delete tapped")
        // to add delete logic here
    }
}

//MARK: - EditPostController Delegate

extension FeedController: PostUpdateDelegate {
    func didUpdatePost(_ controller: EditPostController, _ postImageUrl: String, _ caption: String) {
        self.post?.caption = caption
        self.post?.imageURL = postImageUrl
        self.configureUI()
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
    
    func didTapPlayButton(_ cell: FeedCell, for post: Post) {
        
        guard let videoURL = post.videoURL else { return }
        
        playVideo(from: URL(string: videoURL)!)
    }
    
    func didTapPostImageView(_ cell: FeedCell, for postImage: UIImage) {
        presentFullScreenImage(postImage)
    }
    
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
    
    func didTapEditButton(_ cell: FeedCell, for post: Post) {
        let actionSheet = UIAlertController(title: nil, message: "Choose Options", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.handleEdit()
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.handleDelete()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
}

//MARK: - UIScrollViewDelegate

extension FeedController {
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    override func scrollViewDidZoom(_ scrollView: UIScrollView) {
            if scrollView.zoomScale > 1 {
                panGesture?.isEnabled = false
            } else {
                panGesture?.isEnabled = true
            }
        }
}

/*
 
 
 */
