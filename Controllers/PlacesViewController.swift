//
//  TagsViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/8/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit

class PlacesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let homeView = HomeViewController()
    
    //stores the tags that the user chooses to use
    var chosenTags : [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self 
        tableView.dataSource = self

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chosenTags.count
    }
    

    
    
    //formats each cell to include a place name and rating
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagNameCell", for: indexPath) as! PlaceNameTableViewCell
        
        //makes the cell look nicer
        cell.layer.cornerRadius = 15
        cell.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha: 0.25).cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 0.0
        cell.layer.masksToBounds = false
        
        cell.placeName.text = chosenTags[indexPath.row]
        
        
        return cell
        
    }
    
}
