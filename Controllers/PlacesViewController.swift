//
//  TagsViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/8/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import CoreLocation

class PlacesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    //sets up the client that will communicate with Yelp
    private let yelpAPIClient = CDYelpAPIClient(apiKey:"jLXjDlnpU3aVVE0FSiObtMMMIRGp9b_Ro3YLMSmHSTASWs8nzoEx-XIkOuHG4s5IbkvbnWIvKjkhViQbUJ1NC7FMwXwEQ1QIPe4Vg-OxG2QL-snTD-UI897Z5TxjW3Yx")
    
    //stores the tags that the user chooses to use
    var chosenTags : [String] = []
    
    let yelpRatings : [Double: UIImage] = [0.0: #imageLiteral(resourceName: "stars_regular_0"), 1.0: #imageLiteral(resourceName: "stars_regular_1"), 1.5: #imageLiteral(resourceName: "stars_regular_1_half"),2.0: #imageLiteral(resourceName: "stars_regular_2"), 2.5: #imageLiteral(resourceName: "stars_regular_2_half"),3.0: #imageLiteral(resourceName: "stars_regular_3"),3.5: #imageLiteral(resourceName: "stars_regular_3_half"),4.0: #imageLiteral(resourceName: "stars_regular_4"),4.5: #imageLiteral(resourceName: "stars_regular_4_half"),5.0: #imageLiteral(resourceName: "stars_regular_5")]
    
    let homeView = HomeViewController()
    
    //to store the results of the places near the users
    var yelpResults: [CDYelpBusiness] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    //    for tag in chosenTags {    37.773514, -122.417807
           findPlaces(lat: 37.773514, lng: -122.417807 , keyword: chosenTags.first!)
            
   //     }
        
        tableView.delegate = self 
        tableView.dataSource = self
        
        backButton.layer.cornerRadius = 15
        backButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha: 0.25).cgColor
        backButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        backButton.layer.shadowOpacity = 1.0
        backButton.layer.shadowRadius = 0.0
        backButton.layer.masksToBounds = false
        

        
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//    }
    
    //accesses Yelp Search API to find a list of 5 places corresponding to the keyword
    func findPlaces(lat: Double, lng: Double, keyword: String) {
        
        var results: [CDYelpBusiness] = []
        
        //cancel any API request previosuly made
      //  yelpAPIClient.cancelAllPendingAPIRequests()
        
        //query Yelp Fusion API for business result
        yelpAPIClient.searchBusinesses(byTerm: keyword , location: nil, latitude: lat, longitude: lng, radius: 10000, categories: nil, locale: nil, limit: 25, offset: 0, sortBy: nil , priceTiers: nil, openNow: nil, openAt: nil, attributes: nil) { (response) in
            
            results = (response?.businesses)!
            
            for place in results {
                self.yelpResults.append(place)
            }
        }
        
        results.removeAll()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yelpResults.count
    }
    
    
    @IBAction func unwindToHomeView(segue:UIStoryboardSegue) {
        
    }

    

    
    
    //formats each cell to include a place name and rating
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeNameCell", for: indexPath) as! PlaceNameTableViewCell
        
        //makes the cell look nicer
        cell.layer.cornerRadius = 15
        cell.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha: 0.25).cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 0.0
        cell.layer.masksToBounds = false
        
        cell.placeName.text = yelpResults[indexPath.row].name
        
        let yelpRating = yelpResults[indexPath.row].rating!
        
        cell.rating.image = yelpRatings[yelpRating]
        
        
        return cell
        
    }
    
}
