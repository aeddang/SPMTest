//
//  DownLoadButton.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/24.
//

import Foundation
import SwiftUI

struct DownLoadStatusButton: PageComponent {
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    @State var fileId:String = ""
    
    var body: some View {
        ZStack{
            
            switch self.status {
            case .none :
                ImageButton(
                    defaultImage: Asset.download.like
                ){ idx in
                    self.downLoadProcessStart()
                }
            case .loading(let status) :
                
                switch status {
                case .pause:
                    ImageButton(
                        defaultImage: Asset.download.download
                    ){ idx in
                        self.downLoader?.resume()
                    }
                case .ready, .error:
                    ImageButton(
                        defaultImage: Asset.download.download
                    ){ idx in
                        self.downLoadTaskProvider.request(q: .init(id: self.tag, type: .clear, fildID: self.fileId))
                        self.downLoadProcessStart()
                    }
                default :
                    ImageAnimation(
                        images: Asset.download.loading,
                        fps:0.2,
                        isRunning: .constant(true)
                    )
                    .modifier(MatchParent())
                }
                
            case .loaded :
                Image(Asset.download.downloadOn, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
            }
        }
        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
        .onReceive(self.downLoadTaskProvider.$event){ evt in
            switch evt {
            case .existTask(let id) :
                if self.fileId != id {return}
                self.appSceneObserver.alert = .alert("existTask", "진행중인 다운로드 입니다")
            case .existFile(let id) :
                if self.fileId != id {return}
                self.appSceneObserver.alert = .alert("existFile", "이미 다운받은 파일입니다")
            case .add(let id, _, _) :
                if self.fileId != id {return}
                self.updateDownLoadStatus()
            case .remove(let id) :
                if self.fileId != id {return}
                self.updateDownLoadStatus()
            case .complete(let id, _) :
                if self.fileId != id {return}
                self.updateDownLoadStatus()
            case .start(let id, let fileSize) :
                if self.fileId != id {return}
                self.appSceneObserver.event = .toast(id + " download start " + fileSize.description)
                self.updateDownLoadStatus()
            default : break
            }
        }
        .onReceive(self.viewModel.$currentPlayId) { playId in
            guard let id = playId else {return}
            self.fileId = id
            self.updateDownLoadStatus()
        }
        .onAppear(){
            self.updateDownLoadStatus()
        }
    }
    
    let scs:Scs = Scs(network: ScsNetwork())
    @State var downLoader:HLSDownLoader? = nil
    @State var status: DownLoadTaskStatus = .none
    private func updateDownLoadStatus(){
        self.status = self.downLoadTaskProvider.getDownLoadTaskStatus(id: self.fileId)
        self.downLoader = self.downLoadTaskProvider.tasks[self.fileId]
    }
    
    @State var selectQuality:Quality? = nil
    private func downLoadProcessStart(){
        self.scs.getPlay(
            epsdRsluId: self.fileId, isPersistent: true,
            completion: {res in
                if let data = res.CTS_INFO {
                    self.selectQuality = self.viewModel.getDownLoadData(data: data)
                    if let q = self.selectQuality {
                        self.startDownLoad(q)
                    }
                } else {
                    self.appSceneObserver.event = .toast(self.fileId + " download error")
                    self.resetQuality()
                }
                
            },
            error:{err in
                self.appSceneObserver.event = .toast(self.fileId + " download error")
                self.resetQuality()
            })
    }
    
    private func resetQuality(){
        self.selectQuality = nil
        self.downLoader = nil
    }
    
    private func startDownLoad(_ quality:Quality){
        self.downLoadTaskProvider.request(q: .init(
            id: self.tag, type: .load, fildID: self.fileId,
            path: quality.path,
            ckcURL: quality.drmLicense ?? ""
        ))
    }
     
}
