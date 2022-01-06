//
//  ViewController.swift
//  pomodoro
//
//  Created by Terry on 2022/01/06.
//

import UIKit
import AudioToolbox

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
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
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
            stopTimer()
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
            timer?.suspend()
        case .end:
            currentSeconds = duration
            timerStatus = .start
            setTimerInfoViewVisible(isHidden: false)
            datePicker.isHidden = true
            toggleButton.isSelected = true
            cancelButton.isEnabled = true
            startTimer()
        case .pause:
            timerStatus = .start
            toggleButton.isSelected = true
            timer?.resume()
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
    
    func startTimer(){
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now(),repeating: 1)
            timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600 // 시
                let minutes = (self.currentSeconds % 3600) / 60 // 분
                let seconds = (self.currentSeconds % 3600) % 60 //시
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour,minutes,seconds)
                
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                debugPrint(self.progressView.progress)
                
                if self.currentSeconds <= 0 {
                    //타이머 종료
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    func stopTimer(){
        if timerStatus == .pause {
            timer?.resume()
        }
        timerStatus = .end
        cancelButton.isEnabled = false
        setTimerInfoViewVisible(isHidden: true)
        datePicker.isHidden = false
        toggleButton.isSelected = false
        timer?.cancel()
        timer = nil
    }
}

