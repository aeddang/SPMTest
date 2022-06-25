//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import AVKit

struct TVPlayer: PageComponent{
    static var screenGravity:AVLayerVideoGravity? = nil
    static var playRate:Float? = nil
    static var isMute:Bool = false
    static var selectedQuality:String? = nil
    
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                CPPlayer(
                    viewModel : self.viewModel,
                    pageObservable : self.pageObservable,
                    bottomMargin: Dimen.icon.regular + Dimen.margin.light
                )
                HStack(spacing:0){
                    BrightnessBar()
                    Spacer().modifier(MatchHorizontal(height: 0))
                    VolumeBar(viewModel: self.viewModel)
                }
                .padding(.horizontal, self.isUiShowing ? Dimen.margin.medium : 0)
                .opacity(self.isUiShowing && !self.viewModel.isLock ? 1.0 : 0)
                VStack(spacing:0){
                    Spacer().modifier(MatchVertical(width: 0))
                    BottomFunctionBox(viewModel: self.viewModel)
                }
                .padding(.bottom, self.isUiShowing ? Dimen.margin.medium : Dimen.margin.thin)
                .opacity(self.isUiShowing ? 1.0 : 0)
                
                VStack(spacing:0){
                    Spacer().modifier(MatchVertical(width: 0))
                    ZStack{
                        OptionSelectBox(viewModel: self.viewModel)
                        CaptionSelectBox(viewModel: self.viewModel)
                    }
                }
            }
            .modifier(MatchParent())
            .background(Color.app.black)
            
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .mute(let isMute, _) : Self.isMute = isMute
                case .volume : Self.isMute = false
                default : break
                }
            }
            .onReceive(self.viewModel.$selectQuality){ quality in
                guard let quality = quality else {return}
                Self.selectedQuality = quality.name
                self.viewModel.selectedQuality = quality.name
                self.viewModel.continuousTime = self.viewModel.time
                self.viewModel.currentQuality = quality
                
            }
            .onReceive(self.viewModel.$duration){ d in
                ComponentLog.d("duration " + d.description, tag: self.tag)
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                if quality == nil { return }
                DispatchQueue.main.async {
                    self.initPlay()
                }
            }
            .onReceive(self.viewModel.$playerUiStatus) { st in
                withAnimation{
                    switch st {
                    case .view : break
                    default : break
                    }
                }
            }
            .onReceive(self.viewModel.$playerPipStatus) { st in
                withAnimation{
                    switch st {
                    case .on :
                        self.isPip = true
                    default : self.isPip = false
                    }
                }
            }
            .onReceive(self.viewModel.$rate) { rate in
                if !self.isInit {return}
                Self.playRate = rate
            }
            .onReceive(self.viewModel.$screenGravity) { gravity in
                if !self.isInit {return}
                Self.screenGravity = gravity
            }
            .onAppear(){
                self.viewModel.usePip = true
                if let gravity = Self.screenGravity {
                    self.viewModel.screenGravity = gravity
                }
                if let playRate = Self.playRate {
                    self.viewModel.rate = playRate
                }
                if Self.isMute {
                    self.viewModel.isMute = true
                }
                if let selectedQuality = Self.selectedQuality {
                    self.viewModel.selectedQuality = selectedQuality
                }
                self.viewModel.volume = AVAudioSession.sharedInstance().outputVolume
            }
            .onReceive(self.viewModel.$playerUiStatus) { st in
                withAnimation{
                    switch st {
                    case .view :
                        self.isUiShowing = true
                    default : self.isUiShowing = false
                    }
                }
            }
            .onDisappear(){
                self.viewModel.event = .stop()
            }
        }//geo
    }//body
    @State var isInit:Bool = false
    @State var isPip:Bool = false
    @State var isUiShowing:Bool = false
    func initPlay(){
        self.isInit = true
        ComponentLog.d("initPlay", tag: self.tag)
        guard let quality = self.viewModel.currentQuality else {
            self.viewModel.event = .stop()
            return
        }
        let t = self.viewModel.continuousTime
        self.viewModel.continuousTime = 0
        ComponentLog.d("continuousTime " + t.description, tag: self.tag)
        if quality.drmLicense?.isEmpty == false, let drm = quality.drmLicense {
            ComponentLog.d("fairplay DRM", tag: self.tag)
            self.viewModel.drm = FairPlayDrm(ckcURL: drm, certificateURL: drm)
        }
        self.viewModel.event = .load(quality.path, self.viewModel.autoPlay , t, self.viewModel.header)
    }
}


#if DEBUG
struct BtvPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TVPlayer()
                .environmentObject(Repository())
                .environmentObject(PageSceneObserver())
                .environmentObject(PagePresenter())
                .modifier(MatchParent())
        }
    }
}
#endif

