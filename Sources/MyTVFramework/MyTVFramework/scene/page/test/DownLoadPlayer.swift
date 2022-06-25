//
//  GestureViewer.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/08.
//

import Foundation
import SwiftUI
import Combine

extension DownLoadPlayer {
    
    static let videoPath:String = "https://devmobilemig.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQ0Xdu90PjKSYUMw5tVAOB%2BjSPHYA6ToNsch7tj8u12AdYWJtjUKCCxuHgCpxVccjMGnx2zfUpquJ%2FgJ0j1biNAvT3zLshRc5rgHe1LQWKTOD5ehF6d2vk%2FKWxcWl%2BKHFm429%2BQPJtZH3QMxN8t6bcgiblKiqF7rrzzN5SmqRapSAMsz5sU10PKFzIPjH7jIJfMEUCYd%2FPhXkrVnJH3IYWWFtGgZ8LQtHHgZ6octQf%2F8xD8j4unUq8rG%2F6lkurcT35u0sm8D5%2BFL7vpl1cPzeZ3WJDNEEsgQQ7rk%2Ba9WW12flJXcnk2MaKrLISH8ECgs7d27ZdpTapEo67mje5bd52e%2B%2FAA5veDVoTC9S2yJi74%2Fl5DPdvx4%2B9oZUmJVle7tm4qjjnkxcuODguAIcFUVKFZmO%2BHrOaruZUaW%2BD3l4ucionyeehLoJt8lPOltNZzdtQTDW7Pl5Pg8EJDobexVnku691XEUbGITfJAI%2BXjwbuIGUc%2BY5PvitXzyCyJBi%2BgodPViJumGXIZEtaD9qtAj5cWNPw3k3enpawmspC2SzW%2BbPRN2IcIzwbRrgJbHmLuEXFMqkq6tr5%2F0dqe3vBATu0UpLFVQq%2Bg50rV2AUfVIq2IqgLp1GC4Z9ouvqKpkRUp9hsTi65hlTwxIE0v29eX%2BNvyk8LaEvj1qiGP1DsIz55t73HoqBJ4FC6eXjaX5h3t9%2BbYTQGn4spLSa4aqkRWf8NtQ%2BYH770z1p5fxopJ9jCPTCETgaXpQr7J5KK3pZSF3kyrDmtLExXkGr7L3CZu8J80sOnhEmLO2QYZYlX%2BcyfnYYlen5Zu4DH6js%2B9PP%2B9UW4uQlS2qvYfCDYB8pvSLBWOuBcViyp6ESn2hufKvySiIZsv7vBLnEnduyu4PgVAqhizZ8JfAOyiXpXceyrZWlacylOsyqVMB6Qhi6shxygEhfU981RbUR/CD1010003913_20210706210703.m3u8"
    static let licensePath:String = "https://ecdnlicense-poc.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQCXlO7TZQbSwM59AvR8BNAYDE2uW7q4GFGEYG%2BlxPkrWEYXxtdYFFAF3jpIvGdD3%2Fd8qC6CDqjLep3UF9BEaP7xZN5EHqDLn6sZ39VSP6JW5waOtkoNkGmA8DHilfM%2BEZ7C%2Flj8cwBSPdJe%2BRfrLM74uW4t6oqBdDlb8aInqee%2BuOwODIDSfdac2sscJhaxU%2BBsPD9Jiag%2FZ8bT6RHqCh3HHpT%2BcIyrUlKm1OZzbirL7rlGXKF7s9GFBI1EUHR504Q1ny%2FVUdync%2FkGHV9WMCApY5umSo5O8qAmtbKOru7UPE7I14qdVu1ZJA33sIDKLJjNrsOw5jg0mlwosQB%2Bp7aqw61aT7Efjg4V4r8jn0nGnCJx4trfITy379FQvBQwajf8WVRpAGdRhEuSWK3n%2B2s2nnchEg%2F%2BF4xAaWQXqbqamv46LRrKzzm8p%2FTwWQg3vcKjglTaZny09F%2BQlA2bOUQ8qRt8%2BKVvOJinKDuYC%2B2X8s5%2BahPNDiEcPQZ4hz1uizWblVALr%2Fx2wRFVUbazk7PIZVtkpm1NVp%2FGZareG3qIMnLl%2ByWSB5wWKlX7SQImppXmqAK6vsSA588Wj0suA%2B3tcaGCvZ9QyQ78DQ8FPpM%2BxUt0ZJDkSRfnHoVz6z%2FpRu49%2BLnt5bQ4NkWuL4iVMBMp527pWMpgRseVFRq42id6UOcmJ%2BPhZztJ0gr64NKZDIDoz%2FbjwG4KkZyyD979BsffFktZrUGDK3D5Ercdooz179kekANmdRIGvG2WRoEQ6Ld9TcRu0aGvhJ0%2BM1uKbxzDSstSh26bcpVAQRHbes%2FDnxenp50OMRhWmaHrH7TPbIRXuevJ8i1ylBuS8EaQbbKFLT3SjeIp%2BClYNj5hkyDwI38Y6lSvrEVwNFs9voyj3YzhRaOYa6EphgkI1beT1ZcWoJKwK7z20DyYedMARPM8gnlmiaVlffZjG74Pze9Fn7jCptcJMtZ%2Fsh%2FyLrdOA8G8MMPaLsrZPo%3D/CD1010003913_20210706210703.m3u8"
}


