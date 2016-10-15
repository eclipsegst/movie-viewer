//
//  MovieDetailViewController.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 10/6/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class MovieDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let TAG = NSStringFromClass(MovieDetailViewController.self)
    
    let tableViewCellHeight: CGFloat = 200
    let videoCell = "VideoCell"
    let playerViewControllerSegueId = "PlayerViewControllerSegueId"
    
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var runtimeLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var voteAverageLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var generLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var movieId: String! {
        didSet {
            self.movie = Movie.getMovieById(id: self.movieId)
        }
    }
    
    var movie: Movie!
    var videos: [Video] = []
    
    var notificationToken: NotificationToken?
    var realm: Realm! {
        didSet{
            self.notificationToken = self.realm!.addNotificationBlock({ [weak self] (notification, realm) in
                self!.invalidateViews()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = AppDelegate.getInstance().realm!
        
        self.tableView.register(UINib(nibName: self.videoCell, bundle: nil), forCellReuseIdentifier: self.videoCell)
        
        invalidateViews()
        self.sync()
        Video.sync(movieId: movie.id)
    }
    
    func invalidateViews() {
        self.videos = Array(movie.getAllVideos())
        self.tableViewHeightConstraint.constant = self.tableViewCellHeight * CGFloat(self.videos.count)
        
        self.titleLabel.text = self.movie.title
        self.overviewLabel.text = self.movie.overview
        self.overviewLabel.numberOfLines = 0
        self.overviewLabel.sizeToFit()
        
        if let backdropPath = self.movie.backdropPath {
            let backdropUrl = URL(string: "http://image.tmdb.org/t/p/w500\(backdropPath)")!
            self.backdropImageView.alpha = 0
            self.backdropImageView.setImageWith(backdropUrl)
            UIView.animate(withDuration: 1, animations: {
                self.backdropImageView.alpha = 1.0
            })
        }
        
        if let posterPath = movie.posterPath {
            print(posterPath)
            let url = URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")!
            self.posterImageView.alpha = 0.0
            self.posterImageView.setImageWith(url)
            UIView.animate(withDuration: 1, animations: {
                self.posterImageView.alpha = 1.0
            })
            print(posterPath)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        self.releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        self.popularityLabel.text = String(format: "Popularity: %.1f", self.movie.popularity)
        print("runtime:\(self.movie.runtime)")
        self.runtimeLabel.text = String(self.getRuntime(runtime: self.movie.runtime))
        self.voteAverageLabel.text = String("Average: \(self.movie.voteAverage)")
        self.voteCountLabel.text = String("Average Count: \(self.movie.voteCount)")
        
        if let genres = self.movie.getGenres() {
            var genreNames = ""
            for genre in genres {
                genreNames += genreNames == "" ? genre.name : ", " + genre.name
            }
            
            self.generLabel.text = genreNames
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.videoCell, for: indexPath) as! VideoCell
        let video = self.videos[indexPath.row]
        let url = URL(string: "http://img.youtube.com/vi/\(video.key)/0.jpg")!
        cell.thumbnailImageView.setImageWith(url)
        
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.orange
//        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        PlayerViewControllerSegueId
        performSegue(withIdentifier: self.playerViewControllerSegueId, sender: tableView)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.playerViewControllerSegueId {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.youTubeKey = self.videos[(self.tableView.indexPathForSelectedRow?.row)!].key
        }
    }
    
    func sync() {
        let url = Constants.baseUrl + self.movie.id + Constants.apiKey
        let request = URLRequest(url: URL(string:url)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            
            guard let data = dataOrNil  else {
                print("\(Movie.TAG) : dataOrNil is nil")
                return
            }
            
            guard let movieDict = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("\(Movie.TAG) : Response cannot be parsed as JSONObject.")
                return
            }
            
            let realm = AppDelegate.getInstance().realm!
            
            do {
                try realm.write {
                    if let runtime = movieDict["runtime"] as? Int {
                        self.movie.runtime = runtime
                    }
                    
                    if let status = movieDict["status"] as? String {
                        self.movie.status = status
                    }
                    
                    if let tagline = movieDict["tagline"] as? String {
                        self.movie.tagline = tagline
                    }
                    
                    if let genres = movieDict["genres"] as? [[String : AnyObject]] {
                        var ids = ""
                        for genreDict in genres {
                            ids += ids == "" ? String(describing: genreDict["id"]!) : "," + String(describing: genreDict["id"]!)
                        }
                        
                        self.movie.genreIds = ids
                    }
                    
                    realm.add(self.movie, update: true)
                }
            } catch {
                print("Error updating movie:\n \(movieDict)")
            }
        })
        
        task.resume()
    }

    func getRuntime(runtime: Int) -> String {
        var runtimeString = ""
        let hour = runtime / 60
        let min = runtime % 60
        
        if hour > 0 {
            runtimeString += "\(hour) h "
        }
        
        if min > 0 {
            runtimeString += "\(min)m"
        }
        
        return runtimeString
    }
    
    deinit {
        self.notificationToken?.stop()
    }
    
}
