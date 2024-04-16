//
//  SegementSlideViewController+delegate.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

extension SegementSlideViewController: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        resetScrollViewStatus()
        resetCurrentChildViewControllerContentOffsetY()
        return true
    }
    
    /// 헤더뷰쪽 스크롤의 드래그 시점을 호출하기 위해 Delegate 함수 활용.
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.parentViewDidEndDragging(scrollView)
    }
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.parentViewWillBeginDragging(scrollView)
    }
}

extension SegementSlideViewController: SegementSlideContentDelegate {
    
    public var segementSlideContentScrollViewCount: Int {
        return switcherView.ssDataSource?.titles.count ?? 0
    }
    
    public func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return segementSlideContentViewController(at: index)
    }
    
    public func segementSlideContentView(_ segementSlideContentView: SegementSlideContentView, didSelectAtIndex index: Int, animated: Bool) {
        cachedChildViewControllerIndex.insert(index)
        if switcherView.ssSelectedIndex != index {
            switcherView.selectItem(at: index, animated: animated)
        }
        guard let childViewController = segementSlideContentView.dequeueReusableViewController(at: index) else {
            return
        }
        defer {
            didSelectContentViewController(at: index)
        }
        guard let childScrollView = childViewController.scrollView else {
            return
        }
        let key = String(format: "%p", childScrollView)
        guard !childKeyValueObservations.keys.contains(key) else {
            return
        }
        let keyValueObservation = childScrollView.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self else {
                return
            }
            guard change.newValue != change.oldValue else {
                return
            }
            if let contentOffsetY = scrollView.forceFixedContentOffsetY {
                scrollView.forceFixedContentOffsetY = nil
                scrollView.contentOffset.y = contentOffsetY
                return
            }
            
            if self.isScrollEnabled {
                guard index == self.currentIndex else {
                    return
                }
                self.childScrollViewDidScroll(scrollView)
            } else {
                /// contentView의 좌우 스크롤이 불가능 할 때는
                /// switcherView의 index 상관 없이 childScrollView가 scroll 가능하도록 한다.
                self.childScrollViewDidScroll(scrollView)
            }
        })
        childKeyValueObservations[key] = keyValueObservation
    }
    
}
