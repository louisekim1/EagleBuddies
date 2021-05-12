//
//  BuddyDetailViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit
import Contacts
import GooglePlaces
import MapKit

class BuddyDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var buddy: Buddy!
    var comments: Comments!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if buddy == nil {
            buddy = Buddy()
        }
        comments = Comments()
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameTextField.text = buddy.name
        yearTextField.text = buddy.grade
        memberTextField.text = buddy.members
        descriptionTextView.text = buddy.description
    }
    
    func updateFromInterface() {
        buddy.name = nameTextField.text ?? ""
        buddy.grade = yearTextField.text ?? ""
        buddy.members = memberTextField.text ?? ""
        buddy.description = descriptionTextView.text ?? ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromInterface()
        switch segue.identifier ?? "" {
        case "AddComment":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as!
                CommentTableViewController
            destination.buddy = buddy
        case "ShowReview":
            let destination = segue.destination as! CommentTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.comment = comments.commentArray[selectedIndexPath.row]
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
//                self.cancelBarButton.hide()
                self.navigationController?.setToolbarHidden(true, animated: true)
//                self.disableTextEditing()
                if segueIdentifier ==  "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
//                    self.cameraOrLibraryAlert()
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
}

extension BuddyDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.commentArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        return cell
    }
}

