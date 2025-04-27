
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
        }
    }
    
    private var following = [User]() {
        didSet{
            
        }
    }
    
    private var followers = [User]() {
        didSet{
            
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
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Followers", "Following"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let gridView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let listView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen // Just for demo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    var type: buttonType?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupSegmentControl()
        setupPanGesture()
        tableView.isSkeletonable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.showAnimatedSkeleton()
//        tableView.showSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.25))
    }
    
    
    //MARK: - Helper Functions
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func setupSegmentControl() {
        navigationItem.titleView = segmentControl
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    func fetchUsers() {
        guard let user = user else { return }
        
        if type == .followers {
            UserServices.fetchFollowerUsers(withUser: user.uid) { users in
                self.users = users
                self.checkUserIsFollow()
                self.tableView.hideSkeleton()
            }
        } else {
            UserServices.fetchFollowingUsers(withUser: user.uid) { users in
                self.users = users
                self.tableView.hideSkeleton()
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
    
    private func configureUI() {
        
        view.addSubview(gridView)
        view.addSubview(listView)
        
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            listView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 16),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        gridView.addSubview(tableView)
        NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: gridView.topAnchor),
                    tableView.bottomAnchor.constraint(equalTo: gridView.bottomAnchor),
                    tableView.leadingAnchor.constraint(equalTo: gridView.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: gridView.trailingAnchor)
        ])

        tableView.register(UserListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self

        tableView.separatorStyle = .none
    }
    
    
    //MARK: - Selectors
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Determine current and next views
        let isGridSelected = segmentControl.selectedSegmentIndex == 0
        let currentView = isGridSelected ? gridView : listView
        let nextView = isGridSelected ? listView : gridView
        
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
                    self.segmentControl.selectedSegmentIndex = isGridSelected ? 1 : 0
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
        let isGridSelected = sender.selectedSegmentIndex == 0 // grip = true | list = false
        
        let fromView = isGridSelected ? listView : gridView
        let toView = isGridSelected ? gridView : listView
            
        // Bring new view to front
        view.bringSubviewToFront(toView)
        
        let width = view.frame.width
        let offset = isGridSelected ? -width : width
        
        // Move new view off screen
        toView.transform = CGAffineTransform(translationX: offset, y: 0)
        toView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            // Slide old view away
            fromView.transform = CGAffineTransform(translationX: -offset, y: 0)
            
            // Slide new view into place
            toView.transform = .identity
        }, completion: { _ in
            fromView.isHidden = true
            fromView.transform = .identity
        })
    }
    
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
