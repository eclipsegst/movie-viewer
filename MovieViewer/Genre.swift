//
//  Genre.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/9/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import Foundation
import RealmSwift

class Genre: Object {
    static let TAG = NSStringFromClass(Genre.self)
    
    dynamic var id = ""
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(data: [String : AnyObject]) throws {
        guard let id = data["id"] as? Int else {
            throw ParseError.other(error: "id is not Int")
        }
        
        guard let name = data["name"] as? String else {
            throw ParseError.other(error: "name is not String")
        }
        
        self.id = String(id)
        self.name = name
    }
    
    static func sync() {
        let request = URLRequest(url: URL(string:Constants.genreUrl)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            guard let data = dataOrNil else {
                print("dataOrNil is nil")
                return
            }
            
            guard let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("Cannot pase response as JSONObject.")
                return
            }
            
            guard let results = responseDictionary["genres"] as? [[String: AnyObject]] else {
                print("Key 'genres' is not exist.")
                return
            }
            
            let realm = AppDelegate.getInstance().realm!
            
            for genreDict in results {
                let genre = Genre()
                
                do {
                    try genre.mapFrom(data: genreDict)
                    try! realm.write {
                        realm.add(genre, update: true)
                    }
                } catch ParseError.other(let error) {
                    print(error)
                } catch {
                    print("Error parsing genre:\n \(genreDict)")
                }
            }
            
            print("\(TAG) count: \(Genre.getAllGenres().count)")
        })
        
        task.resume()
    }
    
    static func getAllGenres() -> Results<Genre> {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Genre.self).sorted(byProperty: "id", ascending: true)
    }
    
    static func getGenreById(id: String) -> Genre? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Genre.self).filter("id == %@", id).first
    }
}
