//
//  HealthManager.swift
//  Sports
//
//  Created by Mikko Riihimäki on 17.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import HealthKit

class HealthManager {
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit() -> Void {
        if !HKHealthStore.isHealthDataAvailable() {
            print("No health data")
            return
        }
        
        let readTypes: Set<HKObjectType> = [HKObjectType.workoutType()]
        healthKitStore.requestAuthorization(toShare: nil, read: readTypes, completion: {(authorization: Bool, error: Error?) -> Void in
            if error != nil {
                print("Authorization denied")
            }
            else {
                print("Authorized")
            }
        })
    }
}
