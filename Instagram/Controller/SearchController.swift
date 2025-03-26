//
//  SearchController.swift
//  Instagram
//
//  Created by S M H  on 08/12/2024.
//

import UIKit

private let reuseIdentifier = "UserCell"
private let postCellIdentifier = "PostCell"

class SearchController: UIViewController {
    
    //MARK: - Properties
    
    var users = [User]()
    var filterUsers = [User]()
    
    var posts = [Post]()
    
    private var tableView = UITableView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(ProfileCell.self, forCellWithReuseIdentifier: postCellIdentifier)
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        fetchUsers()
        fetchPosts()
        configureUI()
        configureSearchController()
        
    }
    
    //MARK: - API
    
    func fetchUsers() {
        UserServices.getAllUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    func fetchPosts() {
        PostServices.fetchPostWithLastTimeSeen { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - HelperFunctions
    
    func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.delegate = self
        
//        definesPresentationContext = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: - UISearchBarDelegate

extension SearchController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        tableView.isHidden = false
        collectionView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.text = nil
        
        tableView.isHidden = true
        collectionView.isHidden = false
    }
}
    

//MARK: - UITableViewDataSource

extension SearchController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserTableViewCell
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

//MARK: - UITableViewDelegate

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UICollectionViewDelegate

extension SearchController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDataSource

extension SearchController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellIdentifier, for: indexPath) as! ProfileCell
        
        let viewModel = PostViewModel(post: posts[indexPath.row])
        cell.viewModel = viewModel
        
        return cell
    }
    
}


//MARK: - UICollectionViewFlowLayout

extension SearchController: UICollectionViewDelegateFlowLayout {
    
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
    
}

//MARK: - UISearchControllerDelegate

extension SearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        
        filterUsers.removeAll()
        filterUsers = users.filter { $0.username.lowercased().contains(text) || $0.fullName.lowercased().contains(text) }
        tableView.reloadData()
        
//        print("Debug: filterUsers: # \(filterUsers)")
//        print("----------------------------------------------------------------------------")
    }
    
    
}
