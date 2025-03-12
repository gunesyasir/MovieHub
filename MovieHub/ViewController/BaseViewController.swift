//
//  BaseViewController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

class BaseViewController: UIViewController {
    private var activityIndicator = UIActivityIndicatorView()
    private var activityIndicatorOverlay = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpActivityIndicator()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setUpActivityIndicator() {
        activityIndicatorOverlay = UIView(frame: view.bounds)
        activityIndicatorOverlay.backgroundColor = .black.withAlphaComponent(0.5)
        activityIndicatorOverlay.isHidden = true
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor(named: "Orange")
        
        activityIndicatorOverlay.addSubview(activityIndicator)
        view.addSubview(activityIndicatorOverlay)
    }
    
    func showError(message: String, onTryAgain: @escaping () -> Void) {
        showAlertDialog(message: message, actions: [
            UIAlertAction(title: LocalizedStrings.ok.localized, style: .default, handler: nil),
            UIAlertAction(title: LocalizedStrings.tryAgain.localized, style: .default, handler: { _ in
                onTryAgain()
            })
        ])
    }
    
    func toggleActivityIndicator(show isVisible: Bool) {
        if isVisible {
            activityIndicator.startAnimating()
            activityIndicatorOverlay.isHidden = false
            view.isUserInteractionEnabled = false
            if let tabBarController = tabBarController {
                tabBarController.tabBar.isUserInteractionEnabled = false
            }
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorOverlay.isHidden = true
            view.isUserInteractionEnabled = true
            if let tabBarController = tabBarController {
                tabBarController.tabBar.isUserInteractionEnabled = true
            }
        }
    }

}
