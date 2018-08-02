//
//  CustomizedResultsViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/2/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import CDYelpFusionKit

class CustomizedResultsViewController: UITableViewController {
    
    private let yelpAPIClient = CDYelpAPIClient(apiKey:"jLXjDlnpU3aVVE0FSiObtMMMIRGp9b_Ro3YLMSmHSTASWs8nzoEx-XIkOuHG4s5IbkvbnWIvKjkhViQbUJ1NC7FMwXwEQ1QIPe4Vg-OxG2QL-snTD-UI897Z5TxjW3Yx")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func findCustomizedPlaces(keyword: String, lat: Double, lng: Double) {
        //cancel any API request previosuly made
        yelpAPIClient.cancelAllPendingAPIRequests()
        //query Yelp Fusion API for business result
        yelpAPIClient.searchBusinesses(byTerm: keyword, location: "San Francisco", latitude: lat, longitude: lng, radius: 10000, categories: nil, locale: .english_unitedStates, limit: 5, offset: 0, sortBy: .rating, priceTiers: [.oneDollarSign, .twoDollarSigns], openNow: true, openAt: nil, attributes: nil) { (response) in
            if let response = response,
                let businesses = response.businesses,
                businesses.count > 0 {
                print(businesses.first?.name)
            }
        }
    }
    
    
}
