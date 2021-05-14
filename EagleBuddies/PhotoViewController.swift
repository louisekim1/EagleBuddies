//
//  PhotoViewController.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/13/21.
//

import UIKit
import Firebase
import SDWebImage

class PhotoViewController: UIViewController {
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var buddy: Buddy!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard buddy != nil else {
            print("ERROR: No photo passed to PhotoViewController.swift")
            return
        }
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        if photo.documentID == "" { // This is a new photo
        } else {
            if photo.photoUserID == Auth.auth().currentUser?.uid { // photo posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                self.navigationController?.setToolbarHidden(false, animated: true)
            } else { // photo posted by different user
                saveBarButton.hide()
                cancelBarButton.hide()
                
            }
        }
        guard let url = URL(string: photo.photoURL) else {
            // Then this must be a new image
            photoImageView.image = photo.image
            return
        }
        photoImageView.sd_imageTransition = .fade
        photoImageView.sd_imageTransition?.duration = 0.5
        photoImageView.sd_setImage(with: url)
    }
    
    func updateFromUserInterface() {
        photo.image = photoImageView.image!
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        photo.deleteData(buddy: buddy) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR:")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        photo.saveData(buddy: buddy) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: Can't unwind segue from PhotoViewController because of photo saving error.")
            }
        }
    }
}
