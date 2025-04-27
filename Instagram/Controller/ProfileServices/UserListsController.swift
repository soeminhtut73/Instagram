//
//  UserLists.swift
//  Instagram
//
//  Created by S M H  on 23/03/2025.
//

import UIKit
import SkeletonView

private let reuseIdentifier = "UserCell"

class UserListsController: UIViewController {
    
    //MARK: - Properties
    
    var user : User? {
        didSet{
            fetchUsers()
            configureUI()
        }
    }
    
    private var users = [User]() {
        didSet {
//            tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            tableView.reloadData()
        }
    }
    
    private var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 64
        tableView.estimatedRowHeight = 64
        return tableView
    }()
    
    var type: buttonType?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.isSkeletonable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.showAnimatedSkeleton()
//        tableView.showSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.25))
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
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: view.topAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(UserListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
    }
    
    
    //MARK: - Selectors
    
}

//MARK: - UITableView DataSource

extension UserListsController: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return reuseIdentifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserListTableViewCell
        
        guard let type = type else { return cell }
        
        cell.type = type
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
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
