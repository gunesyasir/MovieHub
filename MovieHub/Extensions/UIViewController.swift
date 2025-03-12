//
//  UIViewController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension UIViewController {
    func configureTabBar() {
        self.tabBarController?.viewControllers?[0].tabBarItem.title = LocalizedStrings.popular.localized
        self.tabBarController?.viewControllers?[1].tabBarItem.title = LocalizedStrings.search.localized
        self.tabBarController?.viewControllers?[2].tabBarItem.title = LocalizedStrings.bookmarks.localized
    }
    
    func navigateToTab(tab: Tabs) {
        self.tabBarController?.selectedIndex = tab.rawValue
    }
    
    func showAlertDialog(title: String = "", message: String, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
