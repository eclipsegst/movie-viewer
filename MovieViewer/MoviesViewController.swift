//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 9/25/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let TAG = NSStringFromClass(MoviesViewController.self)
    
    let movieCell = "MovieCell"
    let movieDetailViewControllerSegueId = "MovieDetailViewControllerSegueId"
    
    var movies: [Movie] = []
    var notificationToken: NotificationToken?
    var realm: Realm? {
        didSet{
            notificationToken = self.realm!.addNotificationBlock({ notification, realm in
                self.invalidateViews()
            })
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = AppDelegate.getInstance().realm

        self.tableView.register(UINib(nibName: movieCell, bundle: nil), forCellReuseIdentifier: movieCell)
        
        SyncMovie.getNowPlaying()
        
        invalidateViews()
    }
    
    func invalidateViews() {
        self.movies = Array(Movie.getAllMovies())
        
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    // MARK - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.movies[indexPath.row]
        
        cell.movie = movie
//        cell.titleLabel.text = movie.title
        return cell
    }
    
    // MARK - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: self.movieDetailViewControllerSegueId, sender: tableView)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.movieDetailViewControllerSegueId {
            let movieDetailViewController = segue.destination as! MovieDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            print("id: \(self.movies[indexPath!.row].id)")
            movieDetailViewController.movieId = self.movies[indexPath!.row].id
        }
    }

    deinit {
        self.notificationToken?.stop()
    }

}
