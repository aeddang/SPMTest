import Foundation
import SwiftUI
import Combine
import MediaPlayer
let testPath = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
let testPath2 = "http://techslides.com/demos/sample-videos/small.mp4"

struct CPPlayer: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    @EnvironmentObject var imageLoader:AsyncImageLoader
    @ObservedObject var viewModel:PlayerModel = PlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var bottomMargin:CGFloat = Dimen.margin.regularExtra

    var body: some View {
        ZStack(alignment: .center){
            CustomAVPlayerController(
                viewModel : self.viewModel,
                pageObservable : self.pageObservable)
            
            if !self.viewModel.useAvPlayerController{
                HStack(spacing:0){
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                        })
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.uiViewChange()
                        })
                        
                        
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                        })
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.uiViewChange()
                        })
                }
                .accessibilityElement()
                .accessibility(label: Text("Player"))
                .accessibilityAction{
                    self.uiViewChange()
                }
                PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable, bottomMargin:self.bottomMargin)
            }
            
        }
        .clipped()
        .onReceive(self.viewModel.$isPlay) { _ in
            self.autoUiHidden?.cancel()
        }
        .onReceive(self.viewModel.$duration) { d in
            /*
            if d == 0 && self.viewModel.path.isEmpty == false{
                if self.waitDurationSubscription == nil {
                    self.creatWaitDuration()
                }
                return
            } else {
                self.clearWaitDuration()
            }
            */
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            //case .load : self.clearWaitDuration()
            //case .stop, .pause :  self.clearWaitDuration()
            case .seeking(let willTime, _):
                let diff =  willTime - self.viewModel.time
                self.viewModel.seeking = diff
                self.autoUiHidden?.cancel()
            case .fixUiStatus(let isFix):
                if isFix {
                    self.autoUiHidden?.cancel()
                } else {
                    self.delayAutoUiHidden()
                }
            default : break
            }
        }
        .onReceive(self.viewModel.$time) { t in
            if (Int(round(t)) % 20) == 0 {
                if UIScreen.screens.count > 1 { return }
                if UIScreen.main.isCaptured {
                    self.viewModel.event = .pause(isUser: false)
                    /*
                    self.appSceneObserver.alert = .alert(
                        String.player.recordDisable, String.player.recordDisableText)
                     */
                }
            }
        }
        .onReceive(self.viewModel.$status) { stat in
            if #available(iOS 14.0, *) { return }
            // self.bindUpdate.toggle()
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .completed :
                if self.viewModel.isReplay {
                    self.viewModel.event = .seekTime(0, true, isUser: false)
                }
            case .loaded :
                self.viewModel.playerUiStatus = .view
                self.delayAutoUiHidden()
            case .seeked:
                //self.viewModel.playerUiStatus = .view
                self.delayAutoUiHidden()
                self.viewModel.seeking = 0
            case .resumed:
                self.delayAutoUiHidden()
            default : break
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let err = err else { return }
            var msg = ""
            var code = ""
            switch err {
            case .connect(let s):
                msg = s
                code = "#connect error"
            case .stream(let err):
                switch err {
                case .playbackSection : return
                default : break
                }
                msg = err.getDescription()
                code = "#stream error"
                
            case .illegalState(_):
                return
            case .drm(let err):
                msg = err.getDescription()
                code = "#drm error"
            case .asset(let err):
                msg = err.getDescription()
                code = "#asset error"
            }
            ComponentLog.e(code + " : " + msg, tag:self.tag)
            if self.viewModel.recoveryCount > 1 || !self.viewModel.useRecovery{
                /*
                self.appSceneObserver.alert = .confirm(
                    String.alert.playError, String.alert.playErrorPlayback, code,
                    confirmText: String.button.btnRetry){retry in
                    if retry {
                        if self.viewModel.useRecovery {
                            self.viewModel.event = .resume()
                        } else {
                            self.viewModel.event = .recovery(isUser: true)
                        }
                    }
                }*/
            }
        }
        .onReceive(self.viewModel.$artImage) { imgPath in
            guard let img = imgPath else {return}
            ComponentLog.d("img " + img, tag:"artImage")
            self.imageLoader.load(url: img)
        }
        .onReceive(self.imageLoader.$event) { evt in
            guard let  evt = evt else { return }
            switch evt {
            case .complete(let img) :
                ComponentLog.d("img completed", tag:"artImage")
                self.updateArtwork(imageData: img)
            default : break
            }
        }
        .background(Color.black)
        .onAppear(){
            self.setRemoteAction()
        }
        .onDisappear(){
            self.viewModel.event = .pause()
            self.clearAutoUiHidden()
            
        }
        
    }
    
    func setRemoteAction(){
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.event = .togglePlay(isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.event = .seekMove(-15, nil, isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.skipForwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.event = .seekMove(15, nil, isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
    func updateArtwork(imageData:UIImage) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {return}
        ComponentLog.d("updateArtwork", tag:"artImage")
        let artwork = MPMediaItemArtwork(boundsSize:.init(width: 240, height: 240)) { sz in
            return imageData
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func uiViewChange(){
        if self.viewModel.playerUiStatus == .hidden {
            self.viewModel.playerUiStatus = .view
            //ComponentLog.d("self.viewModel.playerStatus " + self.viewModel.playerStatus.debugDescription , tag: self.tag)
            if self.viewModel.playerStatus == PlayerStatus.resume {
                self.delayAutoUiHidden()
            }
        }else {
            self.viewModel.playerUiStatus = .hidden
            self.autoUiHidden?.cancel()
        }
    }

    @State var autoUiHidden:AnyCancellable?
    func delayAutoUiHidden(){
        self.autoUiHidden?.cancel()
        if UIAccessibility.isVoiceOverRunning {return}
        self.autoUiHidden = Timer.publish(
            every:  2.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.viewModel.playerUiStatus = .hidden
                self.clearAutoUiHidden()
            }
    }
    func clearAutoUiHidden() {
        self.autoUiHidden?.cancel()
        self.autoUiHidden = nil
    }
}


#if DEBUG
struct ComponentPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPPlayer(viewModel:PlayerModel()).contentBody
                .environmentObject(PagePresenter())
                .environmentObject(AsyncImageLoader())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
