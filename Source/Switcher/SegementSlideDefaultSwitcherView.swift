//
//  SegementSlideDefaultSwitcherView.swift
//  SegementSlide
//
//  Created by Jiar on 2018/12/7.
//  Copyright © 2018 Jiar. All rights reserved.
//

import UIKit

public enum SwitcherType {
    case tab
    case segement
}

public protocol SegementSlideDefaultSwitcherViewDelegate: class {
    var titlesInSegementSlideSwitcherView: [String] { get }
    
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, didSelectAtIndex index: Int, animated: Bool)
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, showBadgeAtIndex index: Int) -> BadgeType
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, willSelectAtIndex index: Int, animated: Bool)
}

extension SegementSlideDefaultSwitcherViewDelegate {
    public func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, willSelectAtIndex index: Int, animated: Bool) { }
}

public class SegementSlideDefaultSwitcherView: UIView {
    
    public private(set) var scrollView = UIScrollView()
    private let indicatorView = UIView()
    private let lowerLine = UIView()
    
    
    /// SwitcherView 버튼의 타이틀을 AttributedString으로 적용하기 위한 프로퍼티.
    public var selectedConfig: [NSAttributedString.Key : Any]?
    public var normalConfig: [NSAttributedString.Key : Any]?
    
    private var titleButtons: [UIButton] = []
    private var innerConfig: SegementSlideDefaultSwitcherConfig = SegementSlideDefaultSwitcherConfig.shared
    
    /// you should call `reloadData()` after set this property.
    open var defaultSelectedIndex: Int?
    
    public private(set) var selectedIndex: Int?
    public weak var delegate: SegementSlideDefaultSwitcherViewDelegate?
    
    /// you must call `reloadData()` to make it work, after the assignment.
    public var config: SegementSlideDefaultSwitcherConfig = SegementSlideDefaultSwitcherConfig.shared
    
    public override var intrinsicContentSize: CGSize {
        return scrollView.contentSize
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(scrollView)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.constraintToSuperview()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.backgroundColor = .clear
        backgroundColor = .white
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        reloadContents()
        reloadBadges()
        updateSelectedIndex()
    }
    
    /// relayout subViews
    ///
    /// you should set `defaultSelectedIndex` before call this method.
    /// otherwise, no item will be selected.
    /// however, if an item was previously selected, it will be reSelected.
    public func reloadData() {
        reloadSubViews()
        reloadContents()
        reloadBadges()
        reloadDataWithSelectedIndex()
    }
    
    /// reload all badges in `SegementSlideSwitcherView`
    public func reloadBadges() {
        for (index, titleButton) in titleButtons.enumerated() {
            guard let type = delegate?.segementSwitcherView(self, showBadgeAtIndex: index) else {
                titleButton.badge.type = .none
                continue
            }
            titleButton.badge.type = type
            if case .none = type {
                continue
            }
            let titleLabelText = titleButton.titleLabel?.text ?? ""
            let width: CGFloat
            if selectedIndex == index {
                width = titleLabelText.boundingWidth(with: innerConfig.selectedTitleFont)
            } else {
                width = titleLabelText.boundingWidth(with: innerConfig.normalTitleFont)
            }
            let height = titleButton.titleLabel?.font.lineHeight ?? titleButton.bounds.height
            switch type {
            case .none:
                break
            case .point:
                titleButton.badge.height = innerConfig.badgeHeightForPointType
                titleButton.badge.offset = CGPoint(x: width/2+titleButton.badge.height/2, y: -height/2)
            case .count:
                titleButton.badge.font = innerConfig.badgeFontForCountType
                titleButton.badge.height = innerConfig.badgeHeightForCountType
                titleButton.badge.offset = CGPoint(x: width/2+titleButton.badge.height/2, y: -height/2)
            case .custom:
                titleButton.badge.height = innerConfig.badgeHeightForCustomType
                titleButton.badge.offset = CGPoint(x: width/2+titleButton.badge.height/2, y: -height/2)
            }
        }
    }
    
    /// select one item by index
    public func selectItem(at index: Int, animated: Bool) {
        updateSelectedButton(at: index, animated: animated)
    }
    
}

extension SegementSlideDefaultSwitcherView {
    
    private func reloadDataWithSelectedIndex() {
        guard let index = selectedIndex else {
            return
        }
        selectedIndex = nil
        updateSelectedButton(at: index, animated: false)
    }
    
    private func updateSelectedIndex() {
        if let index = selectedIndex  {
            updateSelectedButton(at: index, animated: false)
        } else if let index = defaultSelectedIndex {
            updateSelectedButton(at: index, animated: false)
        }
    }
    
