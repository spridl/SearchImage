//
//  MainTabBarController.swift
//  UnsplashSeachPhoto
//
//  Created by T on 16.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchVC = SearchViewController()
        let libraryVC = LibraryViewController()
        let categoriesVC = CategoriesViewController()
        tabBar.tintColor = .black
        
        viewControllers = [
            generateViewControllers(rootViewController: categoriesVC, title: "Categories", image: UIImage(systemName: "list.bullet")!),
            generateViewControllers(rootViewController: searchVC, title: "Search", image: UIImage(systemName: "magnifyingglass")!),
            generateViewControllers(rootViewController: libraryVC, title: "Library", image: UIImage(systemName: "folder")!)
        ]
        
    }
    private func generateViewControllers(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}
