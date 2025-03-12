//
//  BookmarksViewController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import RealmSwift

final class BookmarksViewController: BaseViewController {

    @IBOutlet weak var barItem: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    
    var bookmarksViewModel = BookmarksViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.getNib(), forCellReuseIdentifier: String(describing: MovieTableViewCell.self))
        
        bookmarksViewModel.observeChanges() { [weak self] (result: Result<RealmCollectionChangeStatus, DBManagerError>) in
            
            DispatchQueue.main.async {
                switch result {
                    case .success(.initial):
                        self?.tableView.reloadData()
                    case .success(.update(let deletions, let insertions, let modifications)):
                        self?.tableView.performBatchUpdates({
                            if !deletions.isEmpty {
                                self?.tableView.deleteRows(at: deletions, with: .automatic)
                                // TODO: Update appearances.
                            }
                            if !insertions.isEmpty {
                                self?.tableView.insertRows(at: insertions, with: .automatic)
                                // TODO: Update appearances.
                            }
                            if !modifications.isEmpty {
                                self?.tableView.reloadRows(at: modifications, with: .automatic)
                            }
                        }, completion: nil)
                    
                    case .failure(_):
                        debugPrint("Failed to fetch movies")
                        break
                }
            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        navigateToTab(tab: Tabs.search)
    }
    
    func fetchMovieDetail(of id: Int) {
        bookmarksViewModel.fetchMovieDetail(of: id) { [weak self] in
            if let movie = self?.bookmarksViewModel.movieDetailData {
                NavigationUtils.navigateToMovieDetail(from: self!, movie: movie)
            }
        }
    }
    
    func removeItem(at indexPath: IndexPath) {
        bookmarksViewModel.removeItem(at: indexPath.row) { result in
            switch result {
                case .success:
                    debugPrint("Get back.")
                case .failure(_):
                    debugPrint("Failed to remove movie")
            }
        }
    }

}
