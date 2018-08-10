//
//  HomeViewController.swift
//  Trekr
//
//  Created by Ayesha Nabiha on 8/8/18.
//  Copyright © 2018 Ayesha Nabiha. All rights reserved.
//

import UIKit
import Clarifai

class HomeViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    
    var app = ClarifaiApp(apiKey: "b3780911900f448ab1f30a9dc4171787")
    
    //store the tags that Clarifai generate for the image
    var imageTags: [String] = []
    
    var image: UIImage!
    
    //this array holds "clean" tags that can be searchble in the google maps api
    var cleanTags =  ["park", "beach", "restaurant", "hotel", "bar", "coffee", "food", "landmark", "museum", "garden", "vineyard", "bridge", "concert", "cathedral", "religion", "tourism", "tower", "mountain", "historic sites", "shopping", "boutique", "nature", "waterfall", "outdoors", "nature", "scenic", "river", "sunset"]
    
    //this stores the clean tags that go with each picture and what will be used to search Yelp's API
    var searchableTags : [String] = []
    
    var finishedAnalyzing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goButton.isHidden = true
    }
    
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
                        
                        self.imageTags.removeAll()
                        self.searchableTags.removeAll()
                        
                        for concept in caiOutput.concepts {
                            //store the concept names in the tags array
                            self.imageTags.append(concept.conceptName)
                        }
                        DispatchQueue.main.async {
                            
                            //simplify results to what is only to be searched
                            for tag in self.imageTags {
                                if self.cleanTags.contains(tag) && (!self.searchableTags.contains(tag)) {
                                    self.searchableTags.append(tag)
                                }
                            }
                            
                            self.dismiss(animated: true, completion: nil)
                            self.userImage.image = image
                            self.goButton.isHidden = false
                            
                              //if no matches found
                            if self.searchableTags.count == 0 {

                                let alert = UIAlertController(title: "Could not analyze picture", message: "Oops, seems like we couldn't figure out the image. Try another one.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.self.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                    }
                })
                
            }
        }
    }
    
    @IBAction func uploadPhotoButtonPressed(_ sender: Any) {
        presentActionSheet(from: self)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //image picker controller is dismissed
        picker.dismiss(animated: true)
        
        //check to see if an image was passed back in the info dictionary
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            image = selectedImage
            
            recognizeImage(image: selectedImage)
            
            let alert = UIAlertController(title: nil, message: "Analyzing Image...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //hides the image picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "letsGo" {
            if let destination = segue.destination as?  PlacesViewController {
                destination.chosenTags = searchableTags
            }
        }
    }
    
}
