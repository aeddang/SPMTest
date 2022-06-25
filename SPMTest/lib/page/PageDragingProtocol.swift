//
//  PageDragingProtocol.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
protocol PageDragingProtocol {
    var axis: Axis.Set {get set}
    var isDraging:Bool {get set}
    var isBottom:Bool {get set}
    var bodyOffset:CGFloat {get set}
    var dragInitOffset:CGFloat {get set}
    
    func onPull(geometry:GeometryProxy, value:CGFloat)
    func onPulled(geometry:GeometryProxy)
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value)
    func onDragEnd(geometry:GeometryProxy, value:DragGesture.Value?)
    func onDragCancel()
    
    func onDragInit(offset:CGFloat)
    func onDragingAction(offset:CGFloat, dragOpacity:Double)
    func onDragEndAction(isBottom:Bool, offset:CGFloat)
}

protocol PageDragingView : PageView, PageDragingProtocol {}

extension PageDragingView{
    var axis: Axis.Set {get{.vertical} set{axis = .vertical}}
    var isBottom:Bool {get{false} set{isBottom = false}}
    
    private func moveOffset(_ value:CGFloat, geometry:GeometryProxy) {
        var offset = value
        if offset < 0 { offset = 0 }
        let opc = (self.axis == .vertical)
            ? Double((geometry.size.height - self.bodyOffset)/geometry.size.height)
            : Double((geometry.size.width - self.bodyOffset)/geometry.size.width)
        
        //ComponentLog.d("opc " + opc.description, tag: "opc")
        self.onDragingAction(offset: offset, dragOpacity:opc)
    }
    
    func onPull(geometry:GeometryProxy, value:CGFloat) {
        if self.pageObject?.isPopup == false { return }
        if !self.isDraging { self.onDragInit(offset: 0) }
        let offset = self.bodyOffset + value
        self.moveOffset(offset, geometry:geometry)
    }
    
    func onPulled(geometry:GeometryProxy) {
        self.onDragEnd(geometry:geometry)
    }
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value) {
        if self.pageObject?.isPopup == false { return }
        //ComponentLog.d(value.translation.debugDescription, tag: "translation PageDragingView")
        let offset = (self.axis == .vertical)
            ? value.translation.height
            : value.translation.width
        if !self.isDraging {
            self.onDragInit(offset:offset-self.bodyOffset)
            self.moveOffset(0, geometry:geometry)
        } else {
            self.moveOffset( offset, geometry:geometry)
        }
        
        
    }
    
    func onDragEnd(geometry:GeometryProxy, value:DragGesture.Value? = nil) {
        if self.pageObject?.isPopup == false { return }
        let range = self.axis == .vertical ? geometry.size.height: geometry.size.width
        let diffMin =  self.isBottom ? range*0.66 : range*0.33
        var offset:CGFloat = self.bodyOffset
        if let value = value {
            let predictedOffset = self.axis == .vertical
                            ? value.predictedEndTranslation.height
                            : max(0,value.predictedEndTranslation.width)
            //ComponentLog.d("predictedOffset " + value.predictedEndTranslation.width.description , tag: "onDragEnd")
            offset = offset + predictedOffset
        }
        //ComponentLog.d("offset " + offset.description , tag: "onDragEnd")
        
        var isBottom = false
        if offset > diffMin {
            offset =  range
            isBottom = true
        }else{
            offset = 0
            isBottom = false
        }
        self.onDragEndAction(isBottom:isBottom, offset: offset)
    }
    
    func onDragCancel() {
        if self.pageObject?.isPopup == false { return }
        self.onDragEndAction(isBottom: false, offset: 0)
    }
    
    
}

class PageDragingModel: ObservableObject, PageProtocol, Identifiable{
    static var MIN_DRAG_RANGE:CGFloat = 20

