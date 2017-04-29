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
    
    func authorizeHealthKit(_ completion: @escaping (Bool, Error?) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            print("No health data")
            completion(false, nil)
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.workoutType()]
        healthKitStore.requestAuthorization(toShare: nil, read: readTypes, completion: {(authorization: Bool, error: Error?) -> Void in
            completion(authorization, error)
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
    
    func readHrSamples(_ workout: HKWorkout, _ completion: @escaping ([AnyObject]?, Error?) -> Void) {
        //let predicate = HKQuery.predicateForObjects(from: workout)
        let hrType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [])
        
        let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: hrType!, predicate: predicate, limit: 0, sortDescriptors: [startDateSort], resultsHandler: {(sampleQuery, results, error) -> Void in            
            completion(results, error)
        })
        
        healthKitStore.execute(query)
    }
}
