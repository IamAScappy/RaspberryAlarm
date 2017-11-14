//
//  RecordingPhaseViewController.swift
//  RaspberryAlarm
//
//  Created by 류성두 on 2017. 11. 12..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import CoreMotion
class RecordingPhaseViewController: UIViewController {
    
    // TODO : Record Sleep Phase With HealthKit
    
    // MARK: 알람이 울릴 시간을 계산하는데 사용할 전역변수들
    var alarmItem:AlarmItem!
    var alarmTimer:Timer!
    var currentDay:Int!
    var currentPhase:Phase!
    var remainingSnoozeAmount:Int = 0
    var wakeUpTimeInSeconds:Int{
        get{
            if Timer.currentSecondsOfToday > self.alarmItem.wakeUpTimeInSeconds {
                return alarmItem.wakeUpTimeInSeconds + 24*60*60
            }else{
                return alarmItem.wakeUpTimeInSeconds
            }
        }
    }
    
    // MARK: 수면그래프 작성을 위한, 가속도 센서 관련 전역변수들
    var motionSensorTimer:Timer!
    let motion:CMMotionManager = CMMotionManager()
    var lastState = 100
    
    // MARK: IBOutlets
    @IBOutlet weak var currentTimeLB: UILabel!
    @IBOutlet weak var remainingTimeLB: UILabel!
    
    // MARK: IBActions
    @IBAction func cancelButtonHandler(_ sender: UIButton) {
        alarmTimer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func unwindToRecordingPhase(segue:UIStoryboardSegue) {
    }
    
    // MARK: 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let alarm = DataCenter.main.nearestAlarm else {alert(msg:"설정된 알람이 없습니다!"); return}
        self.alarmItem = alarm
        self.remainingSnoozeAmount = alarm.snoozeAmount
        self.currentPhase = Phase.recordingSleep
        self.currentDay = Calendar.current.component(.weekday, from: Date())
        startAccelerometers()
    }
    override func viewWillAppear(_ animated: Bool) {
        alarmTimer = generateAlarmTimer()
        alarmTimer.fire()
    }
    
    func generateAlarmTimer()->Timer{
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.currentTimeLB.text = Timer.currentHHmmss
            
            var remainingTime = 0
            if self.currentPhase == .recordingSleep{
                if self.alarmItem.repeatDays.contains(Day(rawValue: self.currentDay)!){
                    remainingTime = self.wakeUpTimeInSeconds - Timer.currentSecondsOfToday
                }else{
                    remainingTime = self.wakeUpTimeInSeconds - Timer.currentSecondsOfToday + 24*60*60
                }
            }else if self.currentPhase == .snooze{
                remainingTime = self.remainingSnoozeAmount
                self.remainingSnoozeAmount -= 1
            }

            let remainingHour = Int(remainingTime/3600)
            let remainingMinute = Int((remainingTime - remainingHour*3600)/60)
            let remainingSecond = remainingTime - remainingHour*3600 - remainingMinute*60
            self.remainingTimeLB.text = "\(remainingHour):\(remainingMinute):\(remainingSecond)"

            if remainingTime == self.alarmItem.timeToHeat{
                let url = URL(string: "http://192.168.0.20:3030")!
                URLSession.shared.dataTask(with: url).resume()
            }else if remainingTime == 0{
                timer.invalidate()
                self.performSegue(withIdentifier: "showRingingPhase", sender: self.alarmItem.snoozeAmount)
            }
        }
    }
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 30.0  // 30 Hz
            self.motion.startAccelerometerUpdates()

            // Configure a timer to fetch the data.
            self.motionSensorTimer = Timer(fire: Date(), interval: (1.0/30.0), repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                    let x = data.acceleration.x;let y = data.acceleration.y;let z = data.acceleration.z
                    let currentState = Int(abs((x + y + z)*10))

                    print(currentState - self.lastState)
                    self.lastState = currentState
                }
            })
            // Add the timer to the current run loop.
            RunLoop.current.add(self.motionSensorTimer!, forMode: .defaultRunLoopMode)
        }
    }
    

    func alert(msg:String){
        let alert = UIAlertController(title: "안내", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Timer{
    static var currentHHmmss:String{
        get{
            let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter.string(from: Date())
        }
    }
    static var currentSecondsOfToday:Int{
        let currentTimeString = Timer.currentHHmmss
        let currentHour = Int(currentTimeString.split(separator: ":")[0])!
        let currentMinute = Int(currentTimeString.split(separator: ":")[1])!
        let currentSecond = Int(currentTimeString.split(separator: ":")[2])!
        return currentHour*60*60 + currentMinute*60 + currentSecond
    }
}
