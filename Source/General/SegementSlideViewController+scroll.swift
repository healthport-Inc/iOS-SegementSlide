//
//  SegementSlideViewController+scroll.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

extension SegementSlideViewController {
    
    internal func parentScrollViewDidScroll(_ parentScrollView: UIScrollView) {
        defer {
            scrollViewDidScroll(parentScrollView, isParent: true)
        }
        let parentContentOffsetY = parentScrollView.contentOffset.y
        
        /// SwitcherView가 멈출 곳을 기존의 높이에서 상단 네비뷰의 높이까지 계산해준다.
        let stickyHeight = self.headerStickyHeight - self.headerNaviViewHeight
        switch innerBouncesType {
        case .parent:
            if !canParentViewScroll {
                parentScrollView.contentOffset.y = stickyHeight
                canChildViewScroll = true
            } else if parentContentOffsetY >= stickyHeight {
                parentScrollView.contentOffset.y = stickyHeight
                canParentViewScroll = false
                canChildViewScroll = true
            } else {
                resetOtherCachedChildViewControllerContentOffsetY()
            }
        case .child:
            let childBouncesTranslationY = -parentScrollView.panGestureRecognizer.translation(in: parentScrollView).y.rounded(.up)
            defer {
                lastChildBouncesTranslationY = childBouncesTranslationY
            }
            if !canParentViewScroll {
                parentScrollView.contentOffset.y = headerStickyHeight
                canChildViewScroll = true
            } else if parentContentOffsetY >= headerStickyHeight {
                parentScrollView.contentOffset.y = headerStickyHeight
                canParentViewScroll = false
                canChildViewScroll = true
            } else if parentContentOffsetY <= 0 {
                parentScrollView.contentOffset.y = 0
                canChildViewScroll = true
                resetOtherCachedChildViewControllerContentOffsetY()
            } else {
                guard let childScrollView = currentSegementSlideContentViewController?.scrollView else {
                    resetOtherCachedChildViewControllerContentOffsetY()
                    return
                }
                if childScrollView.contentOffset.y < 0 {
                    if childBouncesTranslationY > lastChildBouncesTranslationY {
                        scrollView.contentOffset.y = 0
                        canChildViewScroll = true
                    } else {
                        canChildViewScroll = false
                    }
                } else {
                    canChildViewScroll = false
                }
                resetOtherCachedChildViewControllerContentOffsetY()
            }
        }
    }
    
    internal func childScrollViewDidScroll(_ childScrollView: UIScrollView) {
        defer {
            scrollViewDidScroll(childScrollView, isParent: false)
        }
        let parentContentOffsetY = scrollView.contentOffset.y
        let childContentOffsetY = childScrollView.contentOffset.y
        switch innerBouncesType {
        case .parent:
            if !canChildViewScroll {
                childScrollView.contentOffset.y = 0
            } else if childContentOffsetY <= 0 {
                /// 현재 ContentView의 스크롤이 불가능하고, SwitcherView의 Select를 통해 Scroll 되었다면
                /// 현재 상태를 유지하도록 한다.
                if self.contentView.isScrollEnabled == false, self.isScrolledBySelectItem {
                    self.isScrolledBySelectItem = false
                } else {
                    canChildViewScroll = false
                    canParentViewScroll = true
                }
            }
        case .child:
            if !canChildViewScroll {
                childScrollView.contentOffset.y = 0
            } else if childContentOffsetY <= 0 {
                if parentContentOffsetY <= 0 {
                    canChildViewScroll = true
                }
                canParentViewScroll = true
            } else {
                if parentContentOffsetY > 0 && parentContentOffsetY < headerStickyHeight {
                    canChildViewScroll = false
                }
            }
        }
    }
    
}
