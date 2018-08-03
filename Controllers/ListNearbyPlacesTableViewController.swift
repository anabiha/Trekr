//
//  ListNearbyPlacesTableViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 7/31/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import CoreLocation

/**
 This sets up the home view, when a user first enters the app, they see a table view of places that are nearby to them that are not a result of them inputting a photo, it is simply there for them to see places that are nearby them
 **/

class ListNearbyPlacesTableViewController : UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //to track the user's location
    private let locationManager = CLLocationManager()
    var locValue : CLLocationCoordinate2D!
    
    //to store the results of the places near the users
    var businesses: [CDYelpBusiness] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var imageTags: [String] = []
    
    //allows to access Clarifai
    let photoHelper = PhotoHelper()
    
    //sets up the client that will communicate with Yelp
    private let yelpAPIClient = CDYelpAPIClient(apiKey:"jLXjDlnpU3aVVE0FSiObtMMMIRGp9b_Ro3YLMSmHSTASWs8nzoEx-XIkOuHG4s5IbkvbnWIvKjkhViQbUJ1NC7FMwXwEQ1QIPe4Vg-OxG2QL-snTD-UI897Z5TxjW3Yx")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
      
        
        tableView.delegate = self
        tableView.dataSource = self
        
        findPlaces(lat: 37.773514, lng: -122.417807)
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()

    }
    
     /** THE FOLLOWING METHODS ARE RELEVANT TO IBACTIONS AND USER INTERACTION **/
    
    //when the camera button is pressed, the user is presented with a picker controller that allows them to upload a photo from their photo library, this then goes through the image analysis and leads to a view that presents user with customized results
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.delegate = self
            present(picker, animated: true, completion: nil)
            
        }
        
    }
    
    //after the user picks an image, send it to Clarifai for recognition and move to the next view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
      
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageTags = photoHelper.recognizeImage(image: image)
        }
        
        dismiss(animated: true, completion: nil)
        
        //present the next view controller after analyzing image
        let customPlaces = CustomizedResultsViewController()
        self.navigationController?.pushViewController(customPlaces, animated: true)
        
    }
    
    //refresh location status while user is still in app (if user travels somewhere else while the app is open)
    @IBAction func refreshButtonPressed(_ sender: Any) {

    }
    
     /** THE FOLLOWING METHODS ARE RELEVANT TO CREATING AND MANIPULATING THE DATA **/
    
    //accesses Yelp Search API to find a generic list of places near them
    func findPlaces(lat: Double, lng: Double) {
        
        var results: [CDYelpBusiness] = []
        
        //cancel any API request previosuly made
        yelpAPIClient.cancelAllPendingAPIRequests()
        
        //query Yelp Fusion API for business result
        yelpAPIClient.searchBusinesses(byTerm: nil , location: nil, latitude: lat, longitude: lng, radius: 10000, categories: nil, locale: nil, limit: 25, offset: 0, sortBy: nil , priceTiers: nil, openNow: nil, openAt: nil, attributes: nil) { (response) in
            
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
    
    //formats each cell to include an image, place name, and rating
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listPlaces", for: indexPath) as! ListPlacesTableViewCell
        
        cell.placeName.text = businesses[indexPath.row].name
        cell.rating.text = businesses[indexPath.row].rating?.description
        
     
        return cell
        
     }
    
    //sets the cell height for the tableview
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    /** THE FOLLOWING METHODS ARE RELEVANT TO LOCATION PERMISSIONS AND DATA **/
    
    //called when the user grants or revokes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        
    }
    
    //executes when the location manager recieves new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location?.coordinate
    }
    
    //if there is any location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
}


