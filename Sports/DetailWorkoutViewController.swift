//
//  DetailWorkoutViewController.swift
//  Sports
//
//  Created by Mikko Riihimäki on 18.4.2017.
//  Copyright © 2017 Mikko Riihimäki. All rights reserved.
//

import UIKit
import HealthKit
import Charts

class DetailWorkoutViewController: UIViewController {
    var healthMgr: HealthManager?
    var workout: HKWorkout?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var avgHrLabel: UILabel!
    
    @IBOutlet weak var tz1Label: UILabel!
    @IBOutlet weak var tz2Label: UILabel!
    @IBOutlet weak var tz3Label: UILabel!
    @IBOutlet weak var tz4Label: UILabel!
    @IBOutlet weak var tz5Label: UILabel!
    
    @IBOutlet weak var tz1PercentLabel: UILabel!
    @IBOutlet weak var tz2PercentLabel: UILabel!
    @IBOutlet weak var tz3PercentLabel: UILabel!
    @IBOutlet weak var tz4PercentLabel: UILabel!
    @IBOutlet weak var tz5PercentLabel: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!

    weak var axisFormatDelegate: IAxisValueFormatter?
    
    var months: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self as! IAxisValueFormatter
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let startDate = formatter.string(from: (workout?.startDate)!)
        dateLabel.text = startDate
        
        let durationFormatter = DateComponentsFormatter()
        let durationText = durationFormatter.string(from: (workout?.duration)!)
        durationLabel.text = durationText
        
        let distanceFormatter = LengthFormatter()
        let distanceInKm = workout?.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
        let distanceText = distanceFormatter.string(fromValue: distanceInKm!, unit: LengthFormatter.Unit.kilometer)
        distanceLabel.text = distanceText
        
//        healthMgr?.readAvgHr(workout!, {(result, error) -> Void in
           /* if result != nil {
                let average = result?[0] as! HKQuantity
                let averageValue = average.doubleValue(for: HKUnit.count())
                print("Average \(averageValue)")
            }*/
//        })
        
        healthMgr?.readHrSamples(workout!, {(results, error) -> Void in
            print("Read HR samples")
            if error == nil {
                if let hrSamples = results as? [HKQuantitySample] {
                    let hrSamplesCount = hrSamples.count
                    if hrSamplesCount > 0 {
                        
                        print("Results \(hrSamplesCount)")
                    
                        var sum: Double = 0
                        var hrValues = [Int]()
                        var hrTimes = [Date]()
                        var printed = false
                        
                        for sample in hrSamples {
                            let hrTimeInterval = sample.startDate.timeIntervalSince1970 - (self.workout?.startDate.timeIntervalSince1970)!
                            if printed != true {
                                print(hrTimeInterval)
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm.ss"
                                print(dateFormatter.string(from: Date(timeIntervalSince1970: hrTimeInterval)))
                                
                                printed = true
                            }
                            let hrTime: Date = Date(timeIntervalSince1970: hrTimeInterval)
                            
                            hrTimes.append(hrTime)
                            
                            let hrValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                            sum += hrValue
                            hrValues.append(Int(hrValue))
                        }
                        let average = Int(sum) / hrSamplesCount
                        let tz1 = hrValues.filter({$0 < 115}).count
                        let tz2 = hrValues.filter({$0 >= 115 && $0 < 125}).count
                        let tz3 = hrValues.filter({$0 >= 125 && $0 < 140}).count
                        let tz4 = hrValues.filter({$0 >= 140 && $0 < 155}).count
                        let tz5 = hrValues.filter({$0 >= 155}).count

                        let tz1Percent: Double = Double(tz1)/Double(hrSamplesCount)
                        let tz2Percent: Double = Double(tz2)/Double(hrSamplesCount)
                        let tz3Percent: Double = Double(tz3)/Double(hrSamplesCount)
                        let tz4Percent: Double = Double(tz4)/Double(hrSamplesCount)
                        let tz5Percent: Double = Double(tz5)/Double(hrSamplesCount)
                    
                        let durationFormatter = DateComponentsFormatter()
                        var tz1Time = self.workout?.duration
                        tz1Time?.multiply(by: tz1Percent)
                        let tz1Text = durationFormatter.string(from: tz1Time!)
                        var tz2Time = self.workout?.duration
                        tz2Time?.multiply(by: tz2Percent)
                        let tz2Text = durationFormatter.string(from: tz2Time!)
                        var tz3Time = self.workout?.duration
                        tz3Time?.multiply(by: tz3Percent)
                        let tz3Text = durationFormatter.string(from: tz3Time!)
                        var tz4Time = self.workout?.duration
                        tz4Time?.multiply(by: tz4Percent)
                        let tz4Text = durationFormatter.string(from: tz4Time!)
                        var tz5Time = self.workout?.duration
                        tz5Time?.multiply(by: tz5Percent)
                        let tz5Text = durationFormatter.string(from: tz5Time!)

                        DispatchQueue.main.async(execute: { () -> Void in
                            self.avgHrLabel.text = String(average)
                        
                            self.tz1Label.text = tz1Text
                            self.tz1PercentLabel.text = String(Int(tz1Percent*100)) + "%"
                            self.tz2Label.text = tz2Text
                            self.tz2PercentLabel.text = String(Int(tz2Percent*100)) + "%"
                            self.tz3Label.text = tz3Text
                            self.tz3PercentLabel.text = String(Int(tz3Percent*100)) + "%"
                            self.tz4Label.text = tz4Text
                            self.tz4PercentLabel.text = String(Int(tz4Percent*100)) + "%"
                            self.tz5Label.text = tz5Text
                            self.tz5PercentLabel.text = String(Int(tz5Percent*100)) + "%"
                            self.setChart(dataPoints: hrTimes, values: hrValues)
                        })
                    }
                }
            }
        })
        
        //months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        //let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        //setChart(dataPoints: months, values: unitsSold)
    }
    
    func setChart(dataPoints: [Date], values: [Int]) {
        lineChartView.noDataText = "Ei syketietoja"

        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let timeIntervalforDate: TimeInterval = dataPoints[i].timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalforDate), y: Double(values[i]))
//            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Units Sold")
        //let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        lineChartView.xAxis.labelPosition = .bottom
        
        let xaxis = lineChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
    }
}

extension DetailWorkoutViewController: IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
