//
//  SegementSlideDefaultViewController.swift
//  SegementSlide
//
//  Created by Jiar on 2020/5/6.
//

import UIKit

open class SegementSlideDefaultViewController: SegementSlideViewController {
    
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
        if contentView.selectedIndex != index {
            contentView.selectItem(at: index, animated: animated)
        }
    }
    
    public func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, showBadgeAtIndex index: Int) -> BadgeType {
        return showBadgeInSwitcher(at: index)
    }
    
}
