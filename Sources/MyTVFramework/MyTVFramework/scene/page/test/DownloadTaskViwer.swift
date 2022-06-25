//
//  DownloadViewer.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/09.
//

import Foundation
import SwiftUI

extension DownloadTaskViwer {
    static let filePath:String = "https://devmobilemig.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQ0Xdu90PjKSYUMw5tVAOB%2BjSPHYA6ToNsch7tj8u12AdYWJtjUKCCxuHgCpxVccjMGnx2zfUpquJ%2FgJ0j1biNAvT3zLshRc5rgHe1LQWKTOD5ehF6d2vk%2FKWxcWl%2BKHFm429%2BQPJtZH3QMxN8t6bcgiblKiqF7rrzzN5SmqRapSAMsz5sU10PKFzIPjH7jIJfMEUCYd%2FPhXkrVnJH3IYWWFtGgZ8LQtHHgZ6octQf%2F8xD8j4unUq8rG%2F6lkurcT35u0sm8D5%2BFL7vpl1cPzeZ3WJDNEEsgQQ7rk%2Ba9WW12flJXcnk2MaKrLISH8ECgs7d27ZdpTapEo67mje5bd52e%2B%2FAA5veDVoTC9S2yJi74%2Fl5DPdvx4%2B9oZUmJVle7tm4qjjnkxcuODguAIcFUVKFZmO%2BHrOaruZUaW%2BD3l4ucionyeehLoJt8lPOltNZzdtQTDW7Pl5Pg8EJDobexVnku691XEUbGITfJAI%2BXjwbuIGUc%2BY5PvitXzyCyJBi%2BgodPViJumGXIZEtaD9qtAj5cWNPw3k3enpawmspC2SzW%2BbPRN2IcIzwbRrgJbHmLuEXFMqkq6tr5%2F0dqe3vBATu0UpLFVQq%2Bg50rV2AUfVIq2IqgLp1GC4Z9ouvqKpkRUp9hsTi65hlTwxIE0v29eX%2BNvyk8LaEvj1qiGP1DsIz55t73HoqBJ4FC6eXjaX5h3t9%2BbYTQGn4spLSa4aqkRWf8NtQ%2BYH770z1p5fxopJ9jCPTCETgaXpQr7J5KK3pZSF3kyrDmtLExXkGr7L3CZu8J80sOnhEmLO2QYZYlX%2BcyfnYYlen5Zu4DH6js%2B9PP%2B9UW4uQlS2qvYfCDYB8pvSLBWOuBcViyp6ESn2hufKvySiIZsv7vBLnEnduyu4PgVAqhizZ8JfAOyiXpXceyrZWlacylOsyqVMB6Qhi6shxygEhfU981RbUR/CD1010003913_20210706210703.m3u8"
    static let licensePath:String = "https://ecdnlicense-poc.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQCXlO7TZQbSwM59AvR8BNAYDE2uW7q4GFGEYG%2BlxPkrWEYXxtdYFFAF3jpIvGdD3%2Fd8qC6CDqjLep3UF9BEaP7xZN5EHqDLn6sZ39VSP6JW5waOtkoNkGmA8DHilfM%2BEZ7C%2Flj8cwBSPdJe%2BRfrLM74uW4t6oqBdDlb8aInqee%2BuOwODIDSfdac2sscJhaxU%2BBsPD9Jiag%2FZ8bT6RHqCh3HHpT%2BcIyrUlKm1OZzbirL7rlGXKF7s9GFBI1EUHR504Q1ny%2FVUdync%2FkGHV9WMCApY5umSo5O8qAmtbKOru7UPE7I14qdVu1ZJA33sIDKLJjNrsOw5jg0mlwosQB%2Bp7aqw61aT7Efjg4V4r8jn0nGnCJx4trfITy379FQvBQwajf8WVRpAGdRhEuSWK3n%2B2s2nnchEg%2F%2BF4xAaWQXqbqamv46LRrKzzm8p%2FTwWQg3vcKjglTaZny09F%2BQlA2bOUQ8qRt8%2BKVvOJinKDuYC%2B2X8s5%2BahPNDiEcPQZ4hz1uizWblVALr%2Fx2wRFVUbazk7PIZVtkpm1NVp%2FGZareG3qIMnLl%2ByWSB5wWKlX7SQImppXmqAK6vsSA588Wj0suA%2B3tcaGCvZ9QyQ78DQ8FPpM%2BxUt0ZJDkSRfnHoVz6z%2FpRu49%2BLnt5bQ4NkWuL4iVMBMp527pWMpgRseVFRq42id6UOcmJ%2BPhZztJ0gr64NKZDIDoz%2FbjwG4KkZyyD979BsffFktZrUGDK3D5Ercdooz179kekANmdRIGvG2WRoEQ6Ld9TcRu0aGvhJ0%2BM1uKbxzDSstSh26bcpVAQRHbes%2FDnxenp50OMRhWmaHrH7TPbIRXuevJ8i1ylBuS8EaQbbKFLT3SjeIp%2BClYNj5hkyDwI38Y6lSvrEVwNFs9voyj3YzhRaOYa6EphgkI1beT1ZcWoJKwK7z20DyYedMARPM8gnlmiaVlffZjG74Pze9Fn7jCptcJMtZ%2Fsh%2FyLrdOA8G8MMPaLsrZPo%3D/CD1010003913_20210706210703.m3u8"
}

