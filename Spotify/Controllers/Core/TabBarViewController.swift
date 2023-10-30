//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Alfan on 24/10/23.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vcHome = HomeViewController()
        let vcSearch = SearchViewController()
        let vcLibrary = LibraryViewController()
        
        vcHome.title = "Browse"
        vcSearch.title = "Search"
        vcLibrary.title = "Library"
        
        vcHome.navigationItem.largeTitleDisplayMode = .always
        vcSearch.navigationItem.largeTitleDisplayMode = .always
        vcLibrary.navigationItem.largeTitleDisplayMode = .always
        
        let navHome = UINavigationController(rootViewController: vcHome)
        let navSearch = UINavigationController(rootViewController: vcSearch)
        let navLibrary = UINavigationController(rootViewController: vcLibrary)
        
        navHome.navigationBar.tintColor = .label
        navSearch.navigationBar.tintColor = .label
        navLibrary.navigationBar.tintColor = .label
        
        navHome.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        navLibrary.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        navHome.navigationBar.prefersLargeTitles = true
        navSearch.navigationBar.prefersLargeTitles = true
        navLibrary.navigationBar.prefersLargeTitles = true
        
        setViewControllers([navHome, navSearch, navLibrary], animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
