//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
enum SceneSelect:Equatable {
    case select((String,[String]),Int, Bool? = false, ((Int) -> Void)? = nil),
         selectBtn((String,[SelectBtnData]),Int, Bool? = false, ((Int) -> Void)? = nil),
         picker((String,[String]),Int, ((Int) -> Void)? = nil),
         datePicker((String, Int), Date, ((Date?) -> Void)? = nil),
         multiPicker((String,[[String]]),[Int], ((Int,Int,Int,Int) -> Void)? = nil)
    
    func check(key:String)-> Bool{
        switch (self) {
        case let .selectBtn(v, _, _, _): return v.0 == key
        case let .select(v, _, _, _): return v.0 == key
        case let .picker(v, _, _): return v.0 == key
        case let .datePicker(v, _, _): return v.0 == key
        case let .multiPicker(v, _, _): return v.0 == key
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
        case (let .selectBtn(lh,_, _, _), let .selectBtn(rh,_, _, _)): return lh.0 == rh.0
        case (let .select(lh,_, _, _), let .select(rh,_, _, _)): return lh.0 == rh.0
        case (let .picker(lh,_, _), let .picker(rh,_, _)): return lh.0 == rh.0
        case (let .datePicker(lh,_, _), let .datePicker(rh,_, _)): return lh.0 == rh.0
        case (let .multiPicker(lh,_, _), let .multiPicker(rh,_, _)): return lh.0 == rh.0
        default : return false
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}



struct SceneSelectController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    @State var selected:Int = 0
    @State var buttons:[SelectBtnData] = []
    @State var currentSelect:SceneSelect? = nil
        
    @State var isCancel = false
    @State var completCancel = false
    
    var body: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: self.$isShow,
            index: self.$selected,
            buttons: self.buttons,
            isCancel:self.isCancel,
            completCancel:self.completCancel)
        { idx in
            switch self.currentSelect {
            case .select(_ , _, _, let handler) , .selectBtn(_ , _, _, let handler) :
                if let handler = handler {
                    self.selectedSelect(idx ,data:self.currentSelect!, completionHandler: handler)
                } else {
                    self.selectedSelect(idx ,data:self.currentSelect!)
                }
                default: break
            }
            withAnimation{
                self.isShow = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isShow {return}
                self.reset()
            }
        }
        
        .onReceive(self.sceneObserver.$select){ select in
            self.currentSelect = select
            switch select{
            case .select(let data, let idx, let completCancel, _): self.setupSelect(data:data, idx: idx, completCancel:completCancel!)
            case .selectBtn(let data, let idx, let useCancel, _): self.setupSelect(data:data, idx: idx, useCancel:useCancel!)
                default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
        .accessibility(hidden: !self.isShow )
    }//body
    
    func reset(){
        self.buttons = []
        self.currentSelect = nil
        self.isCancel = false
    }

    func setupSelect(data:(String,[String]), idx:Int, completCancel:Bool) {
        self.selected = idx
        self.isCancel = false
        self.completCancel = completCancel
        
        let range = 0 ..< data.1.count
        self.buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
    }
    func setupSelect(data:(String,[SelectBtnData]), idx:Int, useCancel:Bool) {
        self.selected = idx
        self.buttons = data.1
        self.isCancel = useCancel
    }
    func selectedSelect(_ idx:Int, data:SceneSelect, completionHandler: @escaping (Int) -> Void) {
        completionHandler(idx)
    }
    func selectedSelect(_ idx:Int, data:SceneSelect) {
        self.sceneObserver.selectResult = .complete(data, idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


