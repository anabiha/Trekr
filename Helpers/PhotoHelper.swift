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
    
    var image : UIImage!
    
    //this method uses Clarifai API to return tags that describe the image
    func recognizeImage(image: UIImage) {
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
    }
    
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
        //present the UIAlertCOntroller from the UIViewController
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        //create a new instatnce of UIImagePickerController, this object will present a native UI component that will allow the user to take a photo from the camera or choose an existing image from their photo library
        let imagePickerController = UIImagePickerController()
        //set the source type to determine whether the UIImagePickerController will activate the camera and display a photo taking overlay ot show the user's photo library.
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        //after imagePickerController is initialized and configured, it is presented to the view controller
        viewController.present(imagePickerController, animated: true)
    }
    
}

extension PhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //image picker controller is dismissed
        picker.dismiss(animated: true)
        
        //check to see if an image was passed back in the info dictionary
        if let selctedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //if so, the image is passed the completionHandler property
            completionHandler?(selctedImage)
            //recognizeImage(image: selctedImage)
            image = selctedImage
        }
    }
    
    //hides the image picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}





