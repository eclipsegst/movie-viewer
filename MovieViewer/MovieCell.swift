//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/6/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    var movie: Movie! {
        didSet {
            titleLabel.text = movie.title
            voteAverageLabel.text = String(movie.voteAverage)
            overviewLabel.text = movie.overview
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            releaseLabel.text = dateFormatter.string(from: movie.releaseDate)
        }
    }
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteAverageLabel: UILabel!
    @IBOutlet var releaseLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
