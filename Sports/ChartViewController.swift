//
//  ChartViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 28.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit
import Charts

class ChartViewController: WorkoutViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let startDate = formatter.string(from: (workout?.startDate)!)
        dateLabel.text = startDate
        
        let parentViewController = parent as! PageViewController
        if let _ = parentViewController.hrSamples {
            updateData()
        }
    }
    
    override func updateData() {
        super.updateData()
        
        let parentViewController = parent as! PageViewController
        let (average, hrValues, hrTimes) = self.calculateHeartRates(parentViewController.hrSamples!)

        DispatchQueue.main.async(execute: { () -> Void in
            self.hrLabel.text = String(average)
        
            self.setChart(dataPoints: hrTimes, values: hrValues)
        })
    }
    
    func calculateHeartRates(_ samples: [HKQuantitySample]) -> (Int, [Int], [Date]) {        
        var sum: Double = 0
        var hrValues = [Int]()
        var hrTimes = [Date]()
        let hrSamplesCount = samples.count
        
        let workoutStart = self.workout?.startDate
        let calendar = Calendar.current
        
        for sample in samples {
            let hrTimeStamp = sample.startDate
            
            let differenceComponents = calendar.dateComponents([.hour, .minute, .second], from: workoutStart!, to: hrTimeStamp)
            let hrTime = calendar.date(from: differenceComponents)
            
            hrTimes.append(hrTime!)
            
            let hrValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            sum += hrValue
            hrValues.append(Int(hrValue))
        }
        let average = Int(sum) / hrSamplesCount

        return (average, hrValues, hrTimes)
    }
    
    func setChart(dataPoints: [Date], values: [Int]) {
        lineChart.noDataText = "Ei syketietoja"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let timeIntervalforDate: TimeInterval = dataPoints[i].timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalforDate), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Syke")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.colors = [UIColor.red]
        
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChart.data = chartData
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.chartDescription?.text = ""
        
        let xaxis = lineChart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
    }
}

extension ChartViewController: IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

