//
//  Buddy.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/11/21.
//

import Foundation
import Firebase

class Buddy {
    var name: String
    var grade: String
    var members: String
    var description: String
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "grade": grade,
                "members": members, "description": description, "postingUserID": postingUserID]
    }
    
    init(name: String, grade: String, members: String, description: String, postingUserID: String, documentID: String) {
        self.name = name
        self.grade = grade
        self.members =  members
        self.description = description
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", grade: "", members: "", description: "", postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let grade = dictionary["grade"] as! String? ?? ""
        let members = dictionary["members"] as! String? ?? ""
        let description = dictionary["description"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, grade: grade, members: members, description: description, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have  an ID, otherwise  .addDocument will create one.
        if self.documentID == "" { // Create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)") // It worked!
                completion(true)
            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)") // It worked!
                completion(true)
            }
        }
    }
}
