//
//  Viewer.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/08.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

extension Viewer {
    enum Direction {
        case left, top, right, bottom
        func title() -> String {
            switch self {
            case .left : return "left"
            case .right : return "right"
            case .top : return "top"
            case .bottom : return "bottom"
            }
        }
        func isVertical() -> Bool {
            switch self {
            case .left, .right : return false
            case .bottom, .top : return true
            }
        }
        func toVector() -> Int {
            switch self {
            case .left : return -1
            case .right : return 1
            case .top : return -1
            case .bottom : return 1
            }
        }
        static func getDirection(vector:Int, axes: Axis.Set) -> Direction {
            if vector > 0 {
                return axes == .horizontal ? .left : .top
            } else {
                return axes == .horizontal ? .right : .bottom
            }
        }
    }
}

struct Viewer:View {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var downLoadTaskProvider:DownLoadTaskProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var myTvModel:MyTvModel = MyTvModel()
    @ObservedObject var myChannelModel:MyChannelModel = MyChannelModel()
    var type:Direction = .top
   
    var body: some View {
        ZStack(){
            if !self.isEmpty {
                KFImage(URL(string: self.programImage?.image ?? ""))
                    .resizable()
                    .placeholder {
                        Image(Asset.noImg16_9)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
                ProgramInfoBox(
                    program: self.program, title: self.title, isAuto:self.isAuto, type: self.type)
            }
        }
        .background(Color.app.darkBlue100)
        .onReceive(self.myTvModel.$event){evt in
            if !self.type.isVertical() { return }
            switch evt {
            case .channelChanged : self.channelUpdate()
            case .channelUpdated(let channel) : self.channelUpdated(channel)
            case .channelUpdateError(let channel) : self.channelUpdateError(channel)
            default : break
            }
        }
        .onReceive(self.myChannelModel.$event){evt in
            if self.type.isVertical() {return}
            switch evt {
            case .currentChannelUpdated(let channel) : self.currentChannelUpdated(channel)
            case .programChanged : self.programUpdate()
            case .programUpdated(let program) : self.programUpdated(program)
            default : break
            }
        }
    }
    @State var isEmpty:Bool = false
    @State var isAuto:Bool = false
    @State var program:Program? = nil
    @State var title:String = ""
    @State var programImage:ImageSet? = nil
    @State var currentChannelId:String = ""
    @State var currentProgramId:String = ""
    func channelUpdate(){
        guard let channel = self.myTvModel.getChannel(directon: self.type) else {
            self.channelEmpty()
            return
        }
        self.isAuto = false
        self.isEmpty = false
        self.currentChannelId = channel.channelId
        if channel.needUpdate == true && self.type.isVertical() {
            self.dataProvider.requestData(q: .init(id:self.currentChannelId, type: channel.api))
        } else {
            self.channelUpdated(channel)
        }
    }
    func channelUpdated(_ channel:Channel){
        if self.currentChannelId != channel.channelId {return}
        self.title = channel.currentTitle
        self.program = channel.currentProgram
        self.programImage = self.program?.currentImage
        
    }
    func channelUpdateError(_ channel:Channel){
        if self.currentChannelId != channel.channelId {return}
        channelEmpty()
    }
    
    func channelEmpty(){
        self.title = ""
        self.program = nil
        self.programImage = nil
        self.isEmpty = true
    }
    
    //현재 채널
    func currentChannelUpdated(_ channel:Channel){
        self.title = channel.currentTitle
    }
    
    func programUpdate(){
        guard let program = self.myChannelModel.getProgram(directon: self.type) else {
            self.programEmpty()
            return
        }
        self.isAuto = false
        self.isEmpty = false
        self.currentProgramId = program.programId
        if program.needUpdate == true {
            //self.dataProvider.requestData(q: .init(id:self.currentChannelId, type: .getChannel(menuId: channel.menuId)))
            self.programUpdated(program)
        } else {
            self.programUpdated(program)
        }
    }
    func programUpdated(_ program:Program){
        if self.currentProgramId != program.programId {return}
        self.program = program
        self.programImage = self.program?.currentImage
        if program.type == .vod || program.type == .myFile {
            guard let item = program.currentItem else {return}
            if let file = self.downLoadTaskProvider.loadedFiles[item.epsdRsluId] {
                self.isAuto = file.isAuto
            }
        }
        
    }
    
    
    func programEmpty(){
        self.program = nil
        self.programImage = nil
        if !self.type.isVertical() {self.isEmpty = true}
    }
}

