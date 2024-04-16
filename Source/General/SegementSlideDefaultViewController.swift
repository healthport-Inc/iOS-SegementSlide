//
//  SegementSlideDefaultViewController.swift
//  SegementSlide
//
//  Created by Jiar on 2020/5/6.
//

import UIKit

open class SegementSlideDefaultViewController: SegementSlideViewController {
    public var scrolledAtSwitch: Bool {
        get {
            let yOffset = self.headerStickyHeight - self.headerNaviViewHeight
            return self.scrollView.contentOffset.y == yOffset
        }
    }
    private let defaultSwitcherView = SegementSlideDefaultSwitcherView()
    
    public override func segementSlideSwitcherView() -> SegementSlideSwitcherDelegate {
        defaultSwitcherView.delegate = self
        defaultSwitcherView.ssDataSource = self
        return defaultSwitcherView
    }
    
    /// 선택된 버튼과 선택 되지 않은 버튼에 대한 Attributes 프로퍼티.
    public var selectedConfig: [NSAttributedString.Key : Any]? {
        didSet {
            self.defaultSwitcherView.selectedConfig = self.selectedConfig
        }
    }
    public var normalConfig: [NSAttributedString.Key : Any]? {
        didSet {
            self.defaultSwitcherView.normalConfig = self.normalConfig
        }
    }
    
    open override func setupSwitcher() {
        super.setupSwitcher()
        defaultSwitcherView.config = switcherConfig
    }
    
    open func selectTitle(_ index: Int, animated: Bool) {
        self.isScrolledBySelectItem = true
        /// Switcher 버튼을 눌렀을 때 ContentView의 스크롤이 불가능한 상태이면 이 함수가 호출 된다.
    }
    
    open var switcherConfig: SegementSlideDefaultSwitcherConfig {
        return SegementSlideDefaultSwitcherConfig.shared
    }
    
    open override var switcherHeight: CGFloat {
        return 44
    }
    
    open var titlesInSwitcher: [String] {
        return []
    }
    
    open func showBadgeInSwitcher(at index: Int) -> BadgeType {
        return .none
    }
    
    /// reload badges in SwitcherView
    public func reloadBadgeInSwitcher() {
        defaultSwitcherView.reloadBadges()
    }
    /// 스크롤뷰를 switcherView가 있는 곳 까지 scroll 하도록 한다.
    public func scrollToSwitch(_ completionHandler: (() -> Void)? = nil) {
        let keypath = "contentOffsetAnimationDuration"
        guard let duration = self.scrollView.value(forKey: keypath) as? Double else { return }
        
        let yOffset = self.headerStickyHeight - self.headerNaviViewHeight
        let origin = CGPoint(x: 0.0, y: yOffset)
        self.scrollView.setContentOffset(origin, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            completionHandler?()
        })
    }
}

extension SegementSlideDefaultViewController: SegementSlideSwitcherDataSource {
    
    public var height: CGFloat {
        return switcherHeight
    }
    
    public var titles: [String] {
        return titlesInSwitcher
    }
    
}

extension SegementSlideDefaultViewController: SegementSlideDefaultSwitcherViewDelegate {
    
    public var titlesInSegementSlideSwitcherView: [String] {
        return switcherView.ssDataSource?.titles ?? []
    }
    
    public func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, didSelectAtIndex index: Int, animated: Bool) {
        guard contentView.scrollView.isScrollEnabled else {
            return
        }
        if contentView.selectedIndex != index {
            contentView.selectItem(at: index, animated: animated)
        }
    }
    
    public func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, showBadgeAtIndex index: Int) -> BadgeType {
        return showBadgeInSwitcher(at: index)
    }
    
    public func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, didSelectTitleAt index: Int, animated: Bool) {
        
        self.selectTitle(index, animated: animated)
    }
}
