//
//  ViewController.swift
//  pomodoro
//
//  Created by Terry on 2022/01/06.
//

import UIKit

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var toggleButton: UIButton!
    
    var duration = 60
    var timerStatus: TimerStatus = .end
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure
        configureToggleButton()
    }

    //MARK: - IBAction
    //취소 버튼 이벤트함수
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch timerStatus {
        case .start, .pause:
            timerStatus = .end
            cancelButton.isEnabled = false
            setTimerInfoViewVisible(isHidden: true)
            datePicker.isHidden = false
            toggleButton.isSelected = false
        default:
            break
        }
    }
    
    //시작 버튼 이벤트함수
    @IBAction func tapToggleButton(_ sender: UIButton) {
        //데이트 픽커에서 설정한 시간을 초로 변환
        duration = Int(datePicker.countDownDuration)
        
        switch timerStatus {
        case .start:
            timerStatus = .pause
            toggleButton.isSelected = false
        case .end:
            timerStatus = .start
            setTimerInfoViewVisible(isHidden: false)
            datePicker.isHidden = true
            toggleButton.isSelected = true
            cancelButton.isEnabled = true
        case .pause:
            timerStatus = .start
            toggleButton.isSelected = true
        }
    }
    
    //MARK: - Function
    func setTimerInfoViewVisible(isHidden: Bool){
        timerLabel.isHidden = isHidden
        progressView.isHidden = isHidden
    }
    
    func configureToggleButton(){
        toggleButton.setTitle("시작", for: .normal)
        toggleButton.setTitle("일시정지", for: .selected)
    }
}

