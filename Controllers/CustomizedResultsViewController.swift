//
//  CustomizedResultsViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/2/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import Clarifai
import Alamofire
import SwiftyJSON

/*
 This sets up the view users will see after the press the camera button, send a picture/take a picture, and have the picture recognized. Users will be presented a table view of places that match their tags 
 */

class CustomizedResultsViewController: UITableViewController, UIImagePickerControllerDelegate {
    
    var app: ClarifaiApp?
    
    let accessTags = ListNearbyPlacesTableViewController()
    var tags : [String] = []
    
    //to store the results of the places near the users
    var businesses: [CDYelpBusiness] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //these are the tags that are going to go into the Yelp API that are derived from the original tags of the picture
    var searchableTags = ["park", "beach", "restaurant", "hotel", "bar", "coffee", "food", "landmark", "museum", "garden", "vineyard", "bridge", "concert", "cathedral", "religion", "tourism", "tower", "mountain", "historic sites", "shopping", "boutique", "nature"]
    
    private let yelpAPIClient = CDYelpAPIClient(apiKey:"jLXjDlnpU3aVVE0FSiObtMMMIRGp9b_Ro3YLMSmHSTASWs8nzoEx-XIkOuHG4s5IbkvbnWIvKjkhViQbUJ1NC7FMwXwEQ1QIPe4Vg-OxG2QL-snTD-UI897Z5TxjW3Yx")
    
    //var yelpTags : [String] = []
    
    var yelpTag = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tags = accessTags.imageTags
        
        for tag in tags {
            if searchableTags.contains(tag) {
                yelpTag = tag
            }
        }
        
        findCustomizedPlaces(keyword: yelpTag, lat: 37.773514, lng: -122.417807)
        
    }
    
    func findCustomizedPlaces(keyword: String, lat: Double, lng: Double) {
        
        var results: [CDYelpBusiness] = []
        
        //cancel any API request previosuly made
        yelpAPIClient.cancelAllPendingAPIRequests()
        
        //query Yelp Fusion API for business result
        yelpAPIClient.searchBusinesses(byTerm: keyword, location: nil , latitude: lat, longitude: lng, radius: 10000, categories: nil, locale: nil, limit: 25, offset: 0, sortBy: .rating, priceTiers: nil, openNow: true, openAt: nil, attributes: nil) { (response) in
            
            results = (response?.businesses)!
            
            for place in results {
                self.businesses.append(place)
            }
        }
        results.removeAll()
    }
    
    
    /** THE FOLLOWING METHODS ARE RELEVANT TO TABLEVIEWS AND SHOWING DATA IN CELLS **/
    
    //sets the number of cells that the user will see
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    //formats each cell to include a place name and rating
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPlaces", for: indexPath) as! CustomizedPlacesTableViewCell
        
        cell.placeName.text = businesses[indexPath.row].name
        cell.rating.text = businesses[indexPath.row].rating?.description
        
        
        return cell
        
    }
    
    //sets the cell height for the tableview
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
