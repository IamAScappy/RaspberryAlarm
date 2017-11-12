//
//  WakeUpTimeSetUpViewController.swift
//  RaspberryAlarm
//
//  Created by 류성두 on 2017. 11. 12..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class WakeUpTimeSetUpViewController: UIViewController {

    var alarmItem:AlarmItem!

    @IBAction func confirmButtonHandler(_ sender: UIBarButtonItem) {
        self.alarmItem = AlarmItem((8,30))!
        performSegue(withIdentifier: "unwindToSetUpAlarmVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let originVC = segue.destination as! SetUpAlarmViewController
        originVC.alarmItem = self.alarmItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
