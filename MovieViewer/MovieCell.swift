//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/6/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import AFNetworking

class MovieCell: UITableViewCell {
    
    var movie: Movie! {
        didSet {
            self.titleLabel.text = movie.title
            self.voteAverageLabel.text = String(movie.voteAverage)
            self.overviewLabel.text = movie.overview
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            self.releaseLabel.text = dateFormatter.string(from: movie.releaseDate)
            
            if let posterPath = movie.posterPath {
                let url = URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")!
                self.posterImageView.alpha = 0.0
                self.posterImageView.setImageWith(url)
                UIView.animate(withDuration: 1, animations: {
                    self.posterImageView.alpha = 1.0
                })
            }
            
            let heartIconBorder = UIImage(named: "for_you_border_icon")
            let heartIcon = UIImage(named: "for_you_icon")
            self.heartButton.setImage(self.movie!.isHearted ? heartIcon : heartIconBorder, for: .normal)
        }
    }
    
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteAverageLabel: UILabel!
    @IBOutlet var releaseLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    @IBAction func heartButtonAction(_ sender: AnyObject) {
        let heartIconBorder = UIImage(named: "for_you_border_icon")
        let heartIcon = UIImage(named: "for_you_icon")
        let realm = AppDelegate.getInstance().realm!
        
        try! realm.write {
            self.movie.isHearted = !self.movie.isHearted
            realm.add(movie, update: true)
        }
        
        self.heartButton.setImage(self.movie!.isHearted ? heartIcon : heartIconBorder, for: .normal)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initViews()
    }
    
    func initViews() {
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let fontSize: CGFloat = selected ? 34.0 : 17.0
        self.textLabel?.font = self.textLabel?.font.withSize(fontSize)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
