//
//  DownLoadItems.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/16.
//

import Foundation
import SwiftUI
struct DownloadTaskItem:View, PageProtocol {
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @ObservedObject var downLoader: HLSDownLoader = HLSDownLoader()
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var q:DownLoadQ
    @State var progress:Double = 0
    @State var status:DownLoaderStatus = .ready
    @State var buttonText:String = "start"
    @State var isCompleted:Bool = false
    @State var isError:Bool = false
    let action: (_ data:DownLoadQ) -> Void
    var body: some View {
        HStack{
            Text(self.q.fildID)
                .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
            Text(self.progress.toPercent(n: 2))
                .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.white))
            FillButton(text:self.buttonText){_ in
                switch self.status {
                case .ready :
                    if let key = q.licenseKey {
                        self.downLoader.start(path: self.q.path, ckcURL: self.q.ckcURL, licenseData:key)
                    } else {
                        self.downLoader.getCertificateData(license: self.q.ckcURL){ key in
                            self.downLoader.start(path: self.q.path, ckcURL: self.q.ckcURL, licenseData: key)
                        }
                    }
                    
                case .progress :
                    self.downLoader.pause()
                case .pause :
                    self.downLoader.resume()
                case .error :
                    self.downLoader.reset()
                    self.downLoader.start(path: self.q.path, ckcURL: self.q.ckcURL, licenseData: q.licenseKey)
                case .complete :
                    ComponentLog.d("file : " + self.downLoader.getFileFullPath().path, tag: self.tag )
                    if self.downLoader.isExistFile() {
                        self.appSceneObserver.alert = .alert("enjoy play")
                    } else {
                        self.appSceneObserver.alert = .alert("no file error")
                    }
                }
                
            }
            .frame(width: 100)
            FillButton(text:"online play", isSelected: true){_ in
                self.action(self.q)
            }
            .frame(width: 100)
            FillButton(text:"del", isSelected: false){_ in
                self.downLoader.stop()
                self.downLoadTaskProvider.request(q: .init(id: self.tag, type: .clear, fildID: self.q.fildID))
            }
            .frame(width: 50)
            
            
        }
        .padding(.all, Dimen.margin.tiny)
        .onReceive(self.downLoader.$status){ stat in
            DataLog.d("downLoader " + self.downLoader.id, tag: self.tag)
            self.status = stat
            switch stat {
            case .ready :
                self.buttonText = "start"
                self.isCompleted = false
                self.isError = false
            case .progress :
                self.buttonText = "pause"
            case .pause :
                self.buttonText = "resume"
            case .error :
                self.buttonText = "error retry"
                self.isError = true
            case .complete :
                self.buttonText = "check file"
                self.isCompleted = true
            }
        }
        .onReceive(self.downLoader.$progress){ pro in
            self.progress = pro
        }
    }
}

struct DownloadItem:View, PageProtocol {
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var file:HLSFile
    let action: (_ data:HLSFile) -> Void
    var body: some View {
        HStack{
            Text(self.file.id)
                .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
            FillButton(text:self.file.isExfire ? "exfire" : "play"){_ in
                self.action(self.file)
            }
            .frame(width: 50)
            FillButton(text:"del", isSelected: false){_ in
                self.downLoadTaskProvider.request(q: .init(id: self.tag, type: .delete, fildID: self.file.id))
            }
            .frame(width: 50)
           
        }
        .padding(.all, Dimen.margin.tiny)
    }
}
