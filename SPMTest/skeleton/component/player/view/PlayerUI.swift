//
//  PlayerUI.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import MediaPlayer
import AVKit
extension PlayerUI {
    static let padding = Dimen.margin.regularExtra
    static let uiHeight:CGFloat = 48
    static let uiRealHeight:CGFloat = 34
    static let timeTextWidth:CGFloat  = 48
    static let spacing:CGFloat = Dimen.margin.thinExtra
}
struct PlayerUI: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    var bottomMargin:CGFloat = Dimen.margin.regularExtra
    @State var time:String = "00:00:00"
    @State var completeTime:String = "00:00:00"
    @State var duration:String = "00:00:00"
    @State var progress: Float = 0
    @State var isPlaying = false
    @State var isLoading = false
    @State var isSeeking = false
    @State var isSeekAble = false
    @State var isError = false
    @State var errorMessage = ""
    @State var isShowing: Bool = false
    var body: some View {
        ZStack{
            HStack(spacing:0){
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 2, perform: {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                    })
                    .onTapGesture(count: 1, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
                    .accessibilityElement()
                    .accessibility(label: Text(String.player.tabBack))
                    .accessibilityAction {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                    }
                    
                    
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 2, perform: {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                    })
                    .onTapGesture(count: 1, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
                    .accessibilityElement()
                    .accessibility(label: Text(String.player.tabForword))
                    .accessibilityAction {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                    }
            }
            .padding(.vertical, Dimen.tab.regular)
            .background(Color.transparent.black50)
            .opacity(self.isShowing  ? 1 : 0)
            .accessibility(hidden: !self.isShowing)
            if self.isLoading {
                CircularSpinner(resorce: Asset.ani.loading)
            }
            
            VStack{
                Spacer()
                HStack(alignment:.center, spacing:Self.spacing){
                    Text(self.time)
                        .kerning(Font.kern.thin)
                        .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .lineLimit(1)
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibility(label:Text(String.player.playTime + self.time))
                    
                    ProgressSlider(
                        pageObservable: self.pageObservable,
                        progress: self.progress,
                        thumbSize: Dimen.icon.tinyExtra,
                        onChange: { pct in
                            let willTime = self.viewModel.duration * Double(pct)
                            self.viewModel.event = .seeking(willTime, isUser: true)
                        },
                        onChanged:{ pct in
                            self.viewModel.event = .seekProgress(pct, isUser: true)
                            self.viewModel.seeking = 0
                        
                        })
                        .frame(height: Self.uiHeight)
                            .accessibilityElement()
                            .accessibility(label:Text(String.player.playTime + self.time))
                         
                    Text(self.completeTime)
                        .kerning(Font.kern.thin)
                        .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .lineLimit(1)
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibility(label:Text(String.player.endTime + self.completeTime))
                    
                }
                .padding(.horizontal, Self.padding)
                .padding(.bottom, self.bottomMargin)
                .opacity(self.isSeekAble ? 1 : 0)
            }
            .opacity(self.isShowing && !self.viewModel.isLock ? 1 : 0)
            .accessibility(hidden: !self.isShowing)
            if !self.isSeeking {
                HStack(spacing:100){
                    ImageButton(
                        defaultImage: Asset.player.seekBackward,
                        size: CGSize(width:Dimen.icon.medium,height:Dimen.icon.medium)
                    
                    ){ _ in
                        self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                    }
                    .accessibility(label: Text(String.player.back))
                    .opacity(self.isSeekAble ? 1 : 0)
                    .rotationEffect(.degrees(self.isControlAble ? 0 : 90))
                    VStack(spacing:Dimen.margin.regular){
                        ImageButton(
                            defaultImage: Asset.player.resume,
                            activeImage: Asset.player.pause,
                            isSelected: self.isPlaying,
                            size: CGSize(width:Dimen.icon.heavy,height:Dimen.icon.heavy)
                        
                        ){ _ in
                            self.viewModel.isUserPlay = self.isPlaying ? false  : true
                            if !self.isSeekAble && !self.isPlaying && !self.viewModel.isLiveStream {
                                self.viewModel.event = .resumeDisable(isUser: true)
                                return
                            }
                            self.viewModel.event = .togglePlay(isUser: true)
                        }
                        .accessibility(label: Text(
                            self.isPlaying ? String.player.pause :  String.player.resume))
                        .opacity(self.isLoading ? 0 : 1)
                        if !self.isPlaying, let info = self.viewModel.playInfo{
                           Text(info)
                               .modifier(BoldTextStyle(
                                           size:  Font.size.light,
                                           color: Color.app.white))
                        }
                    }
                    .accessibility(hidden: !self.isControlAble)
                    
                    ImageButton(
                        defaultImage: Asset.player.seekForward,
                        size: CGSize(width:Dimen.icon.medium,height:Dimen.icon.medium)
                    
                    ){ _ in
                        self.viewModel.event = .seekForward(self.viewModel.getSeekBackwordAmount(), isUser: true)
                    }
                    .accessibility(label: Text(String.player.forword))
                    .opacity(self.isSeekAble ? 1 : 0)
                    .rotationEffect(.degrees(self.isControlAble ? 0 : -90))
                }
                .opacity( self.isControlAble ? 1 : 0 )
            }
        }
        .toast(isShowing: self.$isError, text: self.errorMessage) 
        .onReceive(self.viewModel.$time) { tm in
            if self.viewModel.duration <= 0 {return}
            if tm < 0 {return}
            self.time = tm.secToHourString()
            self.completeTime = max(0,self.viewModel.duration - tm).secToHourString()
            if !self.isSeeking {
                self.progress = Float(tm / max(self.viewModel.duration,1))
            }
        }
        .onReceive(self.viewModel.$duration) { tm in
            self.duration = tm.secToHourString()
        }
        .onReceive(self.viewModel.$isSeekAble) { able in
            guard let able = able else {return}
            self.isSeekAble = able
        }
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
        }
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.isShowing = true
                default :
                    self.isShowing = false
                    if self.viewModel.streamStatus == .buffering(0) { withAnimation{self.isLoading = true} }
                }
            }
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            
            case .seeking(let willTime, _):
                self.progress = Float(willTime / max(self.viewModel.duration,1))
                if !self.isSeeking {
                    withAnimation{ self.isSeeking = true }
                }
            default : break
            }
        }
        
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked:
                withAnimation{self.isSeeking = false}
            default : break
            }
        }
        /*
        .onReceive(self.viewModel.$usePip) { use in
            self.supportedPip = use ? AVPictureInPictureController.isPictureInPictureSupported() : false
        }
        .onReceive(self.viewModel.$playerPipStatus) { stat in
            switch stat {
            case .on : self.isPip = true
            case .off : self.isPip = false
            }
        }
         */
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) : withAnimation{ self.isLoading = true }
            default : withAnimation{ self.isLoading = false }
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let error = err else { return }
            ComponentLog.d("error " + err.debugDescription, tag: self.tag)
           
            self.viewModel.playerUiStatus = .view
            switch error{
            case .connect(_) : self.errorMessage = "connect error"

            case .illegalState(_) :
                self.errorMessage = "illegalState"
                return
            case .drm(_) : self.errorMessage = "drm"
                return
            case .asset(_) : self.errorMessage = "asset"
                return
            case .stream(let e) :
                switch e {
                case .pip(let msg): self.errorMessage = msg
                case .playback(let msg): self.errorMessage = msg
                case .playbackSection : return
                case .unknown(let msg): self.errorMessage = msg
                case .certification(let msg): self.errorMessage = msg
                }
            }
            self.isError = true
        }
        
    }
    
    private var isControlAble:Bool {
        get{
            return self.isShowing && !self.isLoading  && !self.viewModel.isLock
        }
    }

}

