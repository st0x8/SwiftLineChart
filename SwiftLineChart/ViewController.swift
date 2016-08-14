//
//  ViewController.swift
//  SwiftLineChart
//
//  Created by 0x00 on 8/12/16.
//  Copyright © 2016 0x08. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var index = 0
    var lineValues: [[CGFloat]] = [[0, 10, 30, 100], [10, 50, 60 , 47, 80], [0, 80, 140, 150, 300, 320], [0, 20, 30, 50, 80, 50, 150, 180]]
    @IBOutlet var lineChart: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var xLabelTitles = [String]()
        for i in 0...10 {
            xLabelTitles.append(String(i))
        }
        lineChart.xLabelTitles = xLabelTitles
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addLine(sender: AnyObject) {
        
        if index >= 1 {
            lineChart.areaHidden = true
        }
        if index >= lineValues.count {
            return
        }
        lineChart.addLine(lineValues[index], color: nil, lineWidth: nil)
        index = index + 1
    }

}

