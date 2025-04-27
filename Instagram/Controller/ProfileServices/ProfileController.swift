//
//  ImageController.swift
//  Instagram
//
//  Created by S M H  on 08/12/2024.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "Cell"
private let headerIdentifier = "ProfileHeaderCell"

/*
 -  init controller with user
 */

class ProfileController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var posts = [Post]()
    
    let refresher = UIRefreshControl()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        checkUserFollowStatus()
        checkUserStats()
        fetchPosts()
    }
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API Section
    
    // check isFollowStatus and reload to display on following button
    func checkUserFollowStatus() {
        UserServices.checkUserFollowingStatus(uID: user.uid) { isFollow in
            self.user.isFollowed = isFollow
            self.collectionView.reloadData()
        }
    }
    
    // check for user's posts, following and followers count
    func checkUserStats() {
        UserServices.fetchUserStats(uID: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // get post by user's ID
    func fetchPosts() {
        PostServices.fetchPostByUserID(user.uid) { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - Helper Functions
    
    // configure UI for collectionView and register for collecitonViewHeader
    func configureUI() {
        navigationItem.title = user.username
        collectionView.backgroundColor = .white
        
//        refresher.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
//        collectionView.refreshControl = refresher
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    //MARK: - Selector
    @objc func refreshData() {
        
    }
    
}

//MARK: - CollectionViewDataSources

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        
        let viewModel = PostViewModel(post: posts[indexPath.item])
        cell.viewModel = viewModel
        
        return cell
    }
    
    /// create ProfileHeaderViewModel from user and passing to HeaderViewSection
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeaderCell
        header.delegate = self
        
        let viewModel = ProfileHeaderViewModel(user: user)
        header.viewModel = viewModel
        
        return header
    }
    
}


//MARK: - CollectionDelegate

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        
    }
}


//MARK: - CollectionViewFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let size = (collectionView.frame.width - 2) / 3
            return CGSize(width: size, height: size)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 240)
    }
}

//MARK: - ProfileHeaderCellDelegate

/// delegate function after taping button on ProfileHeader Section and
/// take action to api update #follow #unfollow #editProfile
extension ProfileController: ProfileHeaderCellDelegate {

    func didTapEditProfileFollowButton(_ cell: ProfileHeaderCell, didTapButtonFor user: User) {
        
//        guard let mainTab = tabBarController as? MainTabController else { return }
//        guard let currentUser = mainTab.user else { return }
        
        if user.isCurrentUser {  // to edit profile
            let vc = EditProfileViewController(user: user)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            
        } else if user.isFollowed {   // configure to unfollow on user tab button
            
            self.user.isFollowed = false
            let followers = user.stats?.followers ?? 0
            self.user.stats.followers = followers > 0 ? followers - 1 : 0
            
            UserServices.unfollowUsers(uID: user.uid) { error in
                self.collectionView.reloadData()
            }
            
        } else {   // configure to follow on user tab
            
            self.user.isFollowed = true
            self.user.stats?.followers += 1
            
            UserServices.followUsers(uID: user.uid) { error in
                /// save notification for user
                NotificationServices.uploadNotification(toUser: user, type: .follow)
                self.collectionView.reloadData()
            }
        }
    }
    
    func didTapFollowerLabel(_ cell: ProfileHeaderCell, didTapButtonFor user: User, type: buttonType) {
        let controller = UserListsController()
        controller.type = type
        controller.user = user
        
        navigationController?.pushViewController(controller, animated: true)
//        navigationController?.pushViewController(SkeletonViewController(), animated: true)
    }
    
    func didTapFollowingLabel(_ cell: ProfileHeaderCell, didTapButtonFor user: User, type: buttonType) {
        let controller = UserListsController()
        controller.type = type
        controller.user = user
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - EditProfileViewControllerDelegate

extension ProfileController: ProfileUpdateDelegate {
    
    func didUpdateProfile(_ controller: EditProfileViewController, _ newImageUrl: String, _ newUsername: String) {
        user.profileImageUrl = newImageUrl
        user.username = newUsername
        configureUI()
        collectionView.reloadData()
    }
    
    
}
