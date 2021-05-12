//
//  Photos.swift
//  Snacktacular
//
//  Created by Louise Kim on 4/25/21.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init()  {
        db = Firestore.firestore()
    }
    
    func loadData(buddy: Buddy, completed: @escaping () ->  ()) {
        guard buddy.documentID != "" else {
            return
        }
        db.collection("buddies").document(buddy.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
            return completed()
            }
            self.photoArray = [] // clean out existing photoArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
        }
    }
    
}

