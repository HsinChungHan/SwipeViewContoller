//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/4.
//

import Foundation

protocol TimerManagerDataSource: AnyObject {
  func timerManagerTimeInterval(_ timerManager: TimerManager) -> TimeInterval
}

protocol TimerManagerDelegate: AnyObject {
  func timerManagerFires(_ timerManager: TimerManager, timer: Timer)
  func timerManagerInvalidate(_ timerManager: TimerManager)
}

class TimerManager {
  static let shared = TimerManager()
  
  weak var dataSource: TimerManagerDataSource?
  weak var delegate: TimerManagerDelegate?
  
  var timer: Timer?
  
  func setupTimer() {
    guard let dataSource = dataSource else {
      fatalError("You have to set dataSource for ScrollTimer")
    }
    
    let timeInterval = dataSource.timerManagerTimeInterval(self)
    
    timer = Timer.init(timeInterval: timeInterval, target: self, selector: #selector(onTimerFires(sender:)), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  @objc func onTimerFires(sender: Timer) {
    delegate?.timerManagerFires(self, timer: sender)
  }
  
  func invalidateTimer() {
    if let _ = timer {
      timer!.invalidate()
    }
    timer = nil
    delegate?.timerManagerInvalidate(self)
  }
}
