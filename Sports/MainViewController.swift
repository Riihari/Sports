//
//  ViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 15.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UITableViewController {
    var workouts: [String] = ["one", "two", "three"]
    let healthMgr: HealthManager = HealthManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        healthMgr.authorizeHealthKit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Starting")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcellid", for: indexPath)
        
        cell.textLabel?.text = workouts[indexPath.row]
        cell.detailTextLabel?.text = "TBD"
        
        return cell
    }
}

