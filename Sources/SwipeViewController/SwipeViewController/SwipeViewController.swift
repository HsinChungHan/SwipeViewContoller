//
//  SwipingPhotosViewController.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/2.
//

import UIKit

//MARK: - Instance
fileprivate let barDeselectColor = UIColor.init(white: 0, alpha: 0.1)
fileprivate let barSelectColor = UIColor.white

public protocol SwipeViewControllerDataSource: AnyObject {
  func swipeViewControllerAllViewControllers(_ swipingPhotosController: SwipeViewController) -> [UIViewController]
}

public class SwipeViewController: UIViewController {
  
  weak public var dataSource: SwipeViewControllerDataSource?
  
  fileprivate lazy var pagingVC = makePagingVC()
  fileprivate lazy var barStackView = makeBarStackView()
  fileprivate lazy var allViewControllers = makeAllControllers()
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupLayout()
    setViewControlersIntoPagingVC(allViewControllers: allViewControllers, pagingVC: pagingVC)
  }
}

extension SwipeViewController {
  fileprivate func makePagingVC() -> UIPageViewController {
    let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    vc.delegate = self
    vc.dataSource = self
    return vc
  }
  
  fileprivate func makeBarStackView() -> UIStackView {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for UserDetailViewController")
    }
    let countOfControllers = dataSource.swipeViewControllerAllViewControllers(self).count
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4.0
    stackView.distribution = .fillEqually
    for _ in 0 ... countOfControllers - 1 {
      let barView = UIView()
      barView.backgroundColor = barDeselectColor
      barView.layer.cornerRadius = 2.0
      barView.clipsToBounds = true
      stackView.addArrangedSubview(barView)
    }
    stackView.arrangedSubviews.first?.backgroundColor = barSelectColor
    return stackView
  }
  
  fileprivate func makeAllControllers() -> [UIViewController] {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for UserDetailViewController")
    }
    return dataSource.swipeViewControllerAllViewControllers(self)
  }
  
  fileprivate func setupLayout() {
    addChild(pagingVC)
    [pagingVC.view, barStackView].forEach {
      view.addSubview($0)
    }
    pagingVC.view.fillSuperView()
    barStackView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 4))
  }
  
  fileprivate func setViewControlersIntoPagingVC(allViewControllers: [UIViewController], pagingVC: UIPageViewController) {
    guard let firstVC = allViewControllers.first else {
      fatalError("🚨 You have to set VCs for UserDetailViewController")
    }
    pagingVC.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
  }
}

extension SwipeViewController: UIPageViewControllerDataSource {
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    //得到前一個頁面
    guard let viewControllerIndex = allViewControllers.firstIndex(of: viewController) else {
        return nil
    }
     
    let previousIndex = viewControllerIndex - 1
    let minIndex = 0
     
    //如果當前頁面是第一個 VC，向右滑顯示最後一個 VC
    if previousIndex < minIndex {
      return allViewControllers.last
    }
    
    return allViewControllers[previousIndex]
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    //得到後一個頁面
    guard let viewControllerIndex = allViewControllers.firstIndex(of: viewController) else {
        return nil
    }
    let nextIndex = viewControllerIndex + 1
    let maxIndex = allViewControllers.count - 1
     
    //如果當前頁面是最後一個 VC，向左滑顯示第一個 VC
    if nextIndex > maxIndex {
      return allViewControllers.first
    }
    
    return allViewControllers[nextIndex]
  }
}

extension SwipeViewController: UIPageViewControllerDelegate {
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let currentVC = pageViewController.viewControllers?.first
    if let index = allViewControllers.firstIndex(where: { $0 == currentVC }) {
      //讓目前呈現的 VC 對應的 barStackView 的 bar 更改顏色
      barStackView.arrangedSubviews.forEach{
        $0.backgroundColor = barDeselectColor
      }
      barStackView.arrangedSubviews[index].backgroundColor = barSelectColor
    }
  }
}

