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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        checkUserFollowStatus()
        checkUserStats()
    }
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API Section
    
    /// check isFollowStatus and reload to display on following button
    func checkUserFollowStatus() {
        UserServices.checkUserFollowingStatus(uID: user.uid) { isFollow in
            self.user.isFollowed = isFollow
            self.collectionView.reloadData()
        }
    }
    
    func checkUserStats() {
        UserServices.fetchUserStats(uID: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - Helper Functions
    
    /// configure UI for collectionView and register for collecitonViewHeader
    func configureUI() {
        navigationItem.title = user.username
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
}

//MARK: - CollectionViewDataSources
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        
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
        
        // to edit profile
        if user.isCurrentUser {
            print("debug: to edit profile")
            
        // configure to unfollow on user tab button
        } else if user.isFollowed {
            
            UserServices.unfollowUsers(uID: user.uid) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
            
        // configure to follow on user tab
        } else {
            
            UserServices.followUsers(uID: user.uid) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.user.isFollowed = true
                self.collectionView.reloadData()
            }
        }
    }
}
