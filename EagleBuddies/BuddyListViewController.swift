//
//  BuddyListViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit

class BuddyListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var buddies: Buddies!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buddies = Buddies()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buddies.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! BuddyDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.buddy = buddies.buddyArray[selectedIndexPath.row]
        }
    }
}

extension BuddyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.buddyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = buddies.buddyArray[indexPath.row].name
        cell.detailTextLabel?.text = buddies.buddyArray[indexPath.row].grade
        return cell
        
    }
}
