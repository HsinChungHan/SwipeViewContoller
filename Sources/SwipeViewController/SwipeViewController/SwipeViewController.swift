//
//  SwipingPhotosViewController.swift
//  
//
//  Created by Chung Han Hsin on 2020/5/2.
//

import UIKit

//MARK: - SwipeViewControllerDataSource
public protocol SwipeViewControllerDataSource: AnyObject {
  func swipeViewControllerIsAutoScrolling(_ swipeViewController: SwipeViewController) -> Bool
  func swipeViewControllerTimeIntervalOfAutoScrolling(_ swipeViewController: SwipeViewController) -> TimeInterval
}

public class SwipeViewController: UIViewController {
  
  //MARK: - Properties
  weak public var dataSource: SwipeViewControllerDataSource?
  
  fileprivate lazy var pagingVC = makePagingVC()
  fileprivate lazy var barStackView = makeBarStackView()
  fileprivate lazy var tapController = makeTapController()
  fileprivate let viewControllers: [UIViewController]
  fileprivate let swipeViewControllerModel = SwipeViewControllerModel()
  
  //MARK: - Initialize
  public init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - View Life Cycle
  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupLayout()
    setViewControlersIntoPagingVC(allViewControllers: viewControllers, pagingVC: pagingVC)
    tapController.addTapGesture(in: view)
    makeTimerManager()
  }
}

//MARK: - Private function and Lazy Initialization
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
      barView.layer.cornerRadius = 2.0
      barView.clipsToBounds = true
      stackView.addArrangedSubview(barView)
    }
    swipeViewControllerModel.setBarColor(barStackView: stackView, currentIndex: 0)
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
  
  fileprivate func makeTimerManager() {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for SwipeViewController")
    }
    
    if dataSource.swipeViewControllerIsAutoScrolling(self) {
      TimerManager.shred.dataSource = self
      TimerManager.shred.delegate = self
      TimerManager.shred.setupTimer()
    }
  }
}

//MARK: - Public function
extension SwipeViewController {
  
  public func invalidatTimer() {
    TimerManager.shred.invalidateTimer()
  }
}

//MARK: - UIPageViewControllerDataSource
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

//MARK: - UIPageViewControllerDelegate
extension SwipeViewController: UIPageViewControllerDelegate {
  
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    TimerManager.shred.invalidateTimer()
    let currentVC = pageViewController.viewControllers?.first
    if let index = viewControllers.firstIndex(where: { $0 == currentVC }) {
      swipeViewControllerModel.setBarColor(barStackView: barStackView, currentIndex: index)
      swipeViewControllerModel.set(currentIndex: index)
    }
  }
}

//MARK: - TapControllerDataSource
extension SwipeViewController: TapControllerDataSource {
  
  func tapControllerNextIndex(_ tapController: TapController) -> Int {
    let viewWidth = view.frame.width
    let tapLocationX = swipeViewControllerModel.locationX
    let currentIndex = swipeViewControllerModel.currentIndex
    let countOfControllers = viewControllers.count
    let nextIndex = swipeViewControllerModel.getDirectionAndNextIndex(viewWidth: viewWidth, tapLocationX: tapLocationX, currentIndex: currentIndex, countOfControllers: countOfControllers).index
    return nextIndex
  }
  
  func tapControllerDirection(_ tapController: TapController) -> TapDirection {
    let viewWidth = view.frame.width
    let tapLocationX = swipeViewControllerModel.locationX
    let currentIndex = swipeViewControllerModel.currentIndex
    let countOfControllers = viewControllers.count
    let tapDirextion = swipeViewControllerModel.getDirectionAndNextIndex(viewWidth: viewWidth, tapLocationX: tapLocationX, currentIndex: currentIndex, countOfControllers: countOfControllers).direction
    return tapDirextion
  }
  
  func tapControllerIndexOfCurrentController(_ tapController: TapController) -> Int {
    return swipeViewControllerModel.currentIndex
  }
  
  func tapControllerCountOfControllers(_ tapController: TapController) -> Int {
    return viewControllers.count
  }
}

//MARK: - TapControllerDelegate
extension SwipeViewController: TapControllerDelegate {
  
  func tapControllerDidTapForward(_ tapController: TapController, nextIndex: Int) {
    TimerManager.shred.invalidateTimer()
    let currentVC = viewControllers[nextIndex]
    pagingVC.setViewControllers([currentVC], direction: .forward, animated: true) {[weak self] (finished) in
      guard let self = self else {return}
      if finished {
        self.swipeViewControllerModel.set(currentIndex: nextIndex)
        self.swipeViewControllerModel.setBarColor(barStackView: self.barStackView, currentIndex: self.swipeViewControllerModel.currentIndex)
      }
    }
  }
  
  func tapControllerDidTapBack(_ tapController: TapController, nextIndex: Int) {
    TimerManager.shred.invalidateTimer()
    let currentVC = viewControllers[nextIndex]
    pagingVC.setViewControllers([currentVC], direction: .reverse , animated: true) {[weak self] (finished) in
      guard let self = self else {return}
      if finished {
        self.swipeViewControllerModel.set(currentIndex: nextIndex)
        self.swipeViewControllerModel.setBarColor(barStackView: self.barStackView, currentIndex: self.swipeViewControllerModel.currentIndex)
      }
    }
  }
  
  func tapControllerDidTap(_ tapController: TapController, gesture: UITapGestureRecognizer) {
    let locationX = gesture.location(in: view).x
    swipeViewControllerModel.set(locationX: locationX)
  }
}

//MARK: - TimerManagerDataSource
extension SwipeViewController: TimerManagerDataSource {
  
  func timerManagerTimeInterval(_ timerManager: TimerManager) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for SwipeViewController")
    }
    return dataSource.swipeViewControllerTimeIntervalOfAutoScrolling(self)
  }
}

//MARK: - TimerManagerDelegate
extension SwipeViewController: TimerManagerDelegate {
  
  func timerManagerFires(_ timerManager: TimerManager, timer: Timer) {
    let currentIndex = swipeViewControllerModel.currentIndex
    let countOfControllers = viewControllers.count
    let nextIndex = swipeViewControllerModel.getForwardNextIndex(currentIndex: currentIndex, countOfControllers: countOfControllers)
    let currentVC = viewControllers[nextIndex]
    pagingVC.setViewControllers([currentVC], direction: .forward, animated: true) {[weak self] (finished) in
      guard let self = self else {return}
      if finished {
        self.swipeViewControllerModel.set(currentIndex: nextIndex)
        self.swipeViewControllerModel.setBarColor(barStackView: self.barStackView, currentIndex: self.swipeViewControllerModel.currentIndex)
      }
    }
  }
  
  func timerManagerInvalidate(_ timerManager: TimerManager) {
    print("Invalidate Timer")
  }
}
