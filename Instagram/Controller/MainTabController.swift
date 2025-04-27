//
//  MainTabController.swift
//  Instagram
//
//  Created by S M H  on 07/12/2024.
//

import UIKit
import Firebase
import YPImagePicker

class MainTabController: UITabBarController {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            configureViewControllers(with: user)
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserLoginStatus()
        
    }
    
    //MARK: - API
    
    func fetchCurrentUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        UserServices.getUser(uid: userID) { user in
            self.user = user
        }
    }
    
    func checkUserLoginStatus() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                loginController.delegate = self
                let nav = UINavigationController(rootViewController: loginController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            fetchCurrentUser()
        }
    }
    
    //MARK: - Helper Functions
    
    func configureViewControllers(with user: User) {
        
        self.delegate = self
        
        /// for collectionViewController
        let layout = UICollectionViewFlowLayout()
        
        let feedController = configureNavigationController(selectedImage: UIImage(named: "home_selected")!, unselectedImage: UIImage(named: "home_unselected")!, rootViewOfController: FeedController(collectionViewLayout: layout))
                                                 
        let searchController = configureNavigationController(selectedImage: UIImage(named: "search_selected")!, unselectedImage: UIImage(named: "search_unselected")!, rootViewOfController: SearchController())
        
        let notificationController = configureNavigationController(selectedImage: UIImage(named: "like_selected")!, unselectedImage: UIImage(named: "like_unselected")!, rootViewOfController: NotificationController())
        
        let imageSelectController = configureNavigationController(selectedImage: UIImage(named: "plus_unselected")!, unselectedImage: UIImage(named: "plus_unselected")!, rootViewOfController: ImageSelectController())
        
        let profile = ProfileController(user: user)
        let profileController = configureNavigationController(selectedImage: UIImage(named: "profile_selected")!, unselectedImage: UIImage(named: "profile_unselected")!, rootViewOfController: profile)
        
        viewControllers = [feedController, searchController, imageSelectController, notificationController, profileController]
        
        tabBar.isTranslucent = false
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black
    }
    
    /// to select and unSelect tabBarImage
    func configureNavigationController(selectedImage: UIImage, unselectedImage: UIImage, rootViewOfController: UIViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: rootViewOfController)
        navigationController.tabBarItem.image = unselectedImage
        navigationController.tabBarItem.selectedImage = selectedImage
        navigationController.navigationBar.isTranslucent = false
        
        return navigationController
    }
    
    
}

//MARK: - AuthenticationDelegate

extension MainTabController: AuthenticationDelegate {
    
    func didAuthenticate() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let token = UserDefaultManager.shared.deviceToken
        DeviceToken.saveDeviceToken(currentUid: userID, token: token ?? "")
        
        fetchCurrentUser()
        self.dismiss(animated: true)
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    /// select index on imagePicker and config YPImagePicker to pick up image
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photoAndVideo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.hidesBottomBar = true
            config.hidesStatusBar = true
            config.library.maxNumberOfItems = 1
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true)
            
            guard let user = user else { return false }
            
            picker.didFinishPicking { items, _ in
                
                picker.dismiss(animated: false) {
                    let controller = UploadPostController()
                    controller.delegate = self
                    controller.user = user
                    
                    if let item = items.first {
                        switch item {
                        case .photo(let photo):
                            controller.selectedImage = photo.image
                        case .video(let video):
                            controller.selectedVideo = video
                        }
                    }
                    
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                }
            }
        }
        return true
    }
}

//MARK: - UploadPostControllerDelegate

extension MainTabController: UploadPostControllerDelegate {
    
    // call after post upload finish from UploadPostController
    func didUploadPost(_ controller: UploadPostController) {
        
        guard let navigationController = viewControllers?.first as? UINavigationController else { return print("debug: navigationController not found") }
        guard let feedController = navigationController.viewControllers.first as? FeedController else { return print("debug: feedController not found") }
        feedController.fetchPosts()
        
        selectedIndex = 0
        controller.dismiss(animated: true)
        
    }
}
