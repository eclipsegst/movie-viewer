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
    static let TAG = NSStringFromClass(Movie.self)
    
    // Json key
    static let id = "id"
    
    dynamic var id = ""
    dynamic var title = ""
    dynamic var overview = ""
    dynamic var posterPath: String? = nil
    dynamic var releaseDate: Date!
    dynamic var originalTitle = ""
    dynamic var originalLanguage = ""
    dynamic var backdropPath: String? = nil
    dynamic var popularity: Double = 0.0
    dynamic var voteAverage: Double = 0.0
    dynamic var voteCount: Int = 0
    dynamic var adult = false

    dynamic var genreIds = ""
    dynamic var homepage = ""
    dynamic var runtime: Int = 0
    dynamic var status = ""
    dynamic var tagline = ""
    dynamic var budget: Int = 0
    dynamic var revenue: Int = 0
    dynamic var movieType = ""
    dynamic var isHearted: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getGenres() -> Results<Genre>? {
        let realm = AppDelegate.getInstance().realm!
        let genres = self.genreIds.components(separatedBy: ",")
        if genres.count > 0 {
            return realm.objects(Genre.self).filter("id in %@", genres)
        }
        
        return nil
    }
    
    func getAllVideos() -> Results<Video> {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Video.self).filter("movieId == %@", self.id).sorted(byProperty: "id", ascending: true)
    }
    
    func mapFrom(data: [String: AnyObject]) throws {
        self.id = String(describing: data["id"]!)
        self.title = data["title"] as! String
        self.overview = data["overview"] as! String
        if let posterPath = data["poster_path"] as? String {
            self.posterPath = posterPath
        }
        self.originalTitle = data["original_title"] as! String
        self.originalLanguage = data["original_language"] as! String
        
        if let backdropPath = data["backdrop_path"] as? String {
            self.backdropPath = backdropPath
        }
        
        self.popularity = data["popularity"] as! Double
        self.voteAverage = data["vote_average"] as! Double
        self.voteCount = data["vote_count"] as! Int
        self.adult = data["adult"] as! Bool
        
        let datetimeString = data["release_date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.releaseDate = dateFormatter.date(from: datetimeString)
    }
    
    static func sync(movieType: MovieType) {
        let url = Constants.baseUrl + movieType.rawValue + Constants.apiKey
        let request = URLRequest(url: URL(string:url)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            
            guard let data = dataOrNil  else {
                print("\(self.TAG) : dataOrNil is nil")
                return
            }
            
            guard let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("\(self.TAG) : Response cannot be parsed as JSONObject.")
                return
            }
            
            guard let results = responseDictionary["results"] as? [[String: AnyObject]] else {
                print("\(self.TAG) : Key 'results' does not exist.")
                return
            }

            let realm = AppDelegate.getInstance().realm!
            
            for movieDict in results {
                let movie = Movie()
                
                do {
                    try movie.mapFrom(data: movieDict)
                    try! realm.write {
                        realm.add(movie, update: true)
                    }
                } catch {
                    print("Error passing movie:\n \(movieDict)")
                }
            }

            print("\(self.TAG) count: \(Movie.getAllMovies().count)")
        })
        
        task.resume()
    }

    static func getAllMovies() -> Results<Movie> {
        let realm = AppDelegate.getInstance().realm!
        
        return realm.objects(Movie.self)
    }
    
    static func getMoviesByType(movieType: MovieType) -> Results<Movie> {
        let realm = AppDelegate.getInstance().realm!
        var property = ""
        switch movieType {
        case .nowPlaying:
            property = "releaseDate"
        case .topRated:
            property = "voteAverage"
        default:
            property = "releaseDate"
        }
        return realm.objects(Movie.self).filter("movieType == %@", movieType.rawValue).sorted(byProperty: property, ascending: false)
    }
    
    static func getMovieById(id: String) -> Movie? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Movie.self).filter("id == %@", id).first
    }
    
}
