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
    
    func readWorkOuts(_ completion: @escaping ([AnyObject]?, Error?) -> Void) {
        let predicate =  HKQuery.predicateForWorkouts(with: HKWorkoutActivityType.running)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 20, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            if let queryError = error {
                print( "There was an error while reading the samples: \(queryError.localizedDescription)")
            }
            completion(results,error)
        }

        healthKitStore.execute(sampleQuery)
    }

}
