//
//  WorkoutViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 28.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutViewController: UIViewController {
    var healthMgr: HealthManager?
    var workout: HKWorkout?
    
    var pageIndex: PageViews = .timeZoneView
    
    func updateData() {
        
    }
}
