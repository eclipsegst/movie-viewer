//
//  Movie.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 9/25/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object {
    let tag = NSStringFromClass(Movie.self)
    
    // Json key
    static let id = "id"
    
    dynamic var id = ""
    dynamic var title = ""
    dynamic var overview = ""
    dynamic var posterPath = ""
    dynamic var releaseDate: Date!
    dynamic var originalTitle = ""
    dynamic var originalLanguage = ""
    dynamic var backdropPath = ""
    dynamic var popularity: Double = 0.0
    dynamic var voteAverage: Double = 0.0
    dynamic var voteCount: Int = 0
    dynamic var runtime: Int = 0
    dynamic var adult = false
    dynamic var genresIds = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFromDict(dict: [String: AnyObject]) throws {
        self.id = String(describing: dict["id"]!)
        self.title = dict["title"] as! String
        self.overview = dict["overview"] as! String
        self.posterPath = dict["poster_path"] as! String
        self.originalTitle = dict["original_title"] as! String
        self.originalLanguage = dict["original_language"] as! String
        
        if let backdropPath = dict["backdrop_path"] as? String {
            self.backdropPath = backdropPath
        }
        
        self.popularity = dict["popularity"] as! Double
        self.voteAverage = dict["vote_average"] as! Double
        self.voteCount = dict["vote_count"] as! Int
        self.adult = dict["adult"] as! Bool
        
        let datetimeString = dict["release_date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.releaseDate = dateFormatter.date(from: datetimeString)
    }
    
    static func getAllMovies() -> Results<Movie> {
        let realm = AppDelegate.getInstance().realm!
        
        return realm.objects(Movie.self)
    }
    
    static func getMovieById(id: String) -> Movie {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Movie.self).filter("id == %@", id).first!
    }
}
