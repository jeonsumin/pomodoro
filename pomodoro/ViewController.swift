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
    @IBOutlet var imageView: UIImageView!
    
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
            //애니매이션 추가
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            
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
    //애니메이션 추가전 사용 
    func setTimerInfoViewVisible(isHidden: Bool){
        timerLabel.isHidden = isHidden
        progressView.isHidden = isHidden
    }
    
    func configureToggleButton(){
        toggleButton.setTitle("시작", for: .normal)
        toggleButton.setTitle("일시정지", for: .selected)
    }
    
    //타이머 시작 함수
    func startTimer(){
        if timer == nil {
            //메인스레드에서 도는 TimerSource 초기화
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            // deadline은 지금부터 1초 간격으로 스케줄링
            timer?.schedule(deadline: .now(),repeating: 1)
            // timer 이벤트 핸들러 클로저 설정 
            timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600 // 시
                let minutes = (self.currentSeconds % 3600) / 60 // 분
                let seconds = (self.currentSeconds % 3600) % 60 //시
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour,minutes,seconds)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                // time가 돌때 imageView를 회전
                UIView.animate(withDuration: 0.5,delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5,delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                
                if self.currentSeconds <= 0 {
                    //타이머 종료
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }

    //타이머 종료 함수
    func stopTimer(){
        if timerStatus == .pause {
            timer?.resume()
        }
        timerStatus = .end
        cancelButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
        toggleButton.isSelected = false
        timer?.cancel()
        timer = nil
    }
}

