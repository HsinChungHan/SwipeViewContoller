//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/4.
//

import UIKit

//MARK: - Instance
fileprivate let barDeselectColor = UIColor.init(white: 0, alpha: 0.1)
fileprivate let barSelectColor = UIColor.white

class SwipeViewControllerModel {
  private(set) var currentIndex = 0
  private(set) var locationX: CGFloat = 0.0
  
  func set(currentIndex: Int) {
    self.currentIndex = currentIndex
  }
  
  func set(locationX: CGFloat) {
    self.locationX = locationX
  }
  
  func getDirectionAndNextIndex(viewWidth: CGFloat, tapLocationX: CGFloat, currentIndex: Int, countOfControllers: Int) -> (direction: TapDirection, index: Int) {
    var nextIndex: Int
    var direction: TapDirection
    
    if (tapLocationX > viewWidth / 2) {
      nextIndex = getForwardNextIndex(currentIndex: currentIndex, countOfControllers: countOfControllers)
      direction = .forward
    }else {
      nextIndex = getBackNextIndex(currentIndex: currentIndex, countOfControllers: countOfControllers)
      direction = .back
    }
    return (direction: direction, index: nextIndex)
  }
  
  func getForwardNextIndex(currentIndex: Int, countOfControllers: Int) -> Int {
    var nextIndex: Int
    let minIndexOfControllers = 0
    let maxIndexOfControllers = countOfControllers - 1
    if (currentIndex + 1) > maxIndexOfControllers {
      nextIndex = minIndexOfControllers
    }else {
      nextIndex = currentIndex + 1
    }
    return nextIndex
  }
  
  func getBackNextIndex(currentIndex: Int, countOfControllers: Int) -> Int {
    var nextIndex: Int
    let minIndexOfControllers = 0
    let maxIndexOfControllers = countOfControllers - 1
    if (currentIndex - 1) < minIndexOfControllers {
      nextIndex = maxIndexOfControllers
    }else {
      nextIndex = currentIndex - 1
    }
    return nextIndex
  }
  
   func setBarColor(barStackView: UIStackView, currentIndex: Int) {
    //讓目前呈現的 VC 對應的 barStackView 的 bar 更改顏色
    barStackView.arrangedSubviews.forEach{
      $0.backgroundColor = barDeselectColor
    }
    barStackView.arrangedSubviews[currentIndex].backgroundColor = barSelectColor
  }
}
