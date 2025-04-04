//
//  MovieDetailController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import WebKit
import Combine

final class MovieDetailController: BaseViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var castCollection: UICollectionView!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var genreCollection: UICollectionView!
    @IBOutlet weak var homepageButton: UIButton!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var recommendationsLabel: UILabel!
    @IBOutlet weak var recommendationsCollection: UICollectionView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upperLabelsStack: UIStackView!
    
    private let movie: Movie
    let viewModel: MovieDetailViewModel
    private var isSinkedFirstTime = false
    private var cancellables = Set<AnyCancellable>()
    private var webView = WKWebView()
    var tableViewData: [[String: Any]] {
        var data: [[String: Any]] = []
        if let title = movie.originalTitle, !title.isEmpty {
            data.append([LocalizedStrings.originalTitle.localized : title])
        }
        if let budget = movie.budget, budget != 0 {
            data.append([LocalizedStrings.budget.localized : budget])
        }
        if let revenue = movie.revenue, revenue != 0 {
            data.append([LocalizedStrings.revenue.localized : revenue])
        }
        let companies = Array(movie.productionCompanies)
        if companies.count > 0, let name = companies[0].name {
            data.append([LocalizedStrings.productionCompany.localized: name])
        }
        
        return data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setBindings()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        viewModel.updateDatabase()
    }
    
    @IBAction func homepageButtonPressed(_ sender: UIButton) {
        if let page = movie.homepage, let url = URL(string: page) {
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        }
    }

    init?(coder: NSCoder, movie: Movie) {
        self.movie = movie
        viewModel = MovieDetailViewModel(movie: movie)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use `init(coder:movie:)` to initialize.")
    }
    
    func fetchMovieDetail(of id: Int) {
        viewModel.fetchMovieDetail(of: id) { [weak self] in
            if let movie = self?.viewModel.movieDetailData {
                NavigationUtils.navigateToMovieDetail(from: self!, movie: movie)
            } else {
                self?.showError(message: self!.viewModel.errorMessage, onTryAgain: {
                    self?.fetchMovieDetail(of: id)
                })
            }
        }
    }
    
    private func setBindings() {
        viewModel.existInDatabase
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                if !self.isSinkedFirstTime {
                    self.isSinkedFirstTime = true
                    self.addButton.removeShimmer()
                }
                self.setButton()
            }
            .store(in: &cancellables)
        
        viewModel.$isCastRequestCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self, value == true else { return }
                
                if self.viewModel.movie.cast.isEmpty {
                    castLabel.removeFromSuperview()
                    castCollection.removeFromSuperview()
                    recommendationsLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12).isActive = true
                } else {
                    self.castCollection.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isRecommendedsRequestCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self, value == true else { return }
                
                if self.viewModel.recommendedsCurrentPageCount <= 1 { // Works on initial request, does not on pagination requests
                    if self.viewModel.movie.recommendedMovies.isEmpty {
                        recommendationsLabel.removeFromSuperview()
                        recommendationsCollection.removeFromSuperview()
                        if self.viewModel.isCastRequestCompleted && self.viewModel.movie.cast.isEmpty { // No castList to reference in this case
                            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24).isActive = true
                        } else {
                            castCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24).isActive = true
                        }
                        return
                    }
                }
                
                self.recommendationsCollection.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$actorDetailData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let self = self, let actor = data {
                    NavigationUtils.navigateToActorDetail(from: self, actor: actor)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setButton() {
        let isExists = viewModel.existInDatabase.value
        addButton.backgroundColor = UIColor(named: isExists ? "TabbarLabelColor" : "Orange")
        addButton.setTitle(isExists ? LocalizedStrings.removeFromBookmarks.localized : LocalizedStrings.addToBookmarks.localized, for: .normal)
        addButton.setTitleColor(UIColor(named: "TabbarColor"), for: .normal)
        addButton.layer.cornerRadius = 8
        addButton.setImage(UIImage(systemName: isExists ? "bookmark.slash.fill" : "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = isExists ? .gray : UIColor(named: "TabbarColor")
    }
    
    private func setupCollectionView(for collectionView: UICollectionView, of type: UICollectionViewCell.Type, autoSized: Bool = false) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: String(describing: type), bundle: nil), forCellWithReuseIdentifier: String(describing: type))
        if autoSized {
            let collectionFlowLayout = UICollectionViewFlowLayout()
            collectionFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            collectionFlowLayout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            collectionFlowLayout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = collectionFlowLayout
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DictionaryCell.getNib(), forCellReuseIdentifier: String(describing: DictionaryCell.self))
        let rowHeight = CGFloat(30)
        tableView.rowHeight = rowHeight
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableViewData.count) * rowHeight + CGFloat(tableViewData.count)).isActive = true
    }
    
    private func setupWebView() {
        webView.isHidden = true
        webView.frame = view.bounds
        view.addSubview(webView)
    }

    private func setUpViews() {
        title = movie.title
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.init(named: "TabbarLabelColor")] as? [NSAttributedString.Key : Any]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        scrollView.delegate = self
        
        let backdropURL = ImageUtils.getImageURL(from: movie.backdropPath)
        backdropImage.setImage(with: backdropURL)
        
        let posterURL = ImageUtils.getImageURL(from: movie.posterPath)
        if let url = posterURL {
            posterImage.setImage(with: url)
        } else {
            posterImage.removeFromSuperview()
            upperLabelsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        }
        
        if let runtime = movie.runtime, let langCode = movie.spokenLanguages.first?.code, let language = LanguageUtils.getLocalizedLanguageName(fromCode: langCode), let rate = movie.voteAverage {
            duration.text = "🕓 \(runtime)  ⭐️ \(rate.toOneDecimalPoint())  🔊 \(language)"
        } else if let runtime = movie.runtime, let rate = movie.voteAverage {
            duration.text = "🕓 \(runtime)  ⭐️ \(rate.toOneDecimalPoint())"
        } else if let runtime = movie.runtime, let langCode = movie.spokenLanguages.first?.code, let language = LanguageUtils.getLocalizedLanguageName(fromCode: langCode) {
            duration.text = "🕓 \(runtime)  🔊 \(language)"
        } else if let langCode = movie.spokenLanguages.first?.code, let language = LanguageUtils.getLocalizedLanguageName(fromCode: langCode), let rate = movie.voteAverage {
            duration.text = "⭐️ \(rate)  🔊 \(language)"
        } else if let runtime = movie.runtime {
            duration.text = "🕓 \(runtime)"
        } else if let rate = movie.voteAverage {
            duration.text = "⭐️ \(rate)"
        } else if let langCode = movie.spokenLanguages.first?.code, let language = LanguageUtils.getLocalizedLanguageName(fromCode: langCode) {
            duration.text = "🔊 \(language)"
        } else {
            duration.removeFromSuperview()
        }

        releaseDate.text = DateUtils.convertToMonthAndYearFormat(from: movie.releaseDate)
        name.text = movie.title
        overviewLabel.text = movie.overview
        
        castLabel.text = LocalizedStrings.cast.localized
        recommendationsLabel.text = LocalizedStrings.recommendations.localized
        
        addButton.addShimmer()

        if movie.genres.isEmpty {
            genreCollection.removeFromSuperview()
            addButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 12).isActive = true
        } else {
            setupCollectionView(for: genreCollection, of: GenreCell.self, autoSized: true)
        }
        
        if let page = movie.homepage, let _ = URL(string: page) {
            homepageButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        } else {
            homepageButton.removeFromSuperview()
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12).isActive = true
        }
        
        // Height of table view is dynamic, no need for remove and re-constraint.
        setupTableView()

        // Data of collections below is fetching after screen is opened thus checking for if they contains data is wrong in here.
        setupCollectionView(for: castCollection, of: ContentCell.self)
        setupCollectionView(for: recommendationsCollection, of: ContentCell.self)
        
        setupWebView()
    }

}
