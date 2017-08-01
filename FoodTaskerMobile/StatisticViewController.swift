//
//  StatisticViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/15.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import Charts

class StatisticViewController: UIViewController ,IAxisValueFormatter{

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var viewChart: BarChartView!
    
    var weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        //#1 initialize chart
        initializeChart()
        
        
        //#2 load data to chart
        loadDataToChart()
        
        
        
    }
    
    
    func initializeChart(){
        
        viewChart.noDataText = "No Data"
        viewChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        viewChart.xAxis.labelPosition = .bottom
        viewChart.chartDescription?.text = ""
        viewChart.xAxis.valueFormatter = self
        
        
        viewChart.legend.enabled = false
        viewChart.scaleXEnabled = false
        viewChart.scaleYEnabled = false
        viewChart.pinchZoomEnabled = false
        viewChart.doubleTapToZoomEnabled = false
        
        viewChart.leftAxis.axisMinimum = 0.0
        viewChart.leftAxis.axisMaximum = 300.0
        viewChart.highlighter = nil
        viewChart.rightAxis.enabled = false
        viewChart.xAxis.drawGridLinesEnabled = false
        
        
    }
    
    func loadDataToChart(){
        APIManager.shared.getDriverRevenue { (json) in
            if json != nil{
                
                print(json)
                
                
                let revenue = json["revenue"]
                
                var dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<self.weekdays.count{
                    let day = self.weekdays[i]
                    let dataEntry = BarChartDataEntry(x: Double(i), yValues: [revenue[day].double!])
                    dataEntries.append(dataEntry)
                }
                
                let chartDataSet = BarChartDataSet(values: dataEntries, label: "Revenue by Day")
                chartDataSet.colors = ChartColorTemplates.material()
                
                let chartData = BarChartData(dataSet: chartDataSet)
                self.viewChart.data = chartData
                
            }
        }
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return weekdays[Int(value)]
    }


}
