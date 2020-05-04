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

public class SwipeViewController: UIViewController {
  
  fileprivate lazy var pagingVC = makePagingVC()
  fileprivate lazy var barStackView = makeBarStackView()
  fileprivate lazy var tapController = makeTapController()
  fileprivate let viewControllers: [UIViewController]
  fileprivate let swipeViewControllerModel = SwipeViewControllerModel()
  
  public init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupLayout()
    setViewControlersIntoPagingVC(allViewControllers: viewControllers, pagingVC: pagingVC)
    tapController.addTapGesture(in: view)
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
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4.0
    stackView.distribution = .fillEqually
    for _ in 0 ... (viewControllers.count - 1) {
      let barView = UIView()
      barView.backgroundColor = barDeselectColor
      barView.layer.cornerRadius = 2.0
      barView.clipsToBounds = true
      stackView.addArrangedSubview(barView)
    }
    stackView.arrangedSubviews.first?.backgroundColor = barSelectColor
    return stackView
  }
  
  fileprivate func makeTapController() -> TapController {
    let tapController = TapController()
    tapController.dataSource = self
    tapController.delegate = self
    return tapController
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
  
  fileprivate func setBarColor(_ index: Int) {
    //讓目前呈現的 VC 對應的 barStackView 的 bar 更改顏色
    barStackView.arrangedSubviews.forEach{
      $0.backgroundColor = barDeselectColor
    }
    barStackView.arrangedSubviews[index].backgroundColor = barSelectColor
  }
}

extension SwipeViewController: UIPageViewControllerDataSource {
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    //得到前一個頁面
    guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    let minIndex = 0
    
    //如果當前頁面是第一個 VC，向右滑顯示最後一個 VC
    if previousIndex < minIndex {
      return viewControllers.last
    }
    
    return viewControllers[previousIndex]
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    //得到後一個頁面
    guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
      return nil
    }
    let nextIndex = viewControllerIndex + 1
    let maxIndex = viewControllers.count - 1
    
    //如果當前頁面是最後一個 VC，向左滑顯示第一個 VC
    if nextIndex > maxIndex {
      return viewControllers.first
    }
    
    return viewControllers[nextIndex]
  }
}

extension SwipeViewController: UIPageViewControllerDelegate {
  
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let currentVC = pageViewController.viewControllers?.first
    if let index = viewControllers.firstIndex(where: { $0 == currentVC }) {
      setBarColor(index)
    }
  }
}

extension SwipeViewController: TapControllerDataSource {
  func tapControllerWidthOfView(_ tapController: TapController) -> CGFloat {
    return view.frame.width
  }
  
  func tapControllerGestureLocationX(_ tapController: TapController) -> CGFloat {
    return swipeViewControllerModel.locationX
  }
  
  
  func tapControllerIndexOfCurrentController(_ tapController: TapController) -> Int {
    return swipeViewControllerModel.currentIndex
  }
  
  func tapControllerCountOfControllers(_ tapController: TapController) -> Int {
    return viewControllers.count
  }
}

extension SwipeViewController: TapControllerDelegate {
  func tapControllerDidTapForward(_ tapController: TapController, nextIndex: Int) {
    let currentVC = viewControllers[nextIndex]
    pagingVC.setViewControllers([currentVC], direction: .forward, animated: true) {[weak self] (finished) in
      guard let self = self else {return}
      if finished {
        self.swipeViewControllerModel.set(currentIndex: nextIndex)
        self.setBarColor(self.swipeViewControllerModel.currentIndex)
      }
    }
  }
  
  func tapControllerDidTapBack(_ tapController: TapController, nextIndex: Int) {
    let currentVC = viewControllers[nextIndex]
    pagingVC.setViewControllers([currentVC], direction: .reverse , animated: true) {[weak self] (finished) in
      guard let self = self else {return}
      if finished {
        self.swipeViewControllerModel.set(currentIndex: nextIndex)
        self.setBarColor(self.swipeViewControllerModel.currentIndex)
      }
    }
  }
  
  func tapControllerDidTap(_ tapController: TapController, gesture: UITapGestureRecognizer) {
    let locationX = gesture.location(in: view).x
    swipeViewControllerModel.set(locationX: locationX)
  }
}
