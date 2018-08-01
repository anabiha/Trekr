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
    
    func presentActionSheet(from viewController: UIViewController) {
        //initialize a new UIAlertController that be used to present different types of alerts (action sheet is a popup that will be displayed at the bottom edge of the screen
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        //check if the current device has a camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //create a new UIAlertSction
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {action in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            //add the action to the alertController instance
            alertController.addAction(capturePhotoAction)
        }
        //do the same steps as above for the user's photo library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: {action in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            alertController.addAction(uploadAction)
        }
        //add a cancel action to allow a user to close the action sheet
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        //present the UIAlertController from the UIViewController
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        //create a new instatnce of UIImagePickerController, this object will present a native UI component that will allow the user to take a photo from the camera or choose an existing image from their photo library
        let imagePickerController = UIImagePickerController()
        //set the source type to determine whether the UIImagePickerController will activate the camera and display a photo taking overlay or show the user's photo library.
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        //after imagePickerController is initialized and configured, it is presented to the view controller
        viewController.present(imagePickerController, animated: true)
    }
    
}

extension PhotoHelper: UINavigationBarDelegate, UIImagePickerControllerDelegate {
    
    //hides the image picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //after the user picks an image, send it to Clarifai for recognition
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //image picker controller is dismissed
            picker.dismiss(animated: true, completion: nil)
            recognizeImage(image: image)
        }
    }
    
    func recognizeImage(image: UIImage) {
        //check that the app was initialized correctly
        if let app = app {
            //fetch Clarifai's general model
            app.getModelByName("general-v1.3", completion: { (model, error) in
                //create a Clarifai image from a uimage
                let caiImage = ClarifaiImage(image: image)!
                //use Clarifai's general model to predict tags for a given image
                model?.predict(on: [caiImage], completion: { (outputs, error) in
                    print("%@", error ?? "no error")
                    guard let caiOutputs = outputs else {
                        print("Predict failed")
                        return
                    }
                    if let caiOutput = caiOutputs.first {
                        //loop through predicted concepts (tags) and display them on the screen
                        for concept in caiOutput.concepts {
                            self.tags.append(concept.conceptName)
                        }
                        print(self.tags)
                        DispatchQueue.main.async {
                        
                        }
                        DispatchQueue.main.async {
                            self.findPlace(input: self.cleanTags.first!, completion: { (image, url) in
                                //self.imageView.image = image
                            })
                            //self.makeSearch()
                            self.tags.removeAll()
                        }
                        
                    }
                })
            })
        }
    }
    
    func findPlace(input: String, completion: @escaping(UIImage, String) -> Void) {
        
        let strUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=\(input)&keyword=\(input)&key=AIzaSyA0anuwocMn289O95ScN1TnQ0Fwv68PbJk"
        
        Alamofire.request(strUrl).responseJSON { (response) in
            if response.result.isSuccess {
                let searchResult : JSON = JSON(response.result.value!)
                let imageResult = searchResult["results"][0]["icon"].string!
                Alamofire.request(imageResult).responseData(completionHandler: { (response) in
                    if response.result.isSuccess {
                        let image = UIImage(data: response.result.value!)
                        completion(image!, imageResult)
                    } else {
                        print("Image Load Failed! \(response.result.error ?? "error" as! Error)")
                    }
                })
            } else {
                print("Google Maps Search Failed! \(response.result.error ?? "error" as! Error)")
            }
        }
    }
    
}
