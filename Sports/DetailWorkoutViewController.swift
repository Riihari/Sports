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

struct TrainingZones {
    var zoneTime: String
    var zonePercent: Double
}

class DetailWorkoutViewController: WorkoutViewController {    
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
    
    @IBOutlet weak var barChart: BarChartView!

    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self
        
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
        
        if let hrSamples = samples {
            let (average, zones) = calculateTrainingZones(hrSamples)
            updateLabels(average, zones)
        }
        else {
            healthMgr?.readHrSamples(workout!, {(results, error) -> Void in
                if error == nil {
                    if let hrSamples = results as? [HKQuantitySample] {
                        let hrSamplesCount = hrSamples.count
                        if hrSamplesCount > 0 {
                            self.samples = hrSamples
                            
                            let (average, zones) = self.calculateTrainingZones(hrSamples)
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.updateLabels(average, zones)
                            })
                        }
                    }
                }
            })
        }
    }
    
    func updateLabels(_ average: Int, _ zones: [TrainingZones]) {
        self.avgHrLabel.text = String(average)
        
        self.tz1Label.text = zones[0].zoneTime
        self.tz1PercentLabel.text = String(Int(zones[0].zonePercent*100)) + "%"
        self.tz2Label.text = zones[1].zoneTime
        self.tz2PercentLabel.text = String(Int(zones[1].zonePercent*100)) + "%"
        self.tz3Label.text = zones[2].zoneTime
        self.tz3PercentLabel.text = String(Int(zones[2].zonePercent*100)) + "%"
        self.tz4Label.text = zones[3].zoneTime
        self.tz4PercentLabel.text = String(Int(zones[3].zonePercent*100)) + "%"
        self.tz5Label.text = zones[4].zoneTime
        self.tz5PercentLabel.text = String(Int(zones[4].zonePercent*100)) + "%"
        
        self.setChart(zones)
    }
    
    func calculateTrainingZones(_ samples: [HKQuantitySample]) -> (Int, [TrainingZones]) {
        var zones: [TrainingZones] = []
        
        let hrValues = samples.map{$0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))}
        let sum = hrValues.reduce(0, +)
        let hrSamplesCount = samples.count
        
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
        zones.append(TrainingZones(zoneTime: tz1Text!, zonePercent: tz1Percent))
        
        var tz2Time = self.workout?.duration
        tz2Time?.multiply(by: tz2Percent)
        let tz2Text = durationFormatter.string(from: tz2Time!)
        zones.append(TrainingZones(zoneTime: tz2Text!, zonePercent: tz2Percent))
        
        var tz3Time = self.workout?.duration
        tz3Time?.multiply(by: tz3Percent)
        let tz3Text = durationFormatter.string(from: tz3Time!)
        zones.append(TrainingZones(zoneTime: tz3Text!, zonePercent: tz3Percent))
        
        var tz4Time = self.workout?.duration
        tz4Time?.multiply(by: tz4Percent)
        let tz4Text = durationFormatter.string(from: tz4Time!)
        zones.append(TrainingZones(zoneTime: tz4Text!, zonePercent: tz4Percent))
        
        var tz5Time = self.workout?.duration
        tz5Time?.multiply(by: tz5Percent)
        let tz5Text = durationFormatter.string(from: tz5Time!)
        zones.append(TrainingZones(zoneTime: tz5Text!, zonePercent: tz5Percent))
        
        return (average, zones)
    }
    
    func setChart(_ zones: [TrainingZones]) {
        barChart.noDataText = "Ei syketietoja"

        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<zones.count {
            let zoneNr = Double(i)
            let dataEntry = BarChartDataEntry(x: zoneNr, y: zones[i].zonePercent*100)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Harjoitusalueet")
        chartDataSet.colors = [UIColor.red]
        
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        
        barChart.xAxis.labelPosition = .bottom
        barChart.chartDescription?.text = ""
        
        let xaxis = barChart.xAxis
        xaxis.granularity = 1.0
        xaxis.valueFormatter = axisFormatDelegate

    }
}

extension DetailWorkoutViewController: IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let trainingZones = ["PK1", "PK2", "VK1", "VK2", "MK"]
        return trainingZones[Int(value)]
    }
}
