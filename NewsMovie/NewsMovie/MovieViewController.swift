//
//  MovieViewController.swift
//  NewsMovie
//
//  Created by Dauzhan Tokpakbayev on 5/21/20.
//  Copyright © 2020 Dauzhan Tokpakbayev. All rights reserved.
//
import Foundation
import UIKit

//struct Popular: Decodable {
//    let page: Int
//    let results: [Results]
//}
//struct Results: Decodable {
//    let popularity: Double
//    let poster_path: String?
//    let id: Int
//    let adult: Bool
//    let original_title: String?
//    let original_language: String?
//    let overview: String?
//
//}
extension UIImageView {
    func downloadedFrom (url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
        }
        }.resume()
    }
    func downloadedFrom (link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom ( url: url, contentMode: mode)
    }
}
class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()

    var activityIndicator:UIActivityIndicatorView? = nil
    var movies: [NSDictionary]?
    var limit = 20
    var page = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.viewWillAppear(true)
        tableView.dataSource = self
        tableView.delegate = self
        findMovie(page: page)
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        let da = (movies?.count ?? 0)
        print(da)
        if da==limit{
            if indexPath.row == da - 1 {
                if page<501{
                    limit=limit+20
                    page=page+1
                    reloadAndScrollToTop()
                    findMovie(page: page)
                }
                self.perform(#selector(loadTable), with: nil, afterDelay: 10)
            }
        }
       
    }
    @objc func loadTable(){
        
        self.tableView.reloadData()
    }
    func reloadAndScrollToTop() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath ) as! MovieTableViewCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let date = movie["release_date"] as! String
        let posterPath = movie["poster_path"] as! String
        let poster = "https://image.tmdb.org/t/p/w500/\(posterPath)"
        let url = URL(string: poster)
        cell.titleLabel.text=title
        cell.dateLabel.text=date
        cell.posterView.downloadedFrom(url: url!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies![indexPath.row]
        Singleton.shared.movie=movie
        performSegue(withIdentifier: "showDetails", sender: self)
        
        
        
    }
    
    func findMovie(page: Int) {
        let urlS = "https://api.themoviedb.org/3/movie/popular?api_key=c49507d388cc6c120b5d01c02a3ba222&language=en-US&page=\(page)"
        let url = NSURL(string: urlS)
        let request = URLRequest(url: url! as URL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 20)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: {( dataOrNil, responds, error) in
            guard let data = dataOrNil else {return}
            guard error == nil else {return}
            if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{
               // print("respone: \(responseDictionary)")
                self.movies = responseDictionary["results"] as? [NSDictionary]
                self.tableView.reloadData()
            }
            
        })
        task.resume()
    }
    
}
final class Singleton {
    static let shared = Singleton()

    private init(){
        
    }
    var movie: NSDictionary?

    func giveMovie() -> NSDictionary? {
        return movie
    }
}
//guard let url = NSURL(string: urlS) else {return}
//URLSession.shared.dataTask(with:  url) {( data, responds, error) in
//    guard let data = data else {return print("a")}
//    guard error == nil else {return print("gg")}
//
//    do{
//        let decoder = JSONDecoder()
//        self.movies = try decoder.decode(Popular.self, from: data) as? [NSDictionary]
//
//    } catch let error{
//        print(error)
//    }
//
//}.resume()
