//
//  DetailWorkoutViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 18.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit

class DetailWorkoutViewController: UIViewController {
    var healthMgr: HealthManager?
    var workout: HKWorkout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let startDate = formatter.string(from: (workout?.startDate)!)
        print("Start date: \(startDate)")
    }
}
