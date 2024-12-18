//
//  MainTabController.swift
//  Instagram
//
//  Created by S M H  on 07/12/2024.
//

import UIKit

class MainTabController: UITabBarController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureViewControllers()
    }
    
    //MARK: - Helper Functions
    
    func configureViewControllers() {
        
        /// for collectionViewController
        let layout = UICollectionViewFlowLayout()
        
        let feedController = configureNavigationController(selectedImage: UIImage(named: "home_selected")!, unselectedImage: UIImage(named: "home_unselected")!, rootViewOfController: FeedController(collectionViewLayout: layout))
                                                 
        let searchController = configureNavigationController(selectedImage: UIImage(named: "search_selected")!, unselectedImage: UIImage(named: "search_unselected")!, rootViewOfController: SearchController())
        
        let profileController = configureNavigationController(selectedImage: UIImage(named: "profile_selected")!, unselectedImage: UIImage(named: "profile_unselected")!, rootViewOfController: ProfileController())
        
        let notificationController = configureNavigationController(selectedImage: UIImage(named: "like_selected")!, unselectedImage: UIImage(named: "like_unselected")!, rootViewOfController: NotificationController())
        
        let imageSelectController = configureNavigationController(selectedImage: UIImage(named: "plus_unselected")!, unselectedImage: UIImage(named: "plus_unselected")!, rootViewOfController: ImageSelectController())
        
        viewControllers = [feedController, searchController, imageSelectController, notificationController, profileController]
        
        tabBar.isTranslucent = false
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black
    }
    
    /// need to add border between navigationBar and tabBar
    func configureNavigationController(selectedImage: UIImage, unselectedImage: UIImage, rootViewOfController: UIViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: rootViewOfController)
        navigationController.tabBarItem.image = unselectedImage
        navigationController.tabBarItem.selectedImage = selectedImage
        navigationController.navigationBar.isTranslucent = false
        
        return navigationController
    }
    
}