    @Published var uiEvent:PageDragingUIEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    @Published var event:PageDragingEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published var status:PageDragingStatus = .none
    @Published private(set) var nestedScrollEvent:PageNestedScrollEvent? = nil {didSet{ if nestedScrollEvent != nil { nestedScrollEvent = nil} }}
    private(set) var nestedScrollPos:CGFloat = 0
    private(set) var nestedPullPos:CGFloat = 0
    func updateNestedScroll(evt:PageNestedScrollEvent) {
        switch evt {
        case .pullCompleted :
            self.nestedScrollEvent = .pullCompleted
        case .pullCancel :
            self.nestedScrollEvent = .pullCancel
        case .pull(let pos) :
            if nestedPullPos != pos {
                nestedPullPos = pos
                self.nestedScrollEvent = .pull(pos)
            }
        case .scroll(let pos) :
            if nestedScrollPos != pos {
                self.nestedScrollPos = pos
                self.nestedScrollEvent = .scroll(pos)
            }
        }
    }
    
    let cancelGesture =  LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
          .simultaneously(with: RotationGesture(minimumAngleDelta:.zero))
          .simultaneously(with: MagnificationGesture(minimumScaleDelta: 0))
    
      
}

enum PageDragingUIEvent {
    case pull(GeometryProxy, CGFloat),
         pullCompleted(GeometryProxy? = nil),
         pullCancel(GeometryProxy? = nil),
         drag(GeometryProxy, DragGesture.Value),
         draged(GeometryProxy, DragGesture.Value),
         dragCancel,
         setBodyOffset(CGFloat),
         dragEnd(Bool)
}
enum PageDragingEvent {
    case dragInit, drag(CGFloat, Double), draged(Bool,CGFloat)
}
enum PageDragingStatus:String {
    case none,drag,pull
}

enum PageNestedScrollEvent {
    case scroll(CGFloat), pull(CGFloat),pullCompleted ,pullCancel
}


struct PageDragingBody<Content>: PageDragingView  where Content: View{
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDragingModel = PageDragingModel()

    let content: Content
    var axis:Axis.Set
    var initPullRange:CGFloat
    @State var bodyOffset:CGFloat = 0.0
    @State var dragInitOffset:CGFloat = 0.0
    @State var pullOffset:CGFloat = 0
    
    @State var isDraging: Bool = false
    @State var isBottom = false
    @State var isDragInit: Bool = false
    @State var isDragingCompleted = false
    @State private var dragAmount = CGSize.zero
    
    private let minDiff:CGFloat = 4.0
    private let maxDiff:CGFloat = 600
    private var dragingEndAction:((Bool) -> Void)? = nil
    
