//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Foundation
import SwiftUI
import Combine

enum SceneAlert {
    case confirm(String?, String? = nil , String? = nil, confirmText:String? = nil,cancelText:String? = nil, (Bool) -> Void),
         alert(String?, String? = nil, String? = nil, confirmText:String? = nil, (() -> Void)? = nil),
         guideConfirm(String?, String? = nil, guide:String, confirmText:String? = nil, cancelText:String? = nil, ((Bool) -> Void)? = nil),
         apiError(ApiResultError),
         cancel

}
enum SceneAlertResult {
    case complete(SceneAlert), error(SceneAlert) , cancel(SceneAlert?), retry(SceneAlert?)
}
struct DeclarationData:Identifiable {
    let id = UUID.init().uuidString
    let key:String
}

struct SceneAlertController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @State var isShow = false
    @State var title:String? = nil
    @State var image:UIImage? = nil
    @State var text:String? = nil
    @State var subText:String? = nil
    @State var referenceText:String? = nil
    @State var alignment:HorizontalAlignment = .center
    @State var buttons:[AlertBtnData] = []
    @State var currentAlert:SceneAlert? = nil
    @State var delayReset:AnyCancellable? = nil
    
    var body: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: self.$isShow,
            title: self.title,
            image: self.image,
            text: self.text,
            subText: self.subText,
            referenceText: self.referenceText,
            alignment: self.alignment,
            buttons: self.buttons
        ){ idx in
            switch self.currentAlert {
            case .alert(_, _, _, _, let completionHandler) :
                if let handler = completionHandler { self.selectedAlert(idx, completionHandler:handler) }
            case .confirm(_, _, _, _, _, let completionHandler) : self.selectedConfirm(idx, completionHandler:completionHandler)
            case .guideConfirm(_, _, _, _, _, let completionHandler) :
                if let handler = completionHandler {  self.selectedConfirm(idx, completionHandler:handler) }
                
            case .apiError(let data): self.selectedApi(idx, data:data)
            default: return 
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        }
        .onReceive(self.appSceneObserver.$alert){ alert in
            self.currentAlert = alert
            switch alert{
            case .cancel :
                self.isShow = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.isShow {return}
                    self.reset()
                }
                return
            case .alert(let title,let text, let subText, let confirm,  _) :
                self.setupAlert(title:title, text:text, subText:subText, confirmText:confirm)
            case .confirm(let title,let text, let subText, let confirm, let cancel, _) :
                self.setupConfirm(title:title, text:text, subText:subText, confirmText:confirm, cancleText: cancel)
                
            case .guideConfirm(let title,let text, let image, let confirm, let cancel, _) :
                self.image = UIImage(named: SystemEnvironment.bundleId + "/" + image)
                if cancel == nil {
                    self.setupAlert(title:title, text:text, confirmText:confirm)
                } else {
                    self.setupConfirm(title:title, text:text, confirmText:confirm, cancleText: cancel)
                }
                
            case .apiError(let data): self.setupApi(data:data)
            default: return
            }
            withAnimation(.easeIn(duration: 0.2)){
                self.isShow = true
            }
            let voiceGuideText = (self.title ?? "") + (self.text ?? "") + (self.subText ?? "")
            UIAccessibility.announcement(voiceGuideText)
            
        }
        .accessibility(hidden: !self.isShow )
    }//body
    
    func reset(){
        if self.isShow { return }
        self.title = nil
        self.image = nil
        self.text = nil
        self.subText = nil
        self.referenceText = nil
        self.buttons = []
        self.currentAlert = nil
        self.alignment = .center
    }

    
    
    func setupApi(data:ApiResultError) {
        self.title = String.alert.api
        if let apiError = data.error as? ApiError {
            self.text = ApiError.getViewMessage(message: apiError.message)
        }else{
            self.text = String.alert.apiErrorServer
            self.buttons = [
                AlertBtnData(title: String.app.confirm, index: 2),
            ]
        }
    }
    
    func selectedApi(_ idx:Int, data:ApiResultError) {
        if idx == 1 {
            if data.isProcess {
                self.appSceneObserver.alertResult = .retry(nil)
            }else{
                self.dataProvider.requestData(q:.init(type:data.type))
            }
            
        }else if idx == 0  {
            self.appSceneObserver.alertResult = .cancel(nil)
        }
    }
    
    
    func setupConfirm(title:String?, text:String?, subText:String? = nil, confirmText:String? = nil, cancleText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title:  cancleText ?? String.app.cancel, index: 0),
            AlertBtnData(title: confirmText ?? String.app.confirm, index: 1)
        ]
    }
    func selectedConfirm(_ idx:Int,  completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 1)
    }
    
    func setupAlert(title:String?, text:String?, subText:String? = nil,  confirmText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title: confirmText ?? String.app.confirm, index: 0)
        ]
    }
    func selectedAlert(_ idx:Int, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}


