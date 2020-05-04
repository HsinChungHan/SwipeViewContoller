//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/4.
//

import UIKit

enum TapDirection {
  case forward
  case back
}

protocol TapControllerDataSource: AnyObject {
  func tapControllerIndexOfCurrentController(_ tapController: TapController) -> Int
  func tapControllerCountOfControllers(_ tapController: TapController) -> Int
  func tapControllerGestureLocationX(_ tapController: TapController) -> CGFloat
  func tapControllerWidthOfView(_ tapController: TapController) -> CGFloat
}

protocol TapControllerDelegate: AnyObject {
  func tapControllerDidTap(_ tapController: TapController, gesture: UITapGestureRecognizer)
  func tapControllerDidTapForward(_ tapController: TapController, nextIndex: Int)
  func tapControllerDidTapBack(_ tapController: TapController, nextIndex: Int)
}

class TapController {
  
  weak var dataSource: TapControllerDataSource?
  weak var delegate: TapControllerDelegate?
  
  func addTapGesture(in view: UIView) {
    let tapGextureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
    view.addGestureRecognizer(tapGextureRecognizer)
  }
  
  @objc func handleTap(sender: UITapGestureRecognizer) {
    guard let dataSource = dataSource else {
      fatalError("You have to set dataSource for TapController")
    }
    delegate?.tapControllerDidTap(self, gesture: sender)
    let locationX = dataSource.tapControllerGestureLocationX(self)
    let viewWidth = dataSource.tapControllerWidthOfView(self)
    let directionAndNextIndex = getDirectionAndNextIndex(viewWidth: viewWidth, tapLocationX: locationX)
    let direction = directionAndNextIndex.direction
    let nextIndex = directionAndNextIndex.index
    switch direction {
      case .forward:
      	delegate?.tapControllerDidTapForward(self, nextIndex: nextIndex)
      case .back:
      	delegate?.tapControllerDidTapBack(self, nextIndex: nextIndex)
    }
  }
  
  fileprivate func getDirectionAndNextIndex(viewWidth: CGFloat, tapLocationX: CGFloat) -> (direction: TapDirection, index: Int) {
    guard let dataSource = dataSource else {
      fatalError("You have to set dataSource for TapController")
    }
    let countOfControllers = dataSource.tapControllerCountOfControllers(self)
    let currentIndex = dataSource.tapControllerIndexOfCurrentController(self)
    var nextIndex: Int
    var direction: TapDirection
    
    let maxIndexOfControllers = countOfControllers - 1
    let minIndexOfControllers = 0
    if (tapLocationX > viewWidth / 2) {
      if (currentIndex + 1) > maxIndexOfControllers {
        nextIndex = 0
      }else {
        nextIndex = currentIndex + 1
      }
      direction = .forward
    }else {
      if (currentIndex - 1) < minIndexOfControllers {
        nextIndex = maxIndexOfControllers
      }else {
        nextIndex = currentIndex - 1
      }
      direction = .back
    }
    return (direction: direction, index: nextIndex)
  }
}
