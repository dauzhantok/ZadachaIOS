//
//  AllViewController.swift
//  NewsMovie
//
//  Created by Dauzhan Tokpakbayev on 5/22/20.
//  Copyright © 2020 Dauzhan Tokpakbayev. All rights reserved.
//

import UIKit
import Foundation

class AllViewController: UIViewController {

    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var movie: NSDictionary?
        movie = Singleton.shared.giveMovie()
        let title = movie?["title"] as! String
        let date = movie?["release_date"] as! String
        let posterPath = movie?["poster_path"] as! String
        let poster = "https://image.tmdb.org/t/p/w500/\(posterPath)"
        let vot = movie?["vote_average"] as! Double
        let over = movie?["overview"] as! String
        let url = URL(string: poster)
        nameLabel.text = title
        chLabel.text = date
        var vut = String(vot)
        ratingLabel.text = vut
        overviewLabel.text = over
        imgPost.downloadedFrom(url: url!)
    }

}
