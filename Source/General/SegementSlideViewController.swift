//
//  SegementSlideViewController.swift
//  SegementSlide
//
//  Created by Jiar on 2018/12/7.
//  Copyright © 2018 Jiar. All rights reserved.
//

import UIKit

public enum BouncesType {
    case parent
    case child
}

open class SegementSlideViewController: UIViewController {
    
    public internal(set) var scrollView: SegementSlideScrollView!
    public internal(set) var headerView: SegementSlideHeaderView!
    public internal(set) var contentView: SegementSlideContentView!
    public internal(set) var switcherView: SegementSlideSwitcherDelegate!
    public var safeAreaBottomConstraint: NSLayoutConstraint?
    internal var innerHeaderView: UIView?
    
    internal var safeAreaTopConstraint: NSLayoutConstraint?
    internal var parentKeyValueObservation: NSKeyValueObservation?
    internal var childKeyValueObservations: [String: NSKeyValueObservation] = [:]
    internal var innerBouncesType: BouncesType = .parent
    internal var canParentViewScroll: Bool = true
    internal var canChildViewScroll: Bool = false
    internal var lastChildBouncesTranslationY: CGFloat = 0
    internal var cachedChildViewControllerIndex: Set<Int> = Set()
    /// SwitcherView를 통해 스크롤을 했는지 여부를 묻는 변수.
    internal var isScrolledBySelectItem: Bool = false
    
    /// 상단에 NavigationView의 높이를 더해서 SwitcherView가 멈출 곳을 계산한다.
    public var headerNaviViewHeight: CGFloat = 0.0
    /// 직접 스크롤하여 다음 페이지로 넘어가지 못하도록 방지한다.
    public var isScrollEnabled: Bool {
        get {
            self.contentView.isScrollEnabled
        }
        set {
            self.contentView.isScrollEnabled = newValue
        }
    }
    public var headerStickyHeight: CGFloat {
        let headerHeight = headerView.frame.height.rounded(.up)
        if edgesForExtendedLayout.contains(.top) {
            return headerHeight - topLayoutLength
        } else {
            return headerHeight
        }
    }
    public var switcherHeight: CGFloat {
        return switcherView.ssDataSource?.height ?? 44
    }
    public var contentViewHeight: CGFloat {
        return view.bounds.height-topLayoutLength-switcherHeight
    }
    public var currentIndex: Int? {
        return switcherView.ssSelectedIndex
    }
    public var currentSegementSlideContentViewController: SegementSlideContentScrollViewDelegate? {
        guard let currentIndex = currentIndex else {
            return nil
        }
        return contentView.dequeueReusableViewController(at: currentIndex)
    }
    
    /// you should call `reloadData()` after set this property.
    open var defaultSelectedIndex: Int? {
        didSet {
            switcherView.ssDefaultSelectedIndex = defaultSelectedIndex
            contentView.defaultSelectedIndex = defaultSelectedIndex
        }
    }
    
    open var bouncesType: BouncesType {
        return .parent
    }
    
    open func segementSlideHeaderView() -> UIView? {
        if edgesForExtendedLayout.contains(.top) {
            #if DEBUG
            assert(false, "must override this variable")
            #endif
            return nil
        } else {
            return nil
        }
    }
    
    open func segementSlideSwitcherView() -> SegementSlideSwitcherDelegate {
        #if DEBUG
        assert(false, "must override this variable")
        #endif
        return SegementSlideSwitcherEmptyView()
    }
    
    open func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        #if DEBUG
        assert(false, "must override this function")
        #endif
        return nil
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {
        
    }
    
    /// 헤더뷰 쪽에 대한 드래그를 시작하고 끝나는 시점을 알기 위한 함수
    open func parentViewDidEndDragging(_ scrollView: UIScrollView) {
        
    }
    open func parentViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    open func didSelectContentViewController(at index: Int) {
        
    }
    
    open func setupHeader() {
        innerHeaderView = segementSlideHeaderView()
    }
    
    open func setupSwitcher() {

    }
    
    open func setupContent() {
        cachedChildViewControllerIndex.removeAll()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSegementSlideScrollView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    /// reload headerView, SwitcherView and ContentView
    ///
    /// you should set `defaultSelectedIndex` before call this method.
    /// otherwise, no item will be selected.
    /// however, if an item was previously selected, it will be reSelected.
    public func reloadData() {
        setupBounces()
        setupHeader()
        setupSwitcher()
        setupContent()
        contentView.reloadData()
        switcherView.reloadData()
        layoutSegementSlideScrollView()
    }
    
    /// reload headerView
    public func reloadHeader() {
        setupHeader()
        layoutSegementSlideScrollView()
    }
    
    /// reload SwitcherView
    public func reloadSwitcher() {
        setupSwitcher()
        switcherView.reloadData()
        layoutSegementSlideScrollView()
    }
    
    /// reload ContentView
    public func reloadContent() {
        setupContent()
        contentView.reloadData()
    }
    
    /// select one item by index
    public func selectItem(at index: Int, animated: Bool) {
        switcherView.selectItem(at: index, animated: animated)
    }
    
    /// reuse the `SegementSlideContentScrollViewDelegate`
    public func dequeueReusableViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return contentView.dequeueReusableViewController(at: index)
    }
    
    deinit {
        parentKeyValueObservation?.invalidate()
        cleanUpChildKeyValueObservations()
        NotificationCenter.default.removeObserver(self, name: SegementSlideContentView.willCleanUpAllReusableViewControllersNotification, object: nil)
        #if DEBUG
        debugPrint("\(type(of: self)) deinit")
        #endif
    }
    
}
