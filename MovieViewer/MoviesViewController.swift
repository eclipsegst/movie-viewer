//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 9/25/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    let TAG = NSStringFromClass(MoviesViewController.self)
    
    let movieCell = "MovieCell"
    let movieCollectionViewCell = "MovieCollectionViewCell"
    let movieDetailViewControllerSegueId = "MovieDetailViewControllerSegueId"
    
    var movieType: MovieType? {
        didSet {
            self.isFavoriteOnly = self.movieType == nil
        }
    }
    var allMovies: [Movie]!
    var movies: [Movie] = []
    var isHearted: Bool = false
    var notificationToken: NotificationToken?
    var realm: Realm? {
        didSet{
            notificationToken = self.realm!.addNotificationBlock({ notification, realm in
                self.invalidateViews()
            })
        }
    }
    var loadingNotification: MBProgressHUD!
    var refreshControl: UIRefreshControl!
    var stackView: UIStackView!
    var errorLabel: UILabel!
    var startTimer: Timer?
    var endTimer: Timer?
    var searchController: UISearchController!
    var searchText: String = "" {
        didSet {
            if self.searchText == oldValue {
                return
            }
            
            invalidateViews()
        }
    }
    var isListView: Bool = true
    var isFavoriteOnly: Bool = false
    
    @IBOutlet var heartButton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var listGridViewBarButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.movieType)
        
        self.realm = AppDelegate.getInstance().realm
        self.allMovies = Array((self.movieType != nil) ? Movie.getMoviesByType(movieType: self.movieType!) : Movie.getAllMovies())
        setupErrorLabel()
        
        // Set up search bar
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.barStyle = .black
        self.searchController.searchBar.tintColor = UIColor.orange
        
        if self.movieType != nil {
            // Set up pull to refresh
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
            
            self.tableView.insertSubview(refreshControl, at: 1)
            self.tableView.tableHeaderView = searchController.searchBar
        }
        self.tableView.register(UINib(nibName: self.movieCell, bundle: nil), forCellReuseIdentifier: self.movieCell)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.backgroundView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        
        // Set up collection view
        self.collectionView.register(UINib(nibName: self.movieCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: self.movieCollectionViewCell)
        self.collectionView.backgroundColor = UIColor.clear
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let screenWidth = UIScreen.main.bounds.width;
        flowLayout.itemSize = CGSize(width: screenWidth/3 - 4, height: 200);
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        self.collectionView.collectionViewLayout = flowLayout

        invalidateViews()
        networkRequest()
    }
    
    func invalidateViews() {
        print("invalidateViews")
        self.tableView.isHidden = !self.isListView
        self.collectionView.isHidden = self.isListView
        
        self.movies = self.searchText == "" ? self.allMovies : self.allMovies.filter({$0.title.lowercased().contains(self.searchText.lowercased())})

        
        if self.isFavoriteOnly {
            self.movies = self.movies.filter({$0.isHearted == true})
        }
        
        if self.isViewLoaded {
            if self.isListView {
                if self.movieType != nil {
                    self.tableView.insertSubview(refreshControl, at: 1)
                }
                
                self.tableView.reloadData()
            } else {
                if self.movieType != nil {
                    self.collectionView.insertSubview(refreshControl, at: 1)
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func listGridViewBarButtonOnClick(_ sender: AnyObject) {
        let listIcon = UIImage(named: "list_icon")
        let collectionIcon = UIImage(named: "collection_icon")
        
        self.isListView = !self.isListView
        self.listGridViewBarButton.image = self.isListView ? listIcon : collectionIcon
        invalidateViews()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.movies[indexPath.row]
        
        cell.movie = movie
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.orange
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.isActive = false
        performSegue(withIdentifier: self.movieDetailViewControllerSegueId, sender: tableView)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UICollectionDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie = self.movies[indexPath.row]
        if let posterPath = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")!
            cell.posterImageView.alpha = 0.0
            cell.posterImageView.setImageWith(url)
            UIView.animate(withDuration: 1, animations: {
                cell.posterImageView.alpha = 1.0
            })
        }
        
        return cell
    }
    
    // MARK: UICollectionDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: self.movieDetailViewControllerSegueId, sender: collectionView)
        self.collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.movieDetailViewControllerSegueId {
            let movieDetailViewController = segue.destination as! MovieDetailViewController
            let indexPath = sender is UITableView ? self.tableView.indexPathForSelectedRow : self.collectionView.indexPathsForSelectedItems?.first
            movieDetailViewController.movieId = self.movies[indexPath!.row].id
        }
    }
    
    // MARK: - refreshControlAction
    func refreshControlAction(refreshControl: UIRefreshControl) {
        networkRequest()
    }
    
    func networkRequest() {
        if self.movieType == nil {
            return
        }
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.bezelView.color = UIColor.orange
        loadingNotification.label.text = "Loading"
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(self.movieType!.rawValue)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        self.startTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(MoviesViewController.showErrorLabel), userInfo: nil, repeats: false)
        self.endTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(MoviesViewController.hideErrorLabel), userInfo: nil, repeats: false)
        let task : URLSessionTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    guard let results = responseDictionary["results"] as? [[String: AnyObject]] else {
                        print("\(self.TAG) : Key 'results' does not exist.")
                        return
                    }
                    
                    let realm = AppDelegate.getInstance().realm!
                    
                    for movieDict in results {
                        let movie = Movie()
                        
                        do {
                            try movie.mapFrom(data: movieDict)
                            
                            if let oldMovie = Movie.getMovieById(id: movie.id) {
                                movie.isHearted = oldMovie.isHearted
                            }
                            
                            movie.movieType = (self.movieType?.rawValue)!
                            try! realm.write {
                                realm.add(movie, update: true)
                            }
                        } catch {
                            print("Error passing movie:\n \(movieDict)")
                        }
                    }
                    
                    self.allMovies = Array((self.movieType != nil) ? Movie.getMoviesByType(movieType: self.movieType!) : Movie.getAllMovies())
                    
                    self.refreshControl.endRefreshing()
                    self.invalidateViews()
                }
            } else {
                print(response)
            }
            
            self.startTimer?.invalidate()
            self.startTimer?.invalidate()
            MBProgressHUD.hide(for: self.view, animated: true)
        })
        task.resume()
    }
    
    // MARK: - setupErrorLabel
    func setupErrorLabel() {
        //Text Label
        self.errorLabel = UILabel()
        self.errorLabel.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.5, blue: 0.0, alpha: 0.95)
        self.errorLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.errorLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        self.errorLabel.text  = "Network Error"
        self.errorLabel.textAlignment = .center
        self.errorLabel.textColor = UIColor.white
        
        //Stack View
        self.stackView = UIStackView()
        self.stackView.axis = UILayoutConstraintAxis.vertical
        self.stackView.distribution  = UIStackViewDistribution.equalSpacing
        self.stackView.alignment = UIStackViewAlignment.center
        self.stackView.spacing = 16.0
        self.stackView.alpha = 0.0
        
        self.stackView.addArrangedSubview(errorLabel)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(stackView)
        
        //self.stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 74.0).isActive = true
        //self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func hideErrorLabel() {
        UIView.animate(withDuration: 0.8, animations: {
            self.stackView.center = CGPoint(x: self.stackView.center.x, y: 0)
            self.stackView.alpha = 0.0
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func showErrorLabel() {
        self.stackView.center = CGPoint(x: self.stackView.center.x, y: 0)
        self.stackView.alpha = 0.0
        
        UIView.animate(withDuration: 0.8, animations: {
            self.stackView.center = CGPoint(x: self.stackView.center.x, y: 84)
            self.stackView.alpha = 0.95
        })
    }

    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.startTimer?.invalidate()
        self.endTimer?.invalidate()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        self.searchText = searchBar.text!
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            searchBar.keyboardType = .numberPad
        default:
            searchBar.keyboardType = .default
        }
        
        searchBar.reloadInputViews()
        searchBar.text = ""
        self.searchText = ""
    }

    deinit {
        self.notificationToken?.stop()
        self.searchController?.view.removeFromSuperview()
    }

}
