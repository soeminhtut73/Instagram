//
//  NotificationController.swift
//  Instagram
//
//  Created by S M H  on 08/12/2024.
//

import UIKit

private let reuseIdentifier = "NotificationTableViewCell"

class NotificationController: UITableViewController {
    
    //MARK: - Properties
    
    private var viewModels = [NotificationViewModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let refresher = UIRefreshControl()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        fetchData()
    }
    
    //MARK: - API Calling
    
//    func fetchData() {
//        NotificationServices.fetchUserNotification { notificationViewModel in
//            self.viewModels = notificationViewModel
//        }
//    }
    
    func fetchData() {
        NotificationServices.fetchNoti { notiViewModels in
            self.viewModels = notiViewModels
            self.checkUserIsFollow()
        }
    }
    
    func checkUserIsFollow() {
        viewModels.forEach { viewModel in
            guard viewModel.notification.type == .follow else { return }
            
            UserServices.checkUserFollowingStatus(uID: viewModel.user.uid) { isFollow in
                
                if let index = self.viewModels.firstIndex(where: { $0.notification.id == viewModel.notification.id }) {
                    self.viewModels[index].isFollow = isFollow
                }
            }
        }
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        navigationItem.title = "Notifications"
        view.backgroundColor = .systemBackground
        
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 65
        tableView.separatorStyle = .none
    }
    
    @objc func refreshData() {
        viewModels.removeAll()
        fetchData()
        refresher.endRefreshing()
    }
}

//MARK: - UITableView DataSource

extension NotificationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationTableViewCell
        
        cell.viewModel = viewModels[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

//MARK: - UITableView Delegate

extension NotificationController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModels[indexPath.row].user
        let vc = ProfileController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - NotificationTableViewCellDelegate

extension NotificationController: NotificationTableViewCellDelegate {
   
    func didTapFollowButton(_ cell: NotificationTableViewCell, toUserId userId: String) {
        cell.viewModel?.isFollow.toggle()
        
        UserServices.followUsers(uID: userId) { _ in
            print("Debug: followUser on notification cell.")
        }
    }
    
    func didTapUnfollowButton(_ cell: NotificationTableViewCell, toUserId userId: String) {
        cell.viewModel?.isFollow.toggle()
        
        UserServices.unfollowUsers(uID: userId) { _ in
            print("Debug: unFollowUser on notification cell.")
        }
    }
    
    func didTapPostImage(_ cell: NotificationTableViewCell, toPostId postId: String) {
        
        PostServices.fetchSinglePost(with: postId) { post in
            let vc = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            vc.post = post
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
