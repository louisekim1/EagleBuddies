//
//  Buddies.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/11/21.
//

import Foundation
import Firebase

class Buddies {
    var buddyArray: [Buddy] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () ->  ()) {
        db.collection("buddies").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
            return completed()
            }
            self.buddyArray = [] // clean out existing buddyArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let buddy = Buddy(dictionary: document.data())
                buddy.documentID = document.documentID
                self.buddyArray.append(buddy)
            }
            completed()
        }
    }
}

