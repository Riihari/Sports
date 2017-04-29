//
//  PageViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 28.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit

enum PageViews: Int {
    case timeZoneView = 0
    case hrView
    case paceView
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    let pageAmount = PageViews.paceView
    var healthMgr: HealthManager?
    var workout: HKWorkout?
    
    var zones: [TrainingZones]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        setViewControllers([getViewController(0)] as [UIViewController], direction: .forward, animated: false, completion: nil)
        
        let pageControl: UIPageControl = UIPageControl.appearance(whenContainedInInstancesOf: [PageViewController.self])
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = UIColor.darkGray
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! WorkoutViewController

        var index = pageContent.pageIndex.rawValue
        index += 1
        
        if  index == pageAmount.rawValue {
            return nil
        }
        
        return getViewController(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! WorkoutViewController
        
        if  pageContent.pageIndex == PageViews.timeZoneView {
            return nil
        }
    
        var index = pageContent.pageIndex.rawValue
        index -= 1
        return getViewController(index)
    }
    
    func getViewController(_ atIndex: Int) -> WorkoutViewController {
        let pageContentViewController: WorkoutViewController?
        
        if PageViews(rawValue: atIndex) == PageViews.timeZoneView {
            pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "DetailWorkoutController") as! DetailWorkoutViewController
        }
        else {
            pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "ChartController") as! ChartViewController
        }
        pageContentViewController?.healthMgr = healthMgr
        pageContentViewController?.workout = workout
        pageContentViewController?.pageIndex  = PageViews(rawValue: atIndex)!
        
        return pageContentViewController!
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageAmount.rawValue
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return PageViews.timeZoneView.rawValue
    }
}
