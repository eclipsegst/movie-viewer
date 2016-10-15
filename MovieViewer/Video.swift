//
//  Video.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/9/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import Foundation
import RealmSwift

class Video: Object {
    static let TAG = NSStringFromClass(Video.self)
    
    dynamic var id: String = ""
    dynamic var key: String = ""
    dynamic var name: String = ""
    dynamic var site: String = ""
    dynamic var movieId: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(data: [String : AnyObject]) throws {
        guard let id = data["id"] as? String else {
            throw ParseError.other(error: "id is not String")
        }
        
        guard let key = data["key"] as? String else {
            throw ParseError.other(error: "key is not String")
        }
        
        guard let name = data["name"] as? String else {
            throw ParseError.other(error: "name is not String")
        }
        
        guard let site = data["site"] as? String else {
            throw ParseError.other(error: "site is not String")
        }
        
        self.id = id
        self.key = key
        self.name = name
        self.site = site
    }
    
    static func sync(movieId: String) {
        let url = Constants.baseUrl + movieId + "/videos" + Constants.apiKey
        let request = URLRequest(url: URL(string: url)!)
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
            
            guard let results = responseDictionary["results"] as? [[String: AnyObject]] else {
                print("Key 'results' is not exist.")
                return
            }
            
            let realm = AppDelegate.getInstance().realm!
            
            for videoDict in results {
                let video = Video()
                
                do {
                    try video.mapFrom(data: videoDict)
                    video.movieId = movieId
                    try! realm.write {
                        realm.add(video, update: true)
                    }
                } catch ParseError.other(let error) {
                    print(error)
                } catch {
                    print("Error parsing video:\n \(videoDict)")
                }
            }
        })
        
        task.resume()
    }
    
    static func getVideoById(id: String) -> Video? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Video.self).filter("id == %@", id).first
    }

}
