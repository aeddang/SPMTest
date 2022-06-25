//
//  InfinityListView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/16.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum InfinityScrollUIEvent {
    case reload, scrollMove(Int, UnitPoint? = nil), scrollTo(Int, UnitPoint? = nil)
}
enum InfinityScrollEvent {
    case up, down, bottom, top, pull, pullCompleted, pullCancel, ready
}
enum InfinityScrollStatus: String{
    case scroll, pull, pullCancel
}
enum InfinityScrollItemEvent {
    case select(InfinityData), delete(InfinityData), declaration(InfinityData)
}
enum InfinityScrollType :Equatable{
    case reload(isDragEnd:Bool? = nil),
         vertical(isDragEnd:Bool? = nil),
         horizontal(isDragEnd:Bool? = nil),
         web(isDragEnd:Bool? = nil)
    
    static func ==(lhs: InfinityScrollType, rhs: InfinityScrollType) -> Bool {
        switch (lhs, rhs) {
        case ( .reload, .reload):return true
        case ( .vertical, .vertical):return true
        case ( .horizontal, .horizontal):return true
        case ( .web, .web):return true
        default: return false
        }
    }
}

class InfinityScrollModel:ComponentObservable{
    static let onTopSize:CGSize = SystemEnvironment.isTablet
        ? CGSize(width:72, height:72)
        : CGSize(width:60, height:60)
        
    static let onTopSizeKids:CGSize = SystemEnvironment.isTablet
        ? CGSize(width:178, height:146)
        : CGSize(width:93, height:76)
    
    static let PULL_RANGE:CGFloat = 40
    static let PULL_COMPLETED_RANGE:CGFloat = 40
    static let DRAG_RANGE:CGFloat = 70
    static let DRAG_COMPLETED_RANGE:CGFloat = 50
    @Published var uiEvent:InfinityScrollUIEvent? = nil {
        didSet{if self.uiEvent != nil { self.uiEvent = nil}}
    }
    @Published var event:InfinityScrollEvent? = nil
    @Published var scrollStatus:InfinityScrollStatus = .scroll
    @Published var itemEvent:InfinityScrollItemEvent? = nil {
        didSet{if self.itemEvent != nil { self.itemEvent = nil}}
    }
    @Published private(set) var isCompleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var page = 0
    @Published private(set) var total = 0
    @Published fileprivate(set) var pullPosition:CGFloat = 0
    @Published fileprivate(set) var scrollPosition:CGFloat = 0
    fileprivate(set) var prevPosition:CGFloat = 0
    fileprivate(set) var minDiff:CGFloat = 0
    fileprivate(set) var appearList:[Int] = []
    fileprivate(set) var appearValue:Float = 0

    var initIndex:Int? = nil
   
    let idstr:String = UUID().uuidString
    let topIdx:Int = UUID.init().hashValue
    var size = 20
    var isLoadable:Bool {
        get {
            return !self.isLoading && !self.isCompleted
        }
    }
    
    fileprivate(set) var isScrollEnd:Bool = false
    private(set) var isDragEnd:Bool = false
    private(set) var limitedScrollIndex:Int = -1
    private(set) var pullRange:CGFloat = 40
    private(set) var pullCompletedRange:CGFloat = 50
    private(set) var updateScrollDiff:CGFloat = 1.0
    private(set) var updatePullDiff:CGFloat = 0.3
    private(set) var cancelPullDiff:CGFloat = 5
    private(set) var completePullDiff:CGFloat = 40
    private(set) var cancelPullRange:CGFloat = 40
    private(set) var topRange:CGFloat = 80
    private(set) var type: InfinityScrollType = .vertical(isDragEnd: false)
    private(set) var scrollSizeVertical:CGSize = CGSize(width: 375, height: 740)
    private(set) var scrollSizeHorizental:CGSize = CGSize(width: 375, height: 740)
    var isSetup:Bool = false
    init(limitedScrollIndex:Int = -1) {
        self.limitedScrollIndex = limitedScrollIndex
        super.init()
    }
    