    private func reloadSubViews() {
        for titleButton in titleButtons {
            titleButton.removeFromSuperview()
            titleButton.frame = .zero
        }
        titleButtons.removeAll()
        indicatorView.removeFromSuperview()
        indicatorView.frame = .zero
        scrollView.isScrollEnabled = innerConfig.type == .segement
        innerConfig = config
        guard let titles = delegate?.titlesInSegementSlideSwitcherView,
            !titles.isEmpty else {
            return
        }
        for (index, title) in titles.enumerated() {
            
            /// attributes가 있으면 해당 attributes로 타이틀을 설정한다.
            let button = UIButton(type: .custom)
            if let config = self.normalConfig {
                let attrStr = NSMutableAttributedString(string: title, attributes: config)
                button.setAttributedTitle(attrStr, for: .normal)
            } else {
                button.titleLabel?.font = innerConfig.normalTitleFont
                button.setTitle(title, for: .normal)
                button.setTitleColor(innerConfig.normalTitleColor, for: .normal)
            }
            
            button.clipsToBounds = false
            button.backgroundColor = .clear
            button.tag = index
            button.addTarget(self, action: #selector(didClickTitleButton), for: .touchUpInside)
            scrollView.addSubview(button)
            titleButtons.append(button)
        }
        
        scrollView.addSubview(lowerLine)
        lowerLine.backgroundColor = UIColor(red: 0.87, green: 0.88, blue: 0.90, alpha: 1.00)
        
        scrollView.addSubview(indicatorView)
        indicatorView.layer.masksToBounds = true
        indicatorView.layer.cornerRadius = innerConfig.indicatorHeight/2
        indicatorView.backgroundColor = innerConfig.indicatorColor
    }
    
    private func reloadContents() {
        guard scrollView.frame != .zero else {
            return
        }
        guard !titleButtons.isEmpty else {
            scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height)
            return
        }
        
        /// switcherView의 버튼들이 margin값을 가질 필요가 없어 제거.
        /// 버튼의 Size는 뷰의 넓이에 버튼 갯수를 나눠서 구한다.
        var offsetX: CGFloat = 0
        for titleButton in titleButtons {
            let buttonWidth: CGFloat = scrollView.frame.width / CGFloat(titleButtons.count)
            
            titleButton.frame = CGRect(x: offsetX, y: 0, width: buttonWidth, height: scrollView.bounds.height)
            offsetX += buttonWidth
        }
        scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height)
        
        /// 버튼 아래에 보이는 회색 줄에 대한 frame 설정.
        let size = CGSize(width: scrollView.frame.width, height: 1)
        let origin = CGPoint(x: scrollView.frame.origin.x, y: scrollView.frame.maxY - size.height)
        lowerLine.frame = CGRect(origin: origin, size: size)
    }
    
    private func updateSelectedButton(at index: Int, animated: Bool) {
        guard scrollView.frame != .zero else {
            return
        }
        guard index != selectedIndex else {
            return
        }
        let count = titleButtons.count
        if let selectedIndex = selectedIndex {
            guard selectedIndex >= 0, selectedIndex < count else {
                return
            }
            let selectedTitleButton = titleButtons[selectedIndex]
            /// 위에서 Attributes로 설정한 타이틀이 존재 한다면
            /// 해당 타이틀로 다시 Attributes를 설정해준다.
            if let config = self.normalConfig, let title = selectedTitleButton.attributedTitle(for: .normal) {
                let attStr = NSMutableAttributedString(string: title.string, attributes: config)
                selectedTitleButton.setAttributedTitle(attStr, for: .normal)
            } else {
                selectedTitleButton.setTitleColor(innerConfig.normalTitleColor, for: .normal)
                selectedTitleButton.titleLabel?.font = innerConfig.normalTitleFont
            }
            
        }
        guard index >= 0, index < count else {
            return
        }
        
        let titleButton = titleButtons[index]
        /// 위에서 Attributes로 설정한 타이틀이 존재 한다면
        /// 해당 타이틀로 다시 Attributes를 설정해준다.
        if let config = self.selectedConfig, let title = titleButton.attributedTitle(for: .normal) {
            let attStr = NSMutableAttributedString(string: title.string, attributes: config)
            titleButton.setAttributedTitle(attStr, for: .normal)
        } else {
            titleButton.setTitleColor(innerConfig.selectedTitleColor, for: .normal)
            titleButton.titleLabel?.font = innerConfig.selectedTitleFont
        }
        
        
        if animated, indicatorView.frame != .zero {
            UIView.animate(withDuration: 0.25) {
                /// 버튼 아래 인디케이터의 길이는 버튼과 길이가 같아야 하므로
                /// titleButton.frame.width로 설정한다.
                self.indicatorView.frame = CGRect(x: titleButton.frame.origin.x, y: self.frame.height-self.innerConfig.indicatorHeight, width: titleButton.frame.width, height: self.innerConfig.indicatorHeight)
            }
        } else {
            /// 버튼 아래 인디케이터의 길이는 버튼과 길이가 같아야 하므로
            /// titleButton.frame.width로 설정한다.
            indicatorView.frame = CGRect(x: titleButton.frame.origin.x, y: frame.height-innerConfig.indicatorHeight, width: titleButton.frame.width, height: innerConfig.indicatorHeight)
        }
        if case .segement = innerConfig.type {
            var offsetX = titleButton.frame.origin.x-(scrollView.bounds.width-titleButton.bounds.width)/2
            if offsetX < 0 {
                offsetX = 0
            } else if (offsetX+scrollView.bounds.width) > scrollView.contentSize.width {
                offsetX = scrollView.contentSize.width-scrollView.bounds.width
            }
            if scrollView.contentSize.width > scrollView.bounds.width {
                scrollView.setContentOffset(CGPoint(x: offsetX, y: scrollView.contentOffset.y), animated: animated)
            }
        }
        self.selectedIndex = index
        delegate?.segementSwitcherView(self, didSelectAtIndex: index, animated: animated)
    }
    
    
    @objc
    private func didClickTitleButton(_ button: UIButton) {
        selectItem(at: button.tag, animated: true)
    }
    
}
