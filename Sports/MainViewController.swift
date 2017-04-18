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
    var workouts = [HKWorkout]()
    let healthMgr: HealthManager = HealthManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        healthMgr.authorizeHealthKit()
        
        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        healthMgr.readWorkOuts({(results, error) -> Void in
            if error != nil {
                print("Error reading workouts!")
                return
            }
            
            self.workouts = results as! [HKWorkout]
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            });
        
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcellid", for: indexPath)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = formatter.string(from: workout.startDate)
        
        var detailText: String = "Duration: "
        let durationFormatter = DateComponentsFormatter()
        detailText += durationFormatter.string(from: workout.duration)!
        
        let distanceFormatter = LengthFormatter()
        detailText += " Distance: "
        let distanceInKm = workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
        detailText += distanceFormatter.string(fromValue: distanceInKm!, unit: LengthFormatter.Unit.kilometer)

        cell.detailTextLabel?.text = detailText
        
        return cell
    }
}

