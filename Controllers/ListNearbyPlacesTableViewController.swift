//
//  ListNearbyPlacesTableViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 7/31/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

/*
 This sets up the home view, when a user first enters the app, they see a table view of places that are nearby to them that are not a result of them inputting a photo, it is simply there for them to see places that are nearby them
 */
class ListNearbyPlacesTableViewController : UITableViewController{
    
    var placesClient : GMSPlacesClient!
    
    private let locationManager = CLLocationManager()
    
    let placesToLookFor =  ["park", "beach", "restaurant", "hotel", "bar", "coffee", "food", "landmark", "museum", "garden", "vineyard", "bridge", "concert", "cathedral", "religion", "tourism", "tower", "mountain", "historic sites", "shopping", "boutique", "nature"]
    
    var name = ""
    var address = ""
    var image: UIImage!
    
    //to make calls to the Google Places API
    private let dataProvider = GooglePlaceData()
    //how far out from the user's location the API will search for locations
    private let searchRadius: Double = 1000
    
    let photoHelper = PhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //error here
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        //present the action sheet from photoHelper to allow user to capture a photo from their camera or upload a photo from their photo library
        photoHelper.presentActionSheet(from: self)
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        fetchNearbyPlaces(coordinate: (locationManager.location?.coordinate)!)
    }
    
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        //use dataProvider to query Google for nearby places within the searchRadius filtered to the user's selected types
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius: searchRadius, types: placesToLookFor) { places in
            //iterate through the results returned in the completion closure
            for place in places {
                self.name = place.name
                self.address = place.address
                self.image = place.photo!
            }
        }
    }

    //sets the number of cells that the user will see
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //formats each cell
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listPlaces", for: indexPath) as! ListPlacesTableViewCell
        
        fetchNearbyPlaces(coordinate: (locationManager.location?.coordinate)!)
        
        cell.placeName.text = name
        cell.rating.text = address
        cell.imageView?.image = image
     
        return cell
     }
    
    //sets the cell height for the tableview
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

extension ListNearbyPlacesTableViewController : CLLocationManagerDelegate {
    
    //called when the user grants or revokes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    //executes when the location manager recieves new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location: \(location)")
        }
        //fetchNearbyPlaces(coordinate: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}


