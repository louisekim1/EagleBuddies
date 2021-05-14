//
//  BuddyDetailViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit
import Firebase
import SDWebImage

class BuddyDetailViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var buddy: Buddy!
    var comments: Comments!
    var photo: Photo!
    var photos: Photos!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePickerController.delegate = self
        
        if buddy == nil {
            buddy = Buddy()
        } else {
            disableTextEditing()
            cancelBarButton.hide()
            saveBarButton.hide()
            navigationController?.setToolbarHidden(true, animated: true)
        }
        comments = Comments()
        photos = Photos()
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if buddy.documentID != "" {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        comments.loadData(buddy: buddy) {
            self.tableView.reloadData()
        }
    }
    
    func updateUserInterface() {
        nameTextField.text = buddy.name
        yearTextField.text = buddy.grade
        memberTextField.text = buddy.members
        descriptionTextView.text = buddy.description
        
        if buddy.documentID == "" { // this is a new review
            addBordersToEditableObjects()
        } else {
            if buddy.postingUserID == Auth.auth().currentUser?.uid  { // review posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                //     deleteBarButton.isHidden = false
            } else { // review posted by different user
                saveBarButton.hide()
                cancelBarButton.hide()
            }
            nameTextField.isEnabled = false
            nameTextField.borderStyle = .none
            yearTextField.isEnabled = false
            yearTextField.borderStyle = .none
            memberTextField.isEnabled = false
            memberTextField.borderStyle = .none
            descriptionTextView.isEditable = false
            nameTextField.backgroundColor = .white
            memberTextField.backgroundColor = .white
            yearTextField.backgroundColor = .white
            descriptionTextView.backgroundColor = .white
        }
    }
    
    func updateFromInterface() {
        buddy.name = nameTextField.text ?? ""
        buddy.grade = yearTextField.text ?? ""
        buddy.members = memberTextField.text ?? ""
        buddy.description = descriptionTextView.text ?? ""
    }
    
    func addBordersToEditableObjects() {
        descriptionTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func disableTextEditing() {
        nameTextField.isEnabled = false
        yearTextField.isEnabled = false
        memberTextField.isEnabled = false
        descriptionTextView.isEditable = false
        nameTextField.backgroundColor = .clear
        yearTextField.backgroundColor = .clear
        memberTextField.backgroundColor = .clear
        descriptionTextView.backgroundColor = .clear
        nameTextField.borderStyle = .none
        yearTextField.borderStyle = .none
        memberTextField.borderStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromInterface()
        switch segue.identifier ?? "" {
        case "AddComment":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as!
                CommentTableViewController
            destination.buddy = buddy
        case "ShowComment":
            let destination = segue.destination as! CommentTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.comment = comments.commentArray[selectedIndexPath.row]
            destination.buddy = buddy
        case "AddPhoto":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as!
                PhotoViewController
            destination.buddy = buddy
            destination.photo = photo
        case "ShowPhoto":
            let destination = segue.destination as! PhotoViewController
            guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
                print("ERROR: couldn't get selected collectionView item")
                return
            }
            destination.photo = photos.photoArray[selectedIndexPath.row]
            destination.buddy = buddy
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier). This should not have happened!")
        }
    }
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.buddy.saveData { (success) in
                self.saveBarButton.title  = "Done"
                self.cancelBarButton.hide()
                self.navigationController?.setToolbarHidden(true, animated: true)
                self.disableTextEditing()
                if segueIdentifier ==  "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
                    // self.cameraOrLibraryAlert()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        let noSpaces = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func yearFieldChanged(_ sender: UITextField) {
        let noSpaces = yearTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func memberFieldChanged(_ sender: UITextField) {
        let noSpaces = memberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        buddy.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                // ERROR during save occured
                self.oneButtonAlert(title: "😡 Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        if buddy.documentID == "" {
            saveCancelAlert(title: "This group has not been saved", message: "You must save the group before you add a comment", segueIdentifier: "AddComment")
        } else {
            performSegue(withIdentifier: "AddComment", sender: nil)
        }
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if buddy.documentID == "" {
            saveCancelAlert(title: "This Group Has Not Been Saved", message: "You must save this group before you can commment on it", segueIdentifier: "AddPhoto")
        } else {
            cameraOrLibraryAlert()
        }
    }
}

extension BuddyDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.commentArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        cell.textLabel?.text = comments.commentArray[indexPath.row].commentTitle
        return cell
    }
}

extension BuddyDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! BuddyPhotoCollectionViewCell
        photoCell.buddy = buddy
        photoCell.photo = photos.photoArray[indexPath.row]
        return photoCell
    }
}

extension BuddyDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        photo = Photo()
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = originalImage
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "AddPhoto", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            self.oneButtonAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}

//    func updatePictures() {
//        if photo.documentID == "" { // This is a new photo
//            addBordersToEditableObjects()
//        } else {
//            if photo.photoUserID == Auth.auth().currentUser?.uid { // photo posted by current user
//                self.navigationItem.leftItemsSupplementBackButton = false
//                saveBarButton.title = "Update"
//                addBordersToEditableObjects()
//                self.navigationController?.setToolbarHidden(false, animated: true)
//            } else { // photo posted by different user
//                saveBarButton.hide()
//                cancelBarButton.hide()
//                descriptionTextView.isEditable = false
//                descriptionTextView.backgroundColor = .white
//            }
//        }
//        guard let url = URL(string: photo.photoURL) else {
//            // Then this must be a new image
//            photoImageView.image = photo.image
//            return
//        }
//        photoImageView.sd_imageTransition = .fade
//        photoImageView.sd_imageTransition?.duration = 0.5
//        photoImageView.sd_setImage(with: url)
//    }
