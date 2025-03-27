//
//  UserLists.swift
//  Instagram
//
//  Created by S M H  on 23/03/2025.
//

import UIKit

private let reuseIdentifier = "UserCell"

class UserListsController: UITableViewController {
    
    //MARK: - Properties
    
    var user : User? {
        didSet{
//            fetchUsers()
        }
    }
    
    private var users = [User]() {
        didSet {
//            tableView.reloadData()
        }
    }
    
    var type: buttonType?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
//        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Loop through visible cells and show skeleton on specific subviews
        for cell in tableView.visibleCells {
            if let customCell = cell as? UserListTableViewCell {
                customCell.profileImageView.showSkeletonAnimation()
                customCell.usernameLabel.showSkeletonAnimation()
                customCell.followButton.showSkeletonAnimation()
            }
        }
        
        fetchUsers()
        
        // Simulate data loading delay (e.g., API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
            // Remove skeleton animations after data is loaded
            for cell in self.tableView.visibleCells {
                if let customCell = cell as? UserListTableViewCell {
                    customCell.profileImageView.hideSkeletonAnimation()
                    customCell.usernameLabel.hideSkeletonAnimation()
                    customCell.followButton.hideSkeletonAnimation()
                }
            }
        }
    }
    
    //MARK: - Helper Functions
    
    func fetchUsers() {
        guard let user = user else { return }
        
        if type == .followers {
            UserServices.fetchFollowerUsers(withUser: user.uid) { users in
                self.users = users
                self.checkUserIsFollow()
            }
        } else {
            UserServices.fetchFollowingUsers(withUser: user.uid) { users in
                self.users = users
            }
        }
    }
    
    func checkUserIsFollow() {
        users.forEach { user in
            
            UserServices.checkUserFollowingStatus(uID: user.uid) { isFollow in
                
                if let index = self.users.firstIndex(where: { $0.uid == user.uid }) {
                    self.users[index].isFollowed = isFollow
                }
            }
        }
    }
    
    func configureUI() {
        navigationItem.title = type?.buttonText
        view.backgroundColor = .systemBackground
        
        tableView.register(UserListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
        tableView.separatorStyle = .none
    }
    
    
    //MARK: - Selectors
    
}

//MARK: - UITableView DataSource

extension UserListsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.isEmpty ? 1 : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserListTableViewCell
        
        if users.isEmpty {
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            guard let type = type else { return cell }
            
            cell.type = type
            cell.user = users[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

//MARK: - UITableView Delegate

extension UserListsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
