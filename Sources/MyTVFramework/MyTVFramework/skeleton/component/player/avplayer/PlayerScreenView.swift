//
//  PlayerScreenView.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/04.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

protocol PlayerScreenViewDelegate{
    func onPlayerPersistKeyReady(contentId:String?,ckcData:Data?)
    func onPlayerAssetInfo(_ info:AssetPlayerInfo)
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerError(playerError:PlayerError)
    func onPlayerCompleted()
    func onPlayerBecomeActive()
    func onPlayerBitrateChanged(_ bitrate:Double)
    func onPlayerSubtltle(_ langs:[PlayerLangType])
    func onPipStatusChange(_ isStart:Bool)
    func onPipStatusChanged(_ isStart:Bool)
    func onPipClosed(isStop:Bool)
}

protocol PlayerScreenPlayerDelegate{
    func onPlayerReady()
    func onPlayerDestory()
}

class PlayerScreenView: UIView, PageProtocol, CustomAssetPlayerDelegate , AVPictureInPictureControllerDelegate, Identifiable{
    let id:String = UUID.init().uuidString
    var delegate:PlayerScreenViewDelegate? = nil
    var playerDelegate:PlayerScreenPlayerDelegate? = nil
    var drmData:FairPlayDrm? = nil
    var playerController : UIViewController? = nil
    var playerLayer:AVPlayerLayer? = nil
    var pipController:AVPictureInPictureController? = nil
   // private var observer: NSKeyValueObservation?
    private(set) var player:CustomAssetPlayer? = nil
    {
        didSet{
            if player != nil {
                if let pl = playerLayer {
                    layer.addSublayer(pl)
                }
            }
        }
    }

    private var currentTimeObservser:Any? = nil
    private var currentVolume:Float = 1.0
    var isAutoPlay:Bool = false
    private var initTime:Double = 0
    private var recoveryTime:Double = -1
 
