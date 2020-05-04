//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/4.
//

import UIKit

class SwipeViewControllerModel {
  private(set) var currentIndex = 0
  private(set) var locationX: CGFloat = 0.0
  
  func set(currentIndex: Int) {
    self.currentIndex = currentIndex
  }
  
  func set(locationX: CGFloat) {
    self.locationX = locationX
  }
}
