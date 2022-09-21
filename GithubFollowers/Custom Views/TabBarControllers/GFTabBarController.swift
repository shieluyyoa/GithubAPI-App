//
//  GFTabBarController.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 1/9/2022.
//

import UIKit

class GFTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        viewControllers = [createSearchNC(),createFavouritesNC()]
    }
    

    func createSearchNC() -> UINavigationController {
        let searchVC = SearchVC()
        searchVC.title = "Search"
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        
        return UINavigationController(rootViewController: searchVC)
        
    }
    
    func createFavouritesNC() -> UINavigationController {
        let favouritesListVC = FavouritesListVC()
        favouritesListVC.title = "Favourites"
        favouritesListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        return UINavigationController(rootViewController: favouritesListVC)
    }
    

}
