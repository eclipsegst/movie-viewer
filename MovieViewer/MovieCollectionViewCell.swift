//
//  MovieCollectionViewCell.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/13/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var movieTitleLabel: UILabel!

    @IBOutlet var titleLabel: NSLayoutConstraint!
    @IBOutlet var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
