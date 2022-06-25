//
//  TestFramework.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/02.
//

import Foundation
import UIKit
import CoreTelephony
import SwiftUI
import Kingfisher
import BackgroundTasks

class AppDelegate: PageProtocol {
    static var orientationLock = UIInterfaceOrientationMask.all
}
class AppSceneObserver:ObservableObject{
    @Published var isLock = false
    @Published var isLoading = false
    @Published var loadingInfo:[String]? = nil
    @Published var alert:SceneAlert? = nil
    @Published var alertResult:SceneAlertResult? = nil {didSet{ if alertResult != nil { alertResult = nil} }}
    @Published var radio:SceneRadio? = nil
    @Published var radioResult:SceneRadioResult? = nil {didSet{ if radioResult != nil { radioResult = nil} }}
    @Published var select:SceneSelect? = nil
    @Published var selectResult:SceneSelectResult? = nil {didSet{ if selectResult != nil { selectResult = nil} }}
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published var launcherRequest:LauncherRequest? = nil
}

enum SceneEvent {
    case initate,
         toast(String), toastData(ToastData, ((Int) -> Void)? = nil),
         close
}


public struct MyTvPlayer:View {
    @ObservedObject var launcher:MyTvLauncherObservable = MyTvLauncherObservable()
    //@ObservedObject var appSceneObserver = AppSceneObserver()
    public init(launcher:MyTvLauncherObservable?) {
        if let launcher = launcher {
            self.launcher = launcher
        }
    }
    public var body: some View {
        MyTvPlayerLauncher(launcher:self.launcher)
            .environmentObject(Repository())
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .environmentObject(AsyncImageLoader())
            .environmentObject(DownLoadTaskProvider())
            .environmentObject(PageSceneObserver()) //사용안함
            .environmentObject(PagePresenter()) //사용안함
            .onReceive(self.launcher.$event){ evt in
                switch evt {
                case .updated :
                    SystemEnvironment.apolloId = self.launcher.id
                    SystemEnvironment.apolloToken = self.launcher.token
                case .updatedLogLv(let lv) : self.setupLogLv(lv.lv)
                default : break
                }
            }
            
            .onAppear(){
                SystemEnvironment.apolloId = self.launcher.id
                SystemEnvironment.apolloToken = self.launcher.token
                if let lv = self.launcher.logLv {
                    self.setupLogLv(lv.lv)
                }
            }
    }
    
    private func setupLogLv(_ lv:Int){
        PageLog.lv = lv
        DataLog.lv = lv
        ComponentLog.lv = lv
    }
}

public struct MyTvDownLoad:View {
    public init() {}
    public var body: some View {
        MyTvDownLoadLauncher()
            .environmentObject(Repository())
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .environmentObject(AsyncImageLoader())
            .environmentObject(DownLoadTaskProvider())
            .environmentObject(PageSceneObserver()) //사용안함
            .environmentObject(PagePresenter()) //사용안함
    }
}

struct MyTvPlayerLauncher:View, PageProtocol {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var launcher:MyTvLauncherObservable = MyTvLauncherObservable()
    let tvPlayerModel: TVPlayerModel = TVPlayerModel()
    let myTvModel:MyTvModel = MyTvModel()
    let myChannelModel:MyChannelModel = MyChannelModel()
    