    init(
        pageObservable:PageObservable,
        viewModel: PageDragingModel,
        axis:Axis.Set = .vertical,
        minPullAmount:CGFloat? = nil,
        dragingEndAction:((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content) {
        self.pageObservable = pageObservable
        self.viewModel = viewModel
        self.axis = axis
        self.content = content()
        self.initPullRange = minPullAmount ?? ( axis == .vertical ? 0 : 0 )
        self.pullOffset = self.initPullRange
        self.dragingEndAction = dragingEndAction
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading){
                self.content.modifier(MatchParent())
                if self.axis == .horizontal {
                    Spacer()
                        .modifier(MatchVertical(width: 15, margin: 0))
                        .background(Color.transparent.clearUi)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.viewModel))
                        /*
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                .onChanged({ value in
                                    self.viewModel.uiEvent = .drag(geometry, value)
                                })
                                .onEnded({ value in
                                    self.viewModel.uiEvent = .draged(geometry, value)
                                })
                        )
                        .gesture(
                            self.viewModel.cancelGesture
                                .onChanged({_ in
                                    self.viewModel.uiEvent = .dragCancel})
                                .onEnded({_ in
                                    self.viewModel.uiEvent = .dragCancel})
                        )*/
                }
            }
            .offset(self.dragAmount)
            .animation(.easeOut(duration: PageContentBody.pageMoveDuration), value: self.dragAmount)
            .onReceive(self.viewModel.$uiEvent){evt in
                switch evt {
                case .pull(let geo, let value) :
                    if value < self.initPullRange { return }
                    if self.viewModel.status != .pull {
                        self.viewModel.status = .pull
                    }
                    let diff = value - self.pullOffset
                    let dr:CGFloat = diff > 0 ? 1 : -1
                    var d = dr * max(abs(diff),minDiff)
                    let m:CGFloat = self.axis == .horizontal ? 1.0 : 1.0
                    if dr == 1 {d = d * m}
                    //ComponentLog.d("pull value " + value.description , tag: "InfinityScrollViewProtocol")
                    if self.viewModel.status != .drag && self.viewModel.status != .pull  {return}
                    self.onPull(geometry: geo, value: d)
                    self.pullOffset = value
                case .pullCompleted:
                    self.onDragEndAction(isBottom: true, offset: self.bodyOffset)
                    self.viewModel.status = .none
                    
                case .pullCancel :
                    self.pullOffset = self.initPullRange
                    self.onDragCancel()
                    self.viewModel.status = .none
                    
                case .drag(let geo, let value) :
                    if self.keyboardObserver.isOn {
                        AppUtil.hideKeyboard()
                    }
                    self.onDraging(geometry: geo, value: value)
                case .draged(let geo, let value) : self.onDragEnd(geometry: geo, value:value)
                case .dragCancel :
                    if self.keyboardObserver.isOn {
                        AppUtil.hideKeyboard()
                    }
                    if self.viewModel.status != .drag { return }
                    self.onDragCancel()
                case .dragEnd(let isBottom) :
                    self.onDragEndAction(isBottom: isBottom, offset: 0)
                case .setBodyOffset(let pos) :
                    self.bodyOffset = pos
                    self.setDragAmount()
                    
                default : break
                }
            }
            .onAppear(){
                self.pullOffset = self.initPullRange
            }
            .onDisappear(){
                
            }
        }//geo
    }//body
    
    func onDragInit(offset:CGFloat = 0) {
        //if offset < 0 {return}
        self.isDragingCompleted = false
        self.dragInitOffset = offset
        self.viewModel.event = .dragInit
        self.viewModel.status = .drag
        self.isDragInit = true
        self.isDraging = true
    }
    
    func onDragingAction(offset: CGFloat, dragOpacity: Double) {
        if self.isDragingCompleted {return}
        if !self.isDraging {return}
        let diff = abs(self.bodyOffset - offset)
        //ComponentLog.d("onDragingAction offset " + offset.description , tag: self.tag)
        if abs(diff) > maxDiff { return }
        if abs(diff) < minDiff { return }
        let bodyOffset = max( 0, offset - self.dragInitOffset)
        //ComponentLog.d("onDragingAction " + bodyOffset.description , tag: self.tag)
        if self.isDragInit {
            self.isDragInit = false
            self.bodyOffset = ceil(bodyOffset)
            self.pagePresenter.dragOpercity = dragOpacity
            
        } else {
            self.bodyOffset = ceil(bodyOffset)
            self.pagePresenter.dragOpercity = dragOpacity
        }
        self.setDragAmount()
        self.viewModel.event = .drag(offset, dragOpacity)
        
       
    }

    func onDragEndAction(isBottom: Bool, offset: CGFloat) {
        self.viewModel.status = .none
        self.isDraging = false
        if !isBottom {
            self.bodyOffset = 0
            self.setDragAmount()
        }
        //self.viewModel.event = .draged(isBottom, offset)
        //ComponentLog.d("onDragEndAction self.bodyOffset " + self.bodyOffset.description , tag: "setDragAmount")
        if self.isDragingCompleted {return}
        if let dragingEndAction = self.dragingEndAction {
            self.isBottom = isBottom
            dragingEndAction(isBottom)
            return
        }
        if isBottom {
            self.isDragingCompleted = true
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
    }
    
    private func setDragAmount(){
        //PageLog.d("self.bodyOffset " + self.bodyOffset.description, tag: "setDragAmount")
        self.dragAmount = self.axis == .horizontal
            ? .init(width: self.bodyOffset, height: 0)
            : .init(width: 0, height: self.bodyOffset)
    }
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset(){
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = Timer.publish(
            every: 0.05, on: .current, in: .tracking)
            .autoconnect()
            .sink() {_ in
                self.reset()
            }
    }
    
    func reset() {
       self.autoResetSubscription?.cancel()
       self.autoResetSubscription = nil
       DispatchQueue.main.async {
            self.onDragInit()
            self.onDragCancel()
       }
    }
    
    
    
            
}








