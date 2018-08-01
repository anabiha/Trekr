//
//  GooglePlace.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/1/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftyJSON

class GooglePlace {
    
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    var photoReference: String?
    var photo: UIImage?
    
    init(dictionary: [String : Any], acceptedTypes: [String]) {
        let json = JSON(dictionary)
        name = json["name"].stringValue
        address = json["vicinity"].stringValue
        
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        photoReference = json["photos"][0]["photo_reference"].string
        
        let placesToLookFor =  ["park", "beach", "restaurant", "hotel", "bar", "coffee", "food", "landmark", "museum", "garden", "vineyard", "bridge", "religion", "tourism", "tower", "mountain", "historic sites", "shopping", "boutique", "nature"]
        
        let randomNumber = Int(arc4random_uniform(UInt32(placesToLookFor.count-1)))
        var place = placesToLookFor[randomNumber]
        
        if let types = json["types"].arrayObject as? [String] {
            for type in types {
                if placesToLookFor.contains(type) {
                    place = type
                    break
                }
            }
           
        }
        placeType = place
    }
}