    @discardableResult
    func setup(type: InfinityScrollType? = nil, scrollSize:CGSize? = nil) -> InfinityScrollModel {
        let type:InfinityScrollType = type ?? self.type
        let size:CGSize = scrollSize ?? self.scrollSizeVertical
        self.type = type
    
        switch type {
        case .horizontal (let end):
            pullRange = InfinityScrollModel.DRAG_RANGE
            pullCompletedRange = InfinityScrollModel.DRAG_COMPLETED_RANGE
            updatePullDiff = 0.3
            cancelPullDiff = size.width*5/375
            completePullDiff = size.width*40/375
            cancelPullRange = pullRange
            isDragEnd = end ?? false
            
        case .vertical (let end):
            pullRange = InfinityScrollModel.DRAG_RANGE
            pullCompletedRange = InfinityScrollModel.DRAG_COMPLETED_RANGE
            updatePullDiff = 0.3
            cancelPullDiff = size.height*10/740
            completePullDiff = size.height*50/740
            cancelPullRange = pullRange
            isDragEnd = end ?? false
            
        case .reload (let end):
            pullRange = InfinityScrollModel.PULL_RANGE
            pullCompletedRange = InfinityScrollModel.PULL_COMPLETED_RANGE
            updatePullDiff = 0.3
            cancelPullDiff = 10
            completePullDiff = 1000
            cancelPullRange = pullRange
            isDragEnd = end ?? false
            
        case .web (let end):
            pullRange = 0
            pullCompletedRange = InfinityScrollModel.DRAG_RANGE + InfinityScrollModel.DRAG_COMPLETED_RANGE
            updatePullDiff = 0.3
            cancelPullDiff = 10
            completePullDiff = 1000
            cancelPullRange = 30
            isDragEnd = end ?? true
        }
        self.isSetup = true
        return self
    }
    
    func reload(){
        self.isCompleted = false
        self.page = 0
        self.total = 0
        self.isLoading = false
    }
    
    func onLoad(){
        self.isLoading = true
    }
    
    func onComplete(itemCount:Int){
        isCompleted =  size > itemCount
        self.total = self.total + itemCount
        self.page = self.page + 1
        self.isLoading = false
    }
    
    func onError(){
        self.isLoading = false
    }
    
    
    fileprivate func onMove(pos:CGFloat){
        if self.isScrollEnd {
            return
        }
        let diff = self.prevPosition - pos
        //ComponentLog.d("diff " + diff.description, tag: "InfinityScrollViewProtocol")
        if abs(diff) > 10000 { return }
        if abs(diff) > self.minDiff{
            self.scrollPosition = pos
            self.prevPosition = ceil(pos)
        }
        if diff > 30 { return }
        if pos >= self.pullRange && self.scrollStatus != .pullCancel {
            if self.scrollStatus != .pull {
                self.onPullInit()
            }
            self.minDiff = self.updatePullDiff
            if diff < -self.completePullDiff {
                ComponentLog.d("onPullCompleted pull range " + diff.description, tag: "InfinityScrollViewProtocol")
                self.onPullCompleted()
                return
            }
            if diff > self.cancelPullDiff {
                if (pos + diff) >= (self.pullCompletedRange + self.pullRange){
                    ComponentLog.d("onPullCompleted " + diff.description , tag: "InfinityScrollViewProtocol")
                    self.isScrollEnd = self.isDragEnd
                    self.onPullCompleted()
                } else {
                    ComponentLog.d("onPullCancel pull " + self.isScrollEnd.description , tag: "InfinityScrollViewProtocol")
                    self.onPullCancel()
                }
                //self.onPullCancel()
                self.prevPosition = ceil(pos)
                return
            }
            if abs(diff) > self.minDiff {
                //ComponentLog.d("onPull pos " + pos.description, tag: "InfinityScrollViewProtocol")
                self.onPull(pos: pos)
            }
            if pos == 0 && diff > 0 {
                ComponentLog.d("onPullCancel pos", tag: "InfinityScrollViewProtocol")
                self.onPullCancel()
                self.prevPosition = ceil(pos)
            }
            return
        }
        
        
        if pos >= -self.topRange && pos < self.cancelPullRange {
            if self.scrollStatus == .pull {
                ComponentLog.d("onPullCancel scroll", tag: "InfinityScrollViewProtocol")
                self.onPullCancel()
                self.prevPosition = ceil(pos)
            }
            self.minDiff = self.updateScrollDiff
            onTop()
        } else {
            if diff < -1 {
                self.onUp()
            }
            if diff > 1 {
                self.onDown()
            }
        }
        if self.scrollStatus != .scroll {
            self.scrollStatus = .scroll
        }
    }

