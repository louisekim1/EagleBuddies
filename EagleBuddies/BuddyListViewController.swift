//
//  BuddyListViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit

class BuddyListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var buddies = ["1", "2", "3"]
    var grade = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension BuddyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = buddies[indexPath.row]
        cell.detailTextLabel?.text = grade[indexPath.row]
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowDetail" {
//            let destination = segue.destination as! BuddyDetailViewController
//            let selectedIndexPath = tableView.indexPathForSelectedRow!
//            destination.buddy = buddies.buddyArray[selectedIndexPath.row]
//        }
//    }
}
