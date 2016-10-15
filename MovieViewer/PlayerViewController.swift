//
//  PlayerViewController.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/14/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, YTPlayerViewDelegate {

    var youTubeKey: String = ""
    
    @IBOutlet var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.delegate = self
        playerView.load(withVideoId: self.youTubeKey)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.closedFullScreen), name: .UIWindowDidBecomeHidden, object: nil)
    }
    
    func closedFullScreen() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - YTPlayerViewDelegate
    func playerViewDidBecomeReady(_ playerView: YTPlayerView!) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView!, didChangeTo state: YTPlayerState) {
        if state == .ended {
            dismiss(animated: true, completion: nil)
        }
    }

}
