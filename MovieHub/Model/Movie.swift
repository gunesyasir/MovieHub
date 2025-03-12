//
//  Movie.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

class Movie: Object, Decodable {
    @Persisted var backdropPath: String?
    @Persisted var budget: Int?
    @Persisted var genreIDS = List<Int>()
    @Persisted var genres = List<Genre>()
    @Persisted var homepage: String?
    @Persisted(primaryKey: true) var id: Int
    @Persisted var originalLanguage: String?
    @Persisted var originalTitle: String?
    @Persisted var overview: String?
    @Persisted var posterPath: String?
    @Persisted var productionCompanies = List<ProductionCompany>()
    @Persisted var releaseDate: String?
    @Persisted var revenue: Int?
    @Persisted var runtime: Int?
    @Persisted var spokenLanguages = List<SpokenLanguage>()
    @Persisted var status: String?
    @Persisted var title: String?
    @Persisted var voteAverage: Double?
    @Persisted var recommendedMovies = List<RecommendedMovie>()
    @Persisted var cast = List<Cast>()
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case budget
        case genreIDS = "genre_ids"
        case genres
        case homepage
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case releaseDate = "release_date"
        case revenue
        case runtime
        case spokenLanguages = "spoken_languages"
        case status
        case title
        case voteAverage = "vote_average"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backdropPath = try? container.decode(String.self, forKey: .backdropPath)
        budget = try? container.decode(Int.self, forKey: .budget)
        
        if let genreIDsArray = try? container.decode([Int].self, forKey: .genreIDS) {
            genreIDS.append(objectsIn: genreIDsArray)
        }
        
        if let genresArray = try? container.decode([Genre].self, forKey: .genres) {
            genres.append(objectsIn: genresArray)
        }
        
        homepage = try? container.decode(String.self, forKey: .homepage)
        id = try container.decode(Int.self, forKey: .id)
        originalLanguage = try? container.decode(String.self, forKey: .originalLanguage)
        originalTitle = try? container.decode(String.self, forKey: .originalTitle)
        overview = try? container.decode(String.self, forKey: .overview)
        posterPath = try? container.decode(String.self, forKey: .posterPath)
        
        if let productionCompaniesArray = try? container.decode([ProductionCompany].self, forKey: .productionCompanies) {
            productionCompanies.append(objectsIn: productionCompaniesArray)
        }
        
        releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        revenue = try? container.decode(Int.self, forKey: .revenue)
        runtime = try? container.decode(Int.self, forKey: .runtime)
        
        if let spokenLanguagesArray = try? container.decode([SpokenLanguage].self, forKey: .spokenLanguages) {
            spokenLanguages.append(objectsIn: spokenLanguagesArray)
        }
        
        status = try? container.decode(String.self, forKey: .status)
        title = try? container.decode(String.self, forKey: .title)
        voteAverage = try? container.decode(Double.self, forKey: .voteAverage)
    }
}

class Genre: EmbeddedObject, Decodable {
    @Persisted var id: Int?
    @Persisted var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class ProductionCompany: EmbeddedObject, Decodable {
    @Persisted var id: Int?
    @Persisted var logoPath: String?
    @Persisted var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
        logoPath = try? container.decode(String.self, forKey: .logoPath)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class SpokenLanguage: EmbeddedObject, Decodable {
    @Persisted var code: String?
    @Persisted var name: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "iso_639_1"
        case name
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try? container.decode(String.self, forKey: .code)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class RecommendedMovie: Object {
    @Persisted var id: Int
    @Persisted var posterPath: String?
    @Persisted var title: String?
    
    required override init() {
        super.init()
    }
    
    required init(id: Int, posterPath: String?, title: String?) {
        self.id = id
        self.posterPath = posterPath
        self.title = title
        super.init()
    }
    
    convenience init(from movie: Movie) {
        self.init(id: movie.id, posterPath: movie.posterPath, title: movie.title)
    }
}

