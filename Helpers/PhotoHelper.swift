//
//  PhotoHelper.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/1/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import Clarifai
import Alamofire
import SwiftyJSON

/*
 This class will present the popover to allow the user to choose between taking a new photo or selecting one from the photo library, which will either result in presenting the camera or photo library. It will also return the image that the user has taken or selected
 */

class PhotoHelper: NSObject {
    
    var completionHandler: ((UIImage) -> Void)?
    
    var app = ClarifaiApp(apiKey: "b3780911900f448ab1f30a9dc4171787")
    
    var tags : [String] = []
    
    //this array holds "clean" tags that can be searchble in the google maps api
    var cleanTags =  ["park", "beach", "restaurant", "hotel", "bar", "coffee", "food", "landmark", "museum", "garden", "vineyard", "bridge", "concert", "cathedral", "religion", "tourism", "tower", "mountain", "historic sites", "shopping", "boutique", "nature"]
    
    //this method uses Clarifai API to return tags that describe the image
    func recognizeImage(image: UIImage) -> [String] {
        //check that the app was initialized correctly
        if let app = app {
            //fetch Clarifai's general model
            app.getModelByName("general-v1.3") { (model, error) in
                //create a Clarifai image from an UIImage
                let caiImage = ClarifaiImage(image: image)!
                //use Clarifai's general model to predict tags for a given image
                model?.predict(on: [caiImage], completion: { (outputs, error) in
                    print("%@", error ?? "no error")
                    guard let caiOutputs = outputs else {
                        print("Predict failed")
                        return
                    }
                    if let caiOutput = caiOutputs.first {
                        for concept in caiOutput.concepts {
                            //store the concept names in the tags array
                            self.tags.append(concept.conceptName)
                        }
                    }
                })
            }
        }
        return tags
    }
    
}
