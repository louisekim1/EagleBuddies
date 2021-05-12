//
//  BuddyListViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit

class BuddyListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var buddies: Buddies!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buddies = Buddies()
        tableView.dataSource = self
        tableView.delegate = self
        configureSegmentedControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buddies.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
    }
    
    func configureSegmentedControl() {
        // set font colors for segmented control
        let buttonFontColor = [NSAttributedString.Key.foregroundColor : UIColor(named: "Toolbar") ?? UIColor.orange]
        let whiteFontColor =  [NSAttributedString.Key.foregroundColor : UIColor.white]
        sortSegmentedControl.setTitleTextAttributes(buttonFontColor, for: .selected)
        sortSegmentedControl.setTitleTextAttributes(whiteFontColor, for: .normal)
        
        // add white border to segmented control
        sortSegmentedControl.layer.borderColor = UIColor.white.cgColor
        sortSegmentedControl.layer.borderWidth = 1.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! BuddyDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.buddy = buddies.buddyArray[selectedIndexPath.row]
        }
    }
    
    func sortBasedOnSegmentPressed() {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0: // young to old
            buddies.buddyArray.sort(by: {$0.grade < $1.grade})
        case 1: // old to young
            buddies.buddyArray.sort(by: {$1.grade < $0.grade})
        default:
            print("Hey! You shouldn't have gotten here. Check out the segmented control for an error!")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
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
