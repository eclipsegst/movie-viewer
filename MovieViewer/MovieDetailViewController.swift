//
//  MovieDetailViewController.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/6/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    let TAG = NSStringFromClass(MovieDetailViewController.self)
    
    var movieId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(movieId)
    }

}