struct DownLoadPlayer:View, PageProtocol {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var tvPlayerModel: TVPlayerModel = TVPlayerModel()
    @ObservedObject var downLoader: HLSDownLoader = HLSDownLoader()
    
    let prevLoader = CustomAssetResourceLoader(playerDelegate: nil)
    let keyCoreData = PersistContentKeyCoreDataManager()
    
    @State var downloadPath:String = Self.videoPath
    @State var licensePath:String = Self.licensePath
    
    @State var videoPath:String? = nil
    @State var licenseKey:Data? = nil
    @State var progress:Double = 0
    
    @State var fileID:String = "test"
    @State var keys:[String] = []
    @State var apiPath:String = "https://drm.digicaps.dev/resources/playlist/fairplay/bmt"
    @State var isListView:Bool = false
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    InputCell(
                        title: "List",
                        input: self.$apiPath
                    )
                    FillButton(text: "load") { _ in
                        self.isListView = true
                        
                    }.frame(width: 100)
                }
                .padding(.all, 10)
                .background(Color.app.blue100)
                ZStack(alignment: .topTrailing){
                    
                    TVPlayer(
                        pageObservable:self.pageObservable,
                        viewModel:self.tvPlayerModel)
                    Text(self.bitrate ?? "")
                        .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.white))
                        .padding(.all, Dimen.margin.thin)
                }
                
                HStack{
                    Text(self.fileID)
                        .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                    Text(self.progress.description)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
                        .frame(width: 100)
                }
                .padding(.all, 10)
                .background(Color.app.blue100)
                HStack{
                    FillButton(text:"start"){_ in
                        if self.licenseKey != nil {
                            self.play()
                        } else {
                            self.downLoader.getCertificateData(license: self.licensePath){ cert in
                                self.licenseKey = cert
                                self.play()
                            }
                        }
                        
                    }
                    FillButton(text:"togglePlay"){_ in
                        self.tvPlayerModel.event = .togglePlay(isUser: true)
                    }
                }

                HStack{
                    FillButton(text:"download video"){_ in
                        if self.licenseKey != nil {
                            self.downLoader.start(path: self.downloadPath, ckcURL: self.licensePath, licenseData: self.licenseKey)
                        } else {
                            self.downLoader.getCertificateData(license: self.licensePath){ cert in
                                self.licenseKey = cert
                                self.downLoader.start(path: self.downloadPath, ckcURL: self.licensePath, licenseData: self.licenseKey)
                            }
                        }
                    }
                    FillButton(text:"delete"){_ in
                        self.delete()
                    }
                }
                Text(self.debugingInfo ?? "")
                    .lineLimit(1).onTapGesture {
                        UIPasteboard.general.string = self.debugingInfo
                        self.appSceneObserver.event = .toast("복사되었습니다")
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.all, 10)
                    .modifier(MatchHorizontal(height: 30))
                    .background(Color.app.white)
                    
                Text(self.debugInfo ?? "")
                    .lineLimit(1).onTapGesture {
                        UIPasteboard.general.string = self.debugInfo
                        self.appSceneObserver.event = .toast("복사되었습니다")
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.all, 10)
                    .modifier(MatchHorizontal(height: 30))
                    .background(Color.app.white)
            }
            if self.isListView {
                TestList(apiPath:self.apiPath){ select in
                    self.isListView = false
                    guard let data = select else {return}
                    self.tvPlayerModel.event = .pause(isUser: false)
                    self.delete()
                    self.progress = 0
                    self.fileID = data.title + "_" + data.subTitle
                    self.downloadPath = data.videoPath
                    self.licensePath = data.ckcURL ?? ""
                    
                }
            }
        }
        .background(Color.brand.bg)
        .padding(.vertical, Dimen.margin.heavy)
        .onAppear{
            self.downLoader.fileName = self.fileID
            if self.downLoader.isExistFile() {
                self.videoPath = self.downLoader.getFileFullPath().path
            }
        }
        .onDisappear{
            
        }
        .onReceive(self.tvPlayerModel.$bitrate){ bitrate in
            guard let bitrate = bitrate else {return}
            self.bitrate = "res : " + bitrate.description
        }
        .onReceive(self.tvPlayerModel.$error){ error in
            guard let error = error else {return}
            switch error {
            case .connect(let msg) : self.debugInfo = "Connect : " + msg
            case .illegalState(let evt) : self.debugingInfo = "IllegalState : " + evt.decription
            case .stream(let err) : self.debugInfo = "Stream : " + err.getDescription()
            case .drm(let err): self.debugInfo = "Drm : " + err.getDescription()
            case .asset(let e) : self.debugInfo = "Asset : " + e.getDescription()
            }
        }
        .onReceive(self.tvPlayerModel.$streamEvent){evt in
            switch evt {
            case .persistKeyReady(let contentId, let ckcData) : 
                guard let id = contentId, let data = ckcData else {return}
                keyCoreData.setData(contentId: id, data: data )
            default : break
            }
            
        }
        .onReceive(self.downLoader.$hlsEvent){ evt in
            switch evt {
            case .getPersistKey(let ckcData, let contentId) :
                self.keys.append(contentId)
                keyCoreData.setData(contentId: contentId, data: ckcData)

            default : break
            }
        }
        .onReceive(self.downLoader.$event){ evt in
            switch evt {
            case .complete(let path) :
                self.videoPath = path.path
                keyCoreData.setData(fileId: self.fileID, contentIds: self.keys)
            case .error(let err) :
                if let assetErr = err as? AssetLoadError {
                    self.appSceneObserver.alert = .alert("Asset error", assetErr.getDescription())
                } else if let drmErr = err as? DRMError {
                    self.appSceneObserver.alert = .alert("DRM error", drmErr.getDescription())
                } else {
                    self.appSceneObserver.alert = .alert("download error", err.localizedDescription)
                }
                
            default : break
            }
        }
        .onReceive(self.downLoader.$progress){ pro in
            self.progress = pro
        }
    }
    @State var bitrate:String? = nil
    @State var debugingInfo:String? = "test debuging"
    @State var debugInfo:String? = "test debug"
    
    func play(){
        let drm = FairPlayDrm(ckcURL: self.licensePath , certificateURL: self.licensePath)
        drm.certificate = self.licenseKey
        var persistKeys:[(String,Data,Date)] = []
        if let keys = self.keyCoreData.getData(fileId: self.fileID)?.0 {
            keys.forEach{
                if let key = self.keyCoreData.getData(contentId: $0) {
                    persistKeys.append(key)
                }
            }
        }
        drm.persistKeys = persistKeys
        self.tvPlayerModel.drm = drm
        DispatchQueue.main.async {
            guard let video = videoPath else {
                drm.useOfflineKey = false
                self.tvPlayerModel.event = .load(self.downloadPath)
                self.appSceneObserver.alert = .alert(nil, "online play")
                return
            }
            drm.useOfflineKey = true
            self.tvPlayerModel.event = .load(video)
        }
    }
    func delete(){
        self.downLoader.removeFile()
        self.downLoader.reset()
        self.videoPath = nil
        self.licenseKey = nil
        self.keyCoreData.deleteData(fileId: self.fileID)
        self.keys.forEach{
            self.keyCoreData.deleteData(contentId: $0)
        }
        self.keys = []
    }
}