    @State var status:RepositoryStatus? = nil
    @State var loadingInfo:[String]? = nil
    @State var isLoading = true
    @State var isStoreInit = false
    @State var isInit = false
    @State var toast:ToastData? = nil
    @State var isToastShowing:Bool = false
    @State var toastAction: ((_ idx:Int) -> Void)? = nil
    public var body: some View {
        ZStack(alignment: .topLeading){
            if self.isInit {
                GestureViewer(
                    tvPlayerModel:self.tvPlayerModel,
                    myTvModel: self.myTvModel,
                    myChannelModel: self.myChannelModel
                )
                Button(action: {
                    let info = self.loadingInfo!.first
                }) {
                    Text("crash")
                }
                .padding(.all, Dimen.margin.medium)
            }
            Group {
                SceneAlertController()
            }
            
            if self.isLoading == true {
                Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                    .accessibility(label: Text(self.loadingInfo?.first ?? String.alert.loading ))
                if let loadingInfo = self.loadingInfo  {
                    SceneLoading(loadingInfo:loadingInfo)
                        .accessibilityHidden(true)
                }
                CircularSpinner(resorce: Asset.ani.loading)
                    .accessibilityHidden(true)
            }
        }
        .background(Color.brand.bg)
        .toast(isShowing: self.$isToastShowing , data: self.toast ?? ToastData()){ idx in
            self.toastAction?(idx)
        }
        .onAppCameToForeground {
            PageLog.d("App came to foreground", tag:self.tag)
        }
        .onAppWentToBackground {
            PageLog.d("App went to background", tag:self.tag)
        }
        .onAppear{
            self.repository.setupEnvironmentObject(
                dataProvider: self.dataProvider,
                appSceneObserver: self.appSceneObserver,
                downLoadTaskProvider : self.downLoadTaskProvider
            )
            /*
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                PageLog.d("Family: \(family) Font names: \(names)")
            }*/
        }
        .onReceive(self.launcher.$request){ request in
            self.appSceneObserver.launcherRequest = request
        }
        .onReceive(self.repository.$status){ status in
            self.status = status
            switch status  {
            case .ready :
                self.isInit = true
            default :
                self.isInit = false
            }
        }
        .onReceive(self.appSceneObserver.$isLoading){ loading in
            withAnimation{
                self.isLoading = loading
            }
        }
        .onReceive(self.appSceneObserver.$loadingInfo){ loadingInfo in
            self.loadingInfo = loadingInfo
            withAnimation{
                self.isLoading = loadingInfo == nil ? false : true
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in

            switch evt  {
            case .initate: break
            case .toast(let msg):
                self.toast = ToastData( text: msg )
                withAnimation{
                    self.isToastShowing = true
                }
            case .toastData(let data, let action):
                self.toast = data
                self.toastAction = action
                withAnimation{
                    self.isToastShowing = true
                }
            case .close :
                self.launcher.close()
            default:break
            }
            
        }
    }
    
    func openPopupTest(){
        // 일반
        self.appSceneObserver.alert = .confirm(
            "MY TV가 매일 추천하는 영상이 마음에 드시나요?",
            "다운로드를 설정하시면 데이터 소모 없이 고화질 영상을 미리 다운로드 해둘게요.",
            confirmText: "지금 설정할게요",
            cancelText: "나중에 할게요"){ isOk in
                
            }
        // 이미지
        self.appSceneObserver.alert = .guideConfirm(
            "MY TV가 매일 추천하는 영상이 마음에 드시나요?",
            "다운로드를 설정하시면 데이터 소모 없이 고화질 영상을 미리 다운로드 해둘게요.",
            guide: Asset.character.alert,
            confirmText: "지금 설정할게요",
            cancelText: "나중에 할게요", nil)
        
        // 토스트
        self.appSceneObserver.event = .toastData(.init(
            character: Asset.character.toast1,
            text: "MY TV 추천 영상이 마음에 드시나요?\n데이터 소모 없이 고화질로 추천 다운로드해 둘게요.",
            position: 100,
            duration: 1, btns: ["오늘 그만 볼게요", "지금 설정할게요"])){ idx in
                
            
        }
    }
    
}


struct MyTvDownLoadLauncher:View {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    let tvPlayerModel: TVPlayerModel = TVPlayerModel()
    let hlsDownLoader:HLSDownLoader = HLSDownLoader()
    let downLoader:DownLoader = DownLoader()
    let myTvModel:MyTvModel = MyTvModel()
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = true
    @State var isStoreInit = false
    @State var isInit = false
    @State var toast:ToastData? = nil
    @State var isToastShowing:Bool = false
    
    public var body: some View {
        ZStack(alignment: .topLeading){
            DownloadTaskViwer(tvPlayerModel:self.tvPlayerModel)
            Group {
                SceneAlertController()
            }
            
            if self.isLoading == true {
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                    .accessibility(label: Text(self.loadingInfo?.first ?? String.alert.loading ))
                if let loadingInfo = self.loadingInfo  {
                    SceneLoading(loadingInfo:loadingInfo)
                }
                CircularSpinner(resorce: Asset.ani.loading)
            }
                
        }
        .background(Color.brand.bg)
        .toast(isShowing: self.$isToastShowing , data:self.toast ?? ToastData()){ idx in
            
        }
        .onAppear{
            self.repository.setupEnvironmentObject(
                dataProvider: self.dataProvider,
                appSceneObserver: self.appSceneObserver,
                downLoadTaskProvider : self.downLoadTaskProvider
            )
        }
        
        .onReceive(self.appSceneObserver.$isLoading){ loading in
            withAnimation{
                self.isLoading = loading
            }
        }
        .onReceive(self.appSceneObserver.$loadingInfo){ loadingInfo in
            self.loadingInfo = loadingInfo
            withAnimation{
                self.isLoading = loadingInfo == nil ? false : true
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .initate: break
            case .toast(let msg):
                self.toast = ToastData( text: msg )
                withAnimation{
                    self.isToastShowing = true
                }
            default:break
            }
            
        }
    }
    
}


