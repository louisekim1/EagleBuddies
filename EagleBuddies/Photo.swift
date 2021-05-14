//
//  Photo.swift
//  Snacktacular
//
//  Created by Louise Kim on 4/25/21.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var photoUserID: String
    var photoUserEmail: String
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "photoURL": photoURL]
    }
    
    init(image: UIImage, photoUserID: String, photoUserEmail: String, photoURL: String, documentID: String) {
        self.image = image
        self.photoUserID = photoUserID
        self.photoUserEmail  = photoUserEmail
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), photoUserID: photoUserID, photoUserEmail: photoUserEmail, photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        
        self.init(image: UIImage(), photoUserID: photoUserID, photoUserEmail: photoUserEmail, photoURL: photoURL, documentID: "")
    }
    
    func saveData(buddy: Buddy, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Could not convert photo.image to Data")
            return
        }
        
        let uploadMetaData =  StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        if documentID == "" {
            documentID == UUID().uuidString
        }
        
        let storageRef = storage.reference().child(buddy.documentID).child(documentID)
        
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("ERROR: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was successful!")
        
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: Couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("ERROR: url was nil and this should not have happened because we've already shown there was no error.")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                // Create the dictionary representing data we want to save
                let dataToSave = self.dictionary
                let ref = db.collection("buddies").document(buddy.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID) in spot: \(buddy.documentID)") // It worked!
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentID) failed, in buddy \(buddy.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(buddy: Buddy, completion: @escaping (Bool) -> ()) {
        guard buddy.documentID != "" else {
            print("ERROR: did not pass a valid spot into loadImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(buddy.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error  {
                print("Error: an error occured while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    func deleteData(buddy: Buddy, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("buddies").document(buddy.documentID).collection("photos").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                self.deleteImage(buddy: buddy)
                    completion(true)
            }
        }
    }
    private func deleteImage(buddy: Buddy) {
        guard buddy.documentID != "" else {
            print("ERROR")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(buddy.documentID).child(documentID)
        storageRef.delete { error in
            if let error = error  {
                print("ERROR")
            } else {
                print("SUCCESS")
            }
        }
    }
}