    var delayUpdateSubscription:AnyCancellable?
    func delayUpdate(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = Timer.publish(
            every: 0.05, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.delayUpdateSubscription?.cancel()
                self.onUpdate()
            }
    }
    func onAppear(idx:Int){
        if self.appearList.first(where: {$0 == idx}) == nil {
            self.appearList.append(idx)
        }
        self.delayUpdate()
    }
    
    func onDisappear(idx:Int){
        if let find = self.appearList.firstIndex(where: {$0 == idx}) {
            self.appearList.remove(at: find)
        }
        self.delayUpdate()
    }
    
    
    private func onUpdate(){
        if self.appearList.isEmpty { return }
        self.appearList.sort()
        let value = Float(self.appearList.reduce(0, {$0 + $1}) / self.appearList.count)
        let diff = self.appearValue - value
        self.appearValue = value
        if diff > 0 {
            self.onUp()
            return
        }
        if  diff < 0 {
            self.onDown()
        }
    }
    func pullCancel(){
        if self.scrollStatus == .pull {
            self.onPullCancel()
        }
    }
    private func onPull(pos:CGFloat){
        if self.scrollStatus == .pullCancel { return }
        self.pullPosition = pos
        self.event = .pull
        //self.autoReset()
    }
    private func onPullInit(){
        self.event = .pull
        self.scrollStatus = .pull
    }
    private func onPullCompleted(){
        self.event = .pullCompleted
        self.isScrollEnd = self.isDragEnd
        self.scrollStatus = .pullCancel
        //self.clearAutoReset()
    }
    private  func onPullCancel(){
        if self.scrollStatus == .scroll { return }
        self.event = .pullCancel
        self.pullPosition = 0
        self.isScrollEnd = false
        self.scrollStatus = .pullCancel
        //self.clearAutoReset()
    }
    
    private func onBottom(){
        if self.event == .bottom { return }
        self.event = .bottom
        ComponentLog.d("onBottom", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onTop(){
        if self.event == .top { return }
        self.event = .top
        ComponentLog.d("onTop", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onUp(){
        if self.event == .up { return }
        self.event = .up
        self.pullCancel()
        ComponentLog.d("onUp", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onDown(){
        if self.event == .down { return }
        self.event = .down
        self.pullCancel()
        ComponentLog.d("onDown", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    /*
    private var autoResetSubscription:AnyCancellable?
    private func autoReset() {
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearAutoReset()
                if self.scrollStatus == .pull {
                    self.onPullCancel()
                }
            }
    }
    
    private func clearAutoReset() {
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = nil
    }*/
}



open class InfinityData:Identifiable, Equatable{
    public var id:String = UUID().uuidString
    public var hashId:Int = UUID().hashValue
    var contentID:String = ""
    var index:Int = -1
    var deleteAble = false
    var declarationAble = false
    public static func == (l:InfinityData, r:InfinityData)-> Bool {
        return l.id == r.id
    }
    
    func resetHashId(){
        self.hashId = UUID().hashValue
    }
}

protocol InfinityScrollViewProtocol :PageProtocol{
    var viewModel:InfinityScrollModel {get set}
    func onReady()
    func onMove(pos:CGFloat)
    func onAppear(idx:Int)
    func onDisappear(idx:Int)
}

extension InfinityScrollViewProtocol {
    func onReady(){
        if let idx = self.viewModel.initIndex {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.uiEvent = .scrollTo(idx)
            }
        }
        self.viewModel.event = .ready
    }
    func onMove(pos:CGFloat){
        self.viewModel.onMove(pos: pos)
    }
    
    func onAppear(idx:Int){
        self.viewModel.onAppear(idx: idx)
    }
    
    func onDisappear(idx:Int){
        self.viewModel.onDisappear(idx: idx)
    }
    
   
}


