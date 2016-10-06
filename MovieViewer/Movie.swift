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
    
    // Property
    dynamic var id = ""
    dynamic var title = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFromDict(dict: [String: AnyObject]) throws {
        self.id = String(describing: dict["id"]!)
        self.title = dict["title"] as! String
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
