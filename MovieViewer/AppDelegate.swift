//
//  AppDelegate.swift
//  MovieViewer
//
//  Created by Zhaolong Zhong on 9/25/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var realm: Realm!
    
    let realmConfig = Realm.Configuration(
        // Set the new Schema version. This must be greater than the previously used version.
        schemaVersion: 0,
        migrationBlock: { migration, oldSchemaVersion in
            migration.deleteData(forType: Movie.className())
        }
    )

    static func getInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Realm.Configuration.defaultConfiguration = realmConfig
        self.realm = try! Realm()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationControllerId") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.movieType = MovieType.nowPlaying
        nowPlayingNavigationController.tabBarItem.title = "Now Playing"
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "movie_icon")
        
        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationControllerId") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.movieType = MovieType.topRated
        topRatedNavigationController.tabBarItem.title = "Top Rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "star_icon")
        
        let favoriteNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationControllerId") as! UINavigationController
        let favoriteViewController = favoriteNavigationController.topViewController as! MoviesViewController
        favoriteViewController.movieType = nil
        favoriteNavigationController.tabBarItem.title = "Favorite"
        favoriteNavigationController.tabBarItem.image = UIImage(named: "heart_icon")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController, favoriteNavigationController]
        tabBarController.tabBar.tintColor = UIColor.orange
        tabBarController.tabBar.barStyle = .black
        tabBarController.tabBar.barTintColor = UIColor.black
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
        
        Genre.sync()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

