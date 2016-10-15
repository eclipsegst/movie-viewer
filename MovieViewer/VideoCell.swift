//
//  VideoCell.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/14/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    
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
//        backgroundColor = UIColor(red: 31/255.0, green: 32/255.0, blue: 41/255.0, alpha: 0.9)
        
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