    var usePip:Bool = false
    private var currentUsePip:Bool = false
    private var isPip:Bool = false
    private var isPipClose:Bool = true
    private var isAppPip:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        ComponentLog.d("init " + id, tag: self.tag)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        ComponentLog.d("deinit " + id, tag: self.tag)
        self.destoryScreenview()
    }
    
    func stop() {
        ComponentLog.d("on Stop", tag: self.tag)
        self.destoryPlayer()
    }
    
    func destory(){
        ComponentLog.d("destory " + id , tag: self.tag)
        self.destoryPlayer()
        self.destoryScreenview()
    }
    func destoryScreenview(){
        self.playerLayer = nil
        self.delegate = nil
        self.playerController = nil
        ComponentLog.d("destoryScreenview " + id, tag: self.tag)
    }
    private func destoryPlayer(){
        
        if self.isPip {
            self.isPip = false
            self.delegate?.onPipStatusChanged(false)
        }
        
        guard let player = self.player else {return}
        player.pause()
        player.replaceCurrentItem(with: nil)
        playerLayer?.removeFromSuperlayer()
        playerLayer?.player = nil
        if let avPlayerViewController = playerController as? AVPlayerViewController {
            avPlayerViewController.player = nil
            avPlayerViewController.delegate = nil
        }
        NotificationCenter.default.removeObserver(self)
        self.playerDelegate?.onPlayerDestory()
        self.player = nil
        ComponentLog.d("destoryPlayer " + id, tag: self.tag)
    }
    
    private func createdPlayer(){
      
        self.playerDelegate?.onPlayerReady()
        let center = NotificationCenter.default
        //center.addObserver(self, selector:#selector(newErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerDidBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width * currentRatio
        let h = bounds.height * currentRatio
        let x = (bounds.width - w) / 2
        let y = (bounds.height - h) / 2
        playerLayer?.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func createPlayer(_ url:URL, buffer:Double = 2.0, header:[String:String]? = nil, assetInfo:AssetPlayerInfo? = nil) -> AVPlayer?{
      
        var player:AVPlayer? = nil
        if self.drmData != nil {
            player = startPlayer(url, assetInfo:assetInfo)
        }else if let header = header {
            player = startPlayer(url, header: header)
        }else{
            player = startPlayer(url, assetInfo:assetInfo)
        }
        return player
    }
    
    private let loaderQueue = DispatchQueue(label: "resourceLoader")
    
    private func startPlayer(_ url:URL, header:[String:String]) -> AVPlayer?{
       
        let player = self.player ?? CustomAssetPlayer()
        var assetHeader = [String: Any]()
        assetHeader["AVURLAssetHTTPHeaderFieldsKey"] = header
        let key = "playable"
        let asset = AVURLAsset(url: url, options: assetHeader)
        asset.loadValuesAsynchronously(forKeys: [key]){
            DispatchQueue.global(qos: .background).async {
                let status = asset.statusOfValue(forKey: key, error: nil)
                switch (status)
                {
                case AVKeyValueStatus.failed, AVKeyValueStatus.cancelled, AVKeyValueStatus.unknown:
                    ComponentLog.d("certification fail " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        self.onError(.certification(status.rawValue.description))
                    }
                default:
                    //ComponentLog.d("certification success " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        let item = AVPlayerItem(asset: asset)
                        player.replaceCurrentItem(with: item )
                        self.startPlayer(player:player)
                    }
                    break;
                }
            }
        }
        return player
    }
    
    private func startPlayer(_ url:URL, assetInfo:AssetPlayerInfo? = nil)  -> AVPlayer?{
        ComponentLog.d("DrmData " +  (drmData?.contentId ?? "none drm") , tag: self.tag)
        let player = self.player ?? CustomAssetPlayer()
        if self.drmData == nil {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: item )
        } else {
            player.play(m3u8URL: url, playerDelegate: self, assetInfo:assetInfo, drm: self.drmData)
        }
        self.startPlayer(player:player)
        return player
    }
    

    static let VOLUME_NOTIFY_KEY = "AVSystemController_SystemVolumeDidChangeNotification"
    static let VOLUME_PARAM_KEY = "AVSystemController_AudioVolumeNotificationParameter"
    
    private func startPlayer(player:CustomAssetPlayer){
        if self.player == nil {
            self.player = player
            player.allowsExternalPlayback = false
        
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            player.preventsDisplaySleepDuringVideoPlayback = true
            player.appliesMediaSelectionCriteriaAutomatically = false
        
            player.volume = self.currentVolume
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            }
            catch {
                ComponentLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
            }
            
            if let avPlayerViewController = self.playerController as? AVPlayerViewController {
                avPlayerViewController.player = player
                avPlayerViewController.updatesNowPlayingInfoCenter = false
                avPlayerViewController.videoGravity = self.currentVideoGravity
            }else{
                self.playerLayer?.player = player
                self.playerLayer?.contentsScale = self.currentRatio
                self.playerLayer?.videoGravity = self.currentVideoGravity
            }
            
            ComponentLog.d("startPlayer currentVolume " + self.currentVolume.description , tag: self.tag)
            ComponentLog.d("startPlayer currentRate " + self.currentRate.description , tag: self.tag)
            ComponentLog.d("startPlayer videoGravity " + self.currentVideoGravity.rawValue , tag: self.tag)
            self.createdPlayer()
            self.setupPictureInPicture()
        }
       
    }
    func setupPictureInPicture() {
        guard let layer = self.playerLayer else {return}
        if !self.usePip {
            if self.isPip {
                self.onPipStop()
            }
            self.currentUsePip = false
            pipController?.delegate = nil
            pipController = nil
            return

        }
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            if !self.currentUsePip {
                pipController = AVPictureInPictureController(playerLayer: layer)
                if #available(iOS 14.2, *) {
                    pipController?.canStartPictureInPictureAutomaticallyFromInline = true
                } 
                pipController?.delegate = self
                self.currentUsePip = true
            }
        
        } else {
            self.currentUsePip = false
            pipController = nil
        }
    }

    private func onError(_ e:PlayerStreamError){
        delegate?.onPlayerError(e)
        ComponentLog.e("onError " + e.getDescription(), tag: self.tag)
        if self.isPip {
            self.pip(isStart: false)
        }
        switch e {
        case .playbackSection : break
        default : destoryScreenview()
        }
    }
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return}
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        ComponentLog.d("errorLog " + errorLog.description , tag: self.tag)
    }

    @objc func failedToPlayToEndTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let e = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        if let error = e as? NSError {
            let code = error.code
            if code == -1102 { // 재생구간 오류
                onError(.playbackSection(error.localizedDescription))
            } else {
                onError(.playback(error.localizedDescription))
            }
        }else{
            onError(.unknown("failedToPlayToEndTime"))
        }
        
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        delegate?.onPlayerCompleted()
    }
    @objc func playerDidBecomeActive(notification: NSNotification) {

        delegate?.onPlayerBecomeActive()
    }
   
    
    @objc func playerItemBitrateChange(notification: NSNotification) {
        DispatchQueue.global(qos: .background).async {
            guard let item = notification.object as? AVPlayerItem else {return}
            guard let bitrate = item.accessLog()?.events.last?.indicatedBitrate else {return}
            DispatchQueue.main.async {
                self.delegate?.onPlayerBitrateChanged(bitrate)
            }
        }
       
    }
    
    @discardableResult
    func load(_ path:String, isAutoPlay:Bool = false , initTime:Double = 0,buffer:Double = 2.0,
              header:[String:String]? = nil,
              assetInfo:AssetPlayerInfo? = nil,
              drmData:FairPlayDrm? = nil
              ) -> AVPlayer? {
        
        var assetURL:URL? = nil
        if path.hasPrefix("http") {
            assetURL = URL(string: path)
        } else {
            assetURL = URL(fileURLWithPath: path)
        }
        guard let url = assetURL else { return nil }
        
        self.initTime = initTime
        self.isAutoPlay = isAutoPlay
        self.drmData = drmData
        let player = createPlayer(url, buffer:buffer, header:header, assetInfo: assetInfo)
        return player
    }
    
    func playInit(duration:Double){
        if self.initTime > 0 && duration > 0 {
            seek(initTime)
        }
        guard let currentPlayer = player else { return }
        if self.currentRate != 1 {
            DispatchQueue.main.async {
                currentPlayer.rate = self.currentRate
            }
        }
        if self.isAutoPlay { self.resume() }
        else { self.pause() }
    
        guard let currentItem = currentPlayer.currentItem else { return }
        var langs:[PlayerLangType] = []
        currentItem.asset.allMediaSelections.forEach{ item in
            DataLog.d(item.debugDescription, tag: self.tag)
            if let find = PlayerLangType.allCases.first(where: { lang in
                let info = item.debugDescription
                let key = "language = " + lang.rawValue
                let sbtKey = "sbtl"
                return info.contains(key) && info.contains(sbtKey)
            }) {
                langs.append(find)
            }
        }
        self.delegate?.onPlayerSubtltle(langs)
    }
    
    @discardableResult
    func resume() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.play()
        return true
    }
    
    
    
    @discardableResult
    func pause() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.pause()
        return true
    }
    
    @discardableResult
    func seek(_ t:Double) -> Bool {
        
        guard let currentPlayer = player else { return false }
        let cmt = CMTime(
            value: CMTimeValue(t * PlayerModel.TIME_SCALE),
            timescale: CMTimeScale(PlayerModel.TIME_SCALE))
        currentPlayer.seek(to: cmt)
        return true
    }
    
    @discardableResult
    func mute(_ isMute:Bool) -> Bool {
        currentVolume = isMute ? 0.0 : 1.0
        guard let currentPlayer = player else { return false }
        currentPlayer.volume = currentVolume
        
        return true
    }
    
    func setArtwork(_ imageData:UIImage){
        guard let item = self.player?.currentItem else {return}
        guard let data = imageData.jpegData(compressionQuality: 1) as? NSData else {return}
        let artwork = AVMutableMetadataItem()
        artwork.identifier = .commonIdentifierArtwork
        artwork.value = data
        artwork.dataType = kCMMetadataBaseDataType_JPEG as String
        artwork.extendedLanguageTag = "und"
        item.externalMetadata = [artwork]
        
       
    }
    
    @discardableResult
    func pip(isStart:Bool) -> Bool {
        guard let pip = self.pipController else { return false }
        self.isAppPip = true
        DispatchQueue.main.async {
            isStart ? pip.startPictureInPicture() : pip.stopPictureInPicture()
        }
        return true
    }
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if !self.isAppPip {
            self.delegate?.onPipStatusChange(true)
        }
        self.isPip = true
        self.isPipClose = true
        self.isAppPip = false
        self.delegate?.onPipStatusChanged(true)
    
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
        self.onPipStop()
    }
    private func onPipStop(){
        if !self.isAppPip {
            self.delegate?.onPipStatusChange(false)
        }
        self.isPip = false
        self.isAppPip = false
        self.delegate?.onPipStatusChanged(false)
        self.delegate?.onPipClosed(isStop: self.isPipClose)
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        
        ComponentLog.d("failedToStartPictureInPictureWithError " + error.localizedDescription ,tag: "pipController")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.isPipClose = false
        ComponentLog.d("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler" ,tag: "pipController")
    }

   
    
    func captionChange(lang:String?, size:CGFloat?, color:Color?){
        guard let currentPlayer = player else { return }
        guard let currentItem = currentPlayer.currentItem else { return }
    
        if let group = currentItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let locale = Locale(identifier: lang ?? "")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if lang?.isEmpty == false {
                if let option = options.first {
                    currentItem.select(option, in: group)
                }
            }else {
                currentItem.select(nil, in: group)
            }
        }
        let size = (size ?? 100)
        // let component = color.components()
        guard let rule = AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_RelativeFontSize as String : size
        ]) else { return }
        /*
        guard let rule = AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_RelativeFontSize as String : size,
            kCMTextMarkupAttribute_ForegroundColorARGB as String : [component.a ,component.r,component.g,component.b]
        ]) else { return }
         */
        currentItem.textStyleRules = [rule]
    }
    
    // asset delegate
    func onFindAllInfo(_ info: AssetPlayerInfo) {
        self.delegate?.onPlayerAssetInfo(info)
    }
    
    func onAssetLoadError(_ error: PlayerError) {
        self.delegate?.onPlayerError(playerError: error)
    }
    
    func onAssetEvent(_ evt :AssetLoadEvent) {
        switch evt {
        case .keyReady(let contentId, let ckcData):
            self.delegate?.onPlayerPersistKeyReady(contentId:contentId, ckcData: ckcData)
            if self.isAutoPlay { self.resume() }
            else { self.pause() }
        }
    }
    
    var currentPlayTime:Double? {
        get{
            self.player?.currentItem?.currentTime().seconds
        }
    }
    
    
    var currentRatio:CGFloat = 1.0
    {
        didSet{
            ComponentLog.d("onCurrentRatio " + currentRatio.description, tag: self.tag)
            if let layer = playerLayer {
                layer.contentsScale = currentRatio
                self.setNeedsLayout()
            }
        }
    }
    
    var currentVideoGravity:AVLayerVideoGravity = .resizeAspectFill
    {
        didSet{
             playerLayer?.videoGravity = currentVideoGravity
             if let avPlayerViewController = playerController as? AVPlayerViewController {
                 avPlayerViewController.videoGravity = currentVideoGravity
             }
        }
    }
    
    var currentRate:Float = 1.0
    {
        didSet{
            player?.rate = currentRate
        }
    }
    
}


