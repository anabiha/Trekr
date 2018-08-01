//
//  ListNearbyPlacesTableViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 7/31/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit

//this sets up the home view, when a user first enters the app, they see a table view of places that are nearby to them that are not a result of them inputting a photo, it is simply there for them to peruse
class ListNearbyPlacesTableViewController : UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listPlaces", for: indexPath) as! ListPlacesTableViewCell
        cell.placeName.text = "San Francisco"
        cell.rating.text = "4.5 Stars"
    
        return cell
    }
    
    
}

