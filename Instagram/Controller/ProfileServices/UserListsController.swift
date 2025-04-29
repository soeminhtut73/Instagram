
//
//  UserLists.swift
//  Instagram
//
//  Created by S M H  on 23/03/2025.
//

import UIKit
import SkeletonView

private let followingTableCell = "FollowingCell"
private let followerTableCell = "FollowerCell"

class UserListsController: UIViewController {
    
    //MARK: - Properties
    
    var user : User? {
        didSet{
            fetchUsers()
        }
    }
    
    private var following = [User]() {
        didSet{
            followingTableView.reloadData()
        }
    }
    
    private var followers = [User]() {
        didSet{
            followerTableView.reloadData()
        }
    }

    var selectedSegmentIndex: Int = 0
    
    private var followingTableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 64
        tableView.estimatedRowHeight = 64
        return tableView
    }()
    
    private var followerTableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 64
        tableView.estimatedRowHeight = 64
        return tableView
    }()
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Following", "Followers"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    var type: buttonType?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupSegmentControl()
        setupPanGesture()
//        tableView.isSkeletonable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.showAnimatedSkeleton()
//        tableView.showSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.25))
    }
    
    
    //MARK: - Helper Functions
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = selectedSegmentIndex
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        updateViewForSelectedSegment()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func updateViewForSelectedSegment() {
        if segmentControl.selectedSegmentIndex == 0 {
            followingTableView.isHidden = false
            followerTableView.isHidden = true
        } else {
            followingTableView.isHidden = true
            followerTableView.isHidden = false
        }
    }
    
    private func fetchUsers() {
        guard let user = user else { return }
        
        UserServices.fetchFollowingUsers(withUser: user.uid) { users in
            self.following = users
            
            users.forEach { user in
                UserServices.checkUserFollowingStatus(uID: user.uid) { isFollow in
                    if let index = self.following.firstIndex(where: { $0.uid == user.uid }) {
                        self.following[index].isFollowed = isFollow
                    }
                }
            }
        }
        
        UserServices.fetchFollowerUsers(withUser: user.uid) { users in
            self.followers = users
            
            users.forEach { user in
                UserServices.checkUserFollowingStatus(uID: user.uid) { isFollow in
                    if let index = self.followers.firstIndex(where: { $0.uid == user.uid }) {
                        self.followers[index].isFollowed = isFollow
                    }
                }
            }
        }
    }
    
    private func configureUI() {
        
        navigationItem.title = user?.username
        
        view.addSubview(segmentControl)
        segmentControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 12, width: view.frame.width/2)
        segmentControl.centerX(inView: view)
        
        
        
        view.addSubview(followingTableView)
        view.addSubview(followerTableView)
        
        followingTableView.anchor(top: segmentControl.safeAreaLayoutGuide.bottomAnchor,
                                  left: view.leftAnchor,
                                  bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  right: view.rightAnchor,
                                  paddingTop: 16)
        followingTableView.register(UserListTableViewCell.self, forCellReuseIdentifier: followingTableCell)
        followingTableView.dataSource = self
        followingTableView.separatorStyle = .none
        
        followerTableView.anchor(top: segmentControl.safeAreaLayoutGuide.bottomAnchor,
                                  left: view.leftAnchor,
                                  bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  right: view.rightAnchor,
                                  paddingTop: 16)
        followerTableView.register(UserListTableViewCell.self, forCellReuseIdentifier: followerTableCell)
        followerTableView.dataSource = self
        followerTableView.separatorStyle = .none
        
        followerTableView.isHidden = true
        
    }
    
    
    //MARK: - Selectors
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Determine current and next views
        let isFollowingTableViewSelected = segmentControl.selectedSegmentIndex == 0
        let currentView = isFollowingTableViewSelected ? followingTableView : followerTableView
        let nextView = isFollowingTableViewSelected ? followerTableView : followingTableView
        
        if gesture.state == .began {
            // Prepare next view
            let direction: CGFloat = translation.x > 0 ? -1 : 1
            nextView.transform = CGAffineTransform(translationX: direction * view.frame.width, y: 0)
            nextView.isHidden = false
            view.bringSubviewToFront(currentView)
            view.bringSubviewToFront(nextView)
            
        } else if gesture.state == .changed {
            // Move both views together with the finger
            currentView.transform = CGAffineTransform(translationX: translation.x, y: 0)
            nextView.transform = CGAffineTransform(translationX: (translation.x > 0 ? -view.frame.width : view.frame.width) + translation.x, y: 0)
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Complete the transition based on swipe distance
            let velocity = gesture.velocity(in: view)
            let shouldSwitch = abs(translation.x) > view.frame.width / 3 || abs(velocity.x) > 500
            
            if shouldSwitch {
                let direction: CGFloat = translation.x > 0 ? 1 : -1
                UIView.animate(withDuration: 0.3, animations: {
                    currentView.transform = CGAffineTransform(translationX: direction * self.view.frame.width, y: 0)
                    nextView.transform = .identity
                }, completion: { _ in
                    currentView.isHidden = true
                    currentView.transform = .identity
                    self.segmentControl.selectedSegmentIndex = isFollowingTableViewSelected ? 1 : 0
                })
            } else {
                // Not enough swipe: return to original position
                UIView.animate(withDuration: 0.3) {
                    currentView.transform = .identity
                    nextView.transform = CGAffineTransform(translationX: translation.x > 0 ? -self.view.frame.width : self.view.frame.width, y: 0)
                } completion: { _ in
                    nextView.isHidden = true
                }
            }
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateViewForSelectedSegment()
    }
    
}

//MARK: - UITableView DataSource

extension UserListsController: UITableViewDataSource {
    
//    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//        return reuseIdentifier
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == followingTableView {
            return following.count
        } else {
            return followers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == followingTableView {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: followingTableCell, for: indexPath) as! UserListTableViewCell
            cell.type = .followings
            cell.user = following[indexPath.row]
            cell.delegate = self
            return cell
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: followerTableCell, for: indexPath) as! UserListTableViewCell
            cell.type = .followers
            cell.user = followers[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

//MARK: - UITableView Delegate

extension UserListsController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - UserListTableViewCellDelegate

extension UserListsController: UserListTableViewCellDelegate {
    
    func didTapFollowButton(for cell: UserListTableViewCell, toUserId userId: String) {
        
        cell.user?.isFollowed.toggle()
        
        UserServices.followUsers(uID: userId) { _ in
        }
    }
    
    func didTapUnfollowButton(for cell: UserListTableViewCell, toUserId userId: String) {
        
        cell.user?.isFollowed.toggle()
        
        UserServices.unfollowUsers(uID: userId) { _ in
        }
    }
}
