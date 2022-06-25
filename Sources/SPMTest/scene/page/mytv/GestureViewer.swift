//
//  GestureViewer.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/08.
//

import Foundation
import SwiftUI
import Combine
import Network
import struct Kingfisher.KFImage
extension GestureViewer {
    enum DragType{
        case none, horizontal, vertical, move
    }
    enum Status{
        case ready, play, transition , complete, error
    }
    enum Error{
        case channel , program , play, playBack, simulator
        var errorMsg: String {
            switch self {
            case .channel: return "편성 된 채널이 없습니다"
            case .program: return "편성 된 프로그램이 없습니다"
            case .play: return "재생가능한 콘텐츠가 없습니다"
            case .playBack: return "재생중 에러발생"
            case .simulator: return "시뮬레이터 에서는 재생 테스트를 할 수 없습니다 "
            }
        }
    }
    static let moveTime:Double = 0.3
}

struct GestureViewer:View, PageProtocol {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var tvPlayerModel: TVPlayerModel = TVPlayerModel()
    @ObservedObject var myTvModel:MyTvModel = MyTvModel()
    @ObservedObject var myChannelModel:MyChannelModel = MyChannelModel()
    

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack(alignment: .top){
                    TVPlayer(
                        pageObservable:self.pageObservable,
                        viewModel:self.tvPlayerModel)
                    TopFunctionBox(
                        myTvModel: self.myTvModel,
                        myChannelModel: self.myChannelModel,
                        tvPlayerModel: self.tvPlayerModel)
                }
                .opacity(self.playerOpacity)
                ZStack{
                    KFImage(URL(string: self.programImage?.image ?? ""))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg16_9)
                                .resizable()
                        }
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fit)
                        .modifier(MatchParent())
                        
                    ProgramInfoBox(program: self.program, title: self.title, isAuto: self.isAuto)
                    ImageButton(
                        defaultImage: Asset.player.resume,
                        size: CGSize(width:Dimen.icon.heavy,height:Dimen.icon.heavy)
                    
                    ){ _ in
                        self.tvPlayerModel.isUserPlay = true
                        self.tvPlayerModel.event = .resume(isUser: true)
                    }
                    .accessibility(label: Text(String.player.resume))
                }
                .background(Color.app.darkBlue100)
                .offset(self.dragAmount)
                .opacity((1-self.playerOpacity) * self.dragRatio)
                .scaleEffect(self.dragRatio)
                ZStack{
                    Viewer(myTvModel: self.myTvModel, myChannelModel:self.myChannelModel, type: .top)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y:-geometry.size.height)
                    Viewer(myTvModel: self.myTvModel, myChannelModel:self.myChannelModel, type: .bottom)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y:geometry.size.height)
                    Viewer(myTvModel: self.myTvModel, myChannelModel:self.myChannelModel, type: .left)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x:-geometry.size.width)
                    Viewer(myTvModel: self.myTvModel, myChannelModel:self.myChannelModel, type: .right)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x:geometry.size.width)
                }
                .offset(self.dragAmount)
                
            }
            .background(Color.brand.bg)
            .gesture(
                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .global)
                    .onChanged({ value in self.drag(geo: geometry, value: value)})
                    .onEnded({ value in self.dragCompleted(geo: geometry, value: value)})
            )
            .gesture(
                cancelGesture
                    .onChanged({_ in self.dragCancel(geo: geometry)})
                    .onEnded({_ in self.dragCancel(geo: geometry)})
            )
            .onReceive(self.dataProvider.bands.$event){ evt in
                switch evt {
                case .updatedBand : self.requestBandChannel()
                case .updatedChannels : self.setupBandChannel()
                default : break
                }
            }
            .onReceive(self.dataProvider.$result){ res in
                self.onApiResultResponds(res)
            }
            .onReceive(self.dataProvider.$error){ err in
                self.onApiResultError(err)
            }
            .onReceive(self.myTvModel.$event){evt in
                switch evt {
                case .channelChanged : self.channelUpdate()
                case .channelUpdated(let channel) : self.channelUpdated(channel)
                case .channelUpdateError(let channel) : self.channelUpdateError(channel)
                default : break
                }
            }
            .onReceive(self.myChannelModel.$event){evt in
                switch evt {
                case .programChanged : self.programUpdate()
                case .programUpdated(let program) : self.programUpdated(program)
                default : break
                }
            }
            .onReceive(self.tvPlayerModel.$error){ error in
                guard let err = error else {return}
                switch error {
                case .illegalState : return
                default :
                    self.onPlayerError(err)
                    self.stop(error: .playBack)
                }
            }
            .onReceive(self.tvPlayerModel.$streamEvent){ evt in
                self.onPlayerEvent(evt)
            }
            .onReceive(self.tvPlayerModel.$event){ evt in
                self.onPlayerEvent(evt)
            }
            .onReceive(self.appSceneObserver.$launcherRequest){ request in
                self.onLauncherRequest(request)
            }
            .onAppear{
                
            }
            .onDisappear{
                self.gestureMoveCancel()
            }
        }
    }
    // global
    @State private(set) var status:Status = .ready {
        didSet{
            self.playerOpacity = status == .play ? 1 : 0
        }
    }
    @State private var error:Error? = nil
    @State private var playerOpacity:Double = 0
    @State var isOfflinePlay:Bool = false
    @State var isAuto:Bool = false
    func stop(error:Error){
        self.error = error
        self.currentPlayId = nil
        self.changeStatus(.error)
        self.tvPlayerModel.event = .pause(isUser: false)
        self.appSceneObserver.alert = .alert(
            "MY TV 알림",
            error.errorMsg
        )
    }
    
    func changeStatus(_ newStatus:Status){
        if self.status == .transition {
            self.finalStatus = newStatus
            return
        }
        self.status = newStatus
    }
    
    //extention
    @State var requestBandKey:[String] = []
    @State var isReady:Bool = false
    @State var initChannel:String? = nil
    @State var currentChannelId:String = ""
    @State var currentProgramId:String = ""
    @State var program:Program? = nil
    @State var title:String = ""
    @State var programImage:ImageSet? = nil
    @State var playStartTime:Double = 0
    @State var currentPlayId:String? = nil

    //gesture
    private let ratioValue:CGFloat = 5.0
    @State private var dragAmount = CGSize.zero
    @State private var dragRatioAmount = CGSize.zero
    @State private var dragRatio:Double = 1
    @State private var dragType:DragType = .none
    @State private var finalStatus:Status = .ready
   
    let cancelGesture = LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
          .simultaneously(with: RotationGesture(minimumAngleDelta:.zero))
          .simultaneously(with: MagnificationGesture(minimumScaleDelta: 0))
    
    private func drag(geo:GeometryProxy, value:DragGesture.Value){
        if self.dragType == .move { return }
        if self.dragType == .none {
            self.dragInit(value: value)
        }
        switch self.dragType {
        case .vertical :
            self.dragAmount = CGSize(width: 0,height: value.translation.height)
            self.dragRatio = (geo.size.height-abs(value.translation.height))/geo.size.height
        case .horizontal :
            self.dragAmount = CGSize(width: value.translation.width,height: 0)
            self.dragRatio = (geo.size.width-abs(value.translation.width))/geo.size.width
        default : break
        }
        
        self.dragRatioAmount = CGSize(width: self.dragAmount.width/ratioValue,
                                      height: self.dragAmount.height/ratioValue)
        
    }
    
    private func dragInit(value:DragGesture.Value){
        if abs(value.translation.width) > abs(value.translation.height) {
            self.dragType = .horizontal
        } else {
            self.dragType = .vertical
        }
        self.finalStatus = self.status
        self.status = .transition
    }
    
    private func dragCompleted(geo:GeometryProxy, value:DragGesture.Value){
        switch self.dragType {
        case .vertical :
            let diff = value.predictedEndTranslation.height
            let min = geo.size.height/2
            if abs(diff) > min {
                let vector =  diff > 0 ? 1 : -1
                if self.myTvModel.moveableChannel(
                    Viewer.Direction.getDirection(vector: vector, axes: .vertical).toVector())
                {
                    self.changeVertical(geo:geo, vector:vector)
                } else {
                    self.dragCancel(geo: geo)
                }
            } else {
                self.dragCancel(geo: geo)
            }
            
        case .horizontal :
            let diff = value.predictedEndTranslation.width
            let min = geo.size.width/2
            if abs(diff) > min {
                let vector =  diff > 0 ? 1 : -1
                if self.myChannelModel.moveableProgram(
                    Viewer.Direction.getDirection(vector: vector, axes: .horizontal).toVector())
                {
                    self.changeHorizontal(geo:geo, vector: vector)
                } else {
                    self.dragCancel(geo: geo)
                }
            } else {
                self.dragCancel(geo: geo)
            }
        default : break
        }
    }
    private func dragCancel(geo:GeometryProxy){
        withAnimation(.easeOut(duration: Self.moveTime)){
            self.dragAmount = CGSize.zero
            self.dragRatioAmount = CGSize.zero
            self.dragRatio = 1
        }
        self.gestureMoveReset()
    }
    private func changeVertical(geo:GeometryProxy, vector:Int){
        withAnimation(.easeIn(duration: Self.moveTime)){
            self.dragAmount = CGSize(width: 0, height: vector * Int(geo.size.height))
            self.dragRatioAmount = CGSize(width: 0,height: self.dragAmount.height/ratioValue)
            self.dragRatio = 0
        }
        self.gestureMoveStart(directon: Viewer.Direction.getDirection(vector: vector, axes: .vertical))
    }
    private func changeHorizontal(geo:GeometryProxy, vector:Int){
        withAnimation(.easeIn(duration: Self.moveTime)){
            self.dragAmount = CGSize(width: vector * Int(geo.size.width), height:0)
            self.dragRatioAmount = CGSize(width: self.dragAmount.width/ratioValue, height: 0)
            self.dragRatio = 0
        }
        self.gestureMoveStart(directon: Viewer.Direction.getDirection(vector: vector, axes: .horizontal))
    }
    
    @State private var gestureMoveCompleted:AnyCancellable?
    private func gestureMoveStart(directon:Viewer.Direction){
        self.tvPlayerModel.event = .stop(isUser: true)
        self.dragType = .move
        self.gestureMoveCancel()
        self.gestureMoveCompleted = Timer.publish(
            every: Self.moveTime+0.05, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                switch directon {
                case .right, .left : self.myChannelModel.moveProgram(directon.toVector())
                case .top, .bottom : self.myTvModel.moveChannel(directon.toVector())
                }
                self.gestureMoveCancel()
                self.dragType = .none
                self.dragAmount = CGSize.zero
                self.dragRatioAmount = CGSize.zero
                self.dragRatio = 1
                self.status = .ready
            }
    }
    
    private func gestureMoveReset(){
        self.gestureMoveCancel()
        self.gestureMoveCompleted = Timer.publish(
            every: Self.moveTime, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.dragType = .none
                self.gestureMoveCancel()
                self.status = self.finalStatus
            }
    }
    
    private func gestureMoveCancel(){
        self.gestureMoveCompleted?.cancel()
        self.gestureMoveCompleted = nil
    }
}
