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
  func tapControllerNextIndex(_ tapController: TapController) -> Int
  func tapControllerDirection(_ tapController: TapController) -> TapDirection
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
    
    let direction = dataSource.tapControllerDirection(self)
    let nextIndex = dataSource.tapControllerNextIndex(self)
    switch direction {
      case .forward:
      	delegate?.tapControllerDidTapForward(self, nextIndex: nextIndex)
      case .back:
      	delegate?.tapControllerDidTapBack(self, nextIndex: nextIndex)
    }
  }
}
