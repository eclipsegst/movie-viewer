//
//  SyncMovie.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 9/25/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import Foundation

class SyncMovie {
    static let tag = NSStringFromClass(SyncMovie.self)
    
    static let apiKey = "api_key"
    static let nowPlaying = "now_playing"
    
    static func getNowPlaying() {
        let url = Constants.baseUrl + self.nowPlaying + "?\(apiKey)=" + Constants.apiKey
        let request = URLRequest(url: URL(string:url)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print("response:\(responseDictionary)")
                    
                    if let results = responseDictionary["results"] as? [[String: AnyObject]] {
                        let realm = AppDelegate.getInstance().realm!
                        
                        for movieDict in results {
                            let movie = Movie()
                            
                            do {
                                try movie.mapFromDict(dict: movieDict)
                                try! realm.write {
                                    realm.add(movie, update: true)
                                }
                            } catch {
                                print("Error passing movie:\n \(movieDict)")
                            }
                        }
                    }
                }
            }
            
            print(Movie.getAllMovies().count)
        })
        
        task.resume()
    }
}
