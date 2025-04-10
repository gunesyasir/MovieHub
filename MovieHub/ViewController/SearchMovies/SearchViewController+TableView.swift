//
//  SearchViewController+TableView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMoviesViewModel.movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = searchMoviesViewModel.movieList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MovieTableViewCell.self)) as! MovieTableViewCell
        
        cell.configure(with: movie)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == searchMoviesViewModel.movieList.count - 1, searchMoviesViewModel.currentPageCount < searchMoviesViewModel.totalPageCount {
            searchMoviesViewModel.fetchData(for: searchMoviesViewModel.previousQueryText)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = searchMoviesViewModel.movieList[indexPath.row]

        fetchMovieDetail(of: movie.id)
    }
    
}