struct DownloadTaskViwer:View, PageProtocol {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var tvPlayerModel: TVPlayerModel = TVPlayerModel()
    @State var licenseKey:Data? = nil
    @State var tasks:[HLSDownLoader] = []
    @State var downLoadQ:[String:DownLoadQ] = [:]
    @State var files:[HLSFile] = []
    @State var isRecoveryFail:Bool = false
    @State var apiPath:String = "https://drm.digicaps.dev/resources/playlist/fairplay/bmt"
    @State var isListView:Bool = false
    @State var bitrate:String? = nil
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("DownloadTask TEST")
                        .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                    FillButton(text:"add"){_ in
                        self.downLoadTaskProvider.request(q:
                                .init(id: self.tag, fildID: "test",
                                      path: Self.filePath, ckcURL: Self.licensePath, licenseKey: self.licenseKey))
                    }
                    .frame(width: 100)
                    
                    if self.isRecoveryFail {
                        FillButton(text:"recovery"){_ in
                            self.isRecoveryFail = false
                            self.downLoadTaskProvider.recovery()
                        }
                        .frame(width: 100)
                    }
                }
                .padding(.all, 10)
                .background(Color.app.blue100)
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
                
                ScrollView{
                    VStack{
                        ForEach(self.tasks) { task in
                            let q = self.downLoadQ[task.fileName] ?? DownLoadQ(fildID: "error")
                            DownloadTaskItem(downLoader:task, q:q){ data in
                                self.play(q:data)
                            }
                        }
                    }
                }
                .modifier(MatchParent())
                ZStack(alignment: .topTrailing){
                    TVPlayer(
                        pageObservable:self.pageObservable,
                        viewModel:self.tvPlayerModel)
                    Text(self.bitrate ?? "")
                        .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.white))
                        .padding(.all, Dimen.margin.thin)
                }
                HStack{
                    ScrollView{
                        VStack{
                            ForEach(self.files) { file in
                                DownloadItem(file: file){ data in
                                    self.play(hls: data)
                                }
                            }
                        }
                    }
                    .modifier(MatchParent())
                }
            }
            if self.isListView {
                TestList(apiPath:self.apiPath){ select in
                    self.isListView = false
                    guard let data = select else {return}
                    let fileID = data.subTitle
                    let licensePath = data.ckcURL ?? ""
                    self.downLoadTaskProvider.request(q:
                            .init(id: self.tag, fildID: fileID,
                                  path: data.videoPath, ckcURL: licensePath))
                }
            }
        }
        .padding(.vertical, Dimen.margin.heavy)
        .background(Color.brand.bg)
        .onAppear{
            self.downLoadTaskProvider.recovery()
            
           
        }
        .onReceive(self.tvPlayerModel.$bitrate){ bitrate in
            guard let bitrate = bitrate else {return}
            self.bitrate = "res : " + bitrate.description
        }
        .onReceive(self.tvPlayerModel.$streamEvent){evt in
            switch evt {
            case .persistKeyReady(let contentId, let ckcData) :
                guard let file = currentFile else {return}
                guard let id = contentId, let data = ckcData else {return}
                self.repository.downloadManager.updatedKey(id: file.id, contentId: id, key: data)
               
            case .resumed :
                guard let file = currentFile else {return}
                file.persistKeys = self.repository.downloadManager.getPersistKeys(id: file.id)
                self.currentFile = nil
            default : break
            }
            
        }
        .onReceive(self.downLoadTaskProvider.$event){ evt in
            switch evt {
            case .existTask(_) :
                self.appSceneObserver.alert = .alert("existTask", "진행중인 다운로드 입니다")
            case .existFile(_) :
                self.appSceneObserver.alert = .alert("existFile", "이미 다운받은 파일입니다")
            case .add(let id, let loader, let q) :
                self.downLoadQ[id] = q
                self.tasks.append(loader)
            case .remove(let id) :
                self.downLoadQ.removeValue(forKey: id)
                if let find = self.tasks.firstIndex(where: {$0.fileName == id}) {
                    self.tasks.remove(at: find)
                }
            case .complete(let id,let path) :
                ComponentLog.d("file path : " + path, tag: self.tag)
                self.appSceneObserver.event = .toast(id + " download completed")
            case .start(let id, let fileSize) :
                self.appSceneObserver.event = .toast(id + " download start " + fileSize.description)
            case .recoveryFail :
                self.isRecoveryFail = true
            default : break
            }
        }
        .onReceive(self.downLoadTaskProvider.$downLoadEvent){ evt in
            switch evt {
            case .add(_, let file) :
                self.files.append(file)
            case .remove(let id) :
                if let find = self.files.firstIndex(where: {$0.id == id}) {
                    self.files.remove(at: find)
                }
            default : break
            }
        }
    }
    
    @State var currentFile:HLSFile? = nil
    func play(hls:HLSFile){
        self.currentFile = hls
        let drm = FairPlayDrm(ckcURL: Self.licensePath , certificateURL: Self.licensePath)
        drm.persistKeys = hls.persistKeys
        drm.certificate = self.licenseKey
        drm.useOfflineKey = true
        self.tvPlayerModel.drm = drm
        self.tvPlayerModel.event = .load(hls.filePath, true)
    }
    func play(q:DownLoadQ){
       
        self.appSceneObserver.event = .toast("online play")
        let drm = FairPlayDrm(ckcURL: q.ckcURL , certificateURL: q.ckcURL)
        drm.certificate = q.licenseKey
        drm.useOfflineKey = false
        self.tvPlayerModel.drm = drm
        self.tvPlayerModel.event = .load(q.path, true)
    }
}

