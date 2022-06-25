//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct TopFunctionBox: PageView {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var myTvModel:MyTvModel = MyTvModel()
    @ObservedObject var myChannelModel:MyChannelModel = MyChannelModel()
    @ObservedObject var tvPlayerModel: TVPlayerModel = TVPlayerModel()
    
    @State var isShowing:Bool = false
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ImageButton(
                defaultImage: Asset.icon.back
            ){ idx in
                self.appSceneObserver.event = .close
            }
            HStack( spacing: Dimen.margin.micro ){
                Image(Asset.brand.logo, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 12)
                Text(self.channelTitle)
                    .modifier(RegularTextStyle(size: Font.size.micro, color: Color.app.white))
                    .padding(.top, 2)
            }
            .padding(.horizontal, Dimen.margin.tiny)
            .frame(height:Dimen.bar.medium)
            .background(self.channelType.color)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                HStack(spacing:0){
                    if let title = self.programTitle {
                        Text(title)
                            .modifier(MediumTextStyle(size: Font.size.medium, color: Color.app.white))
                            .padding(.top, 3)
                    }
                    if self.channelType != .live, let id = self.currentProgramId {
                        ImageButton(
                            defaultImage: Asset.icon.info
                        ){ idx in
                            
                        }
                    }
                }
            }
            .padding(.leading, Dimen.margin.thin)
            
            ImageButton(
                defaultImage: Asset.icon.list
            ){ idx in
                
            }
            ImageButton(
                defaultImage: Asset.icon.setting
            ){ idx in
                
            }
            .padding(.leading, Dimen.margin.micro)
        }
        .padding(.horizontal, Dimen.margin.regular)
        .modifier(MatchHorizontal(height: 64))
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.myTvModel.$event){evt in
            switch evt {
            case .channelChanged : self.channelUpdate()
            default : break
            }
        }
        .onReceive(self.myChannelModel.$event){evt in
            switch evt {
            case .programChanged : self.programUpdate()
            default : break
            }
        }
        .onReceive(self.tvPlayerModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view : self.isShowing = true
                default : self.isShowing = false
                }
            }
        }
    }
    
    @State var channelTitle:String = ""
    @State var channelType:ChannelType = .vod
    @State var programTitle:String? = nil
    @State var currentChannelId:String = ""
    @State var currentProgramId:String? = nil
    
    func channelUpdate(){
        guard let channel = self.myTvModel.currentChannel else {
            self.channelEmpty()
            return
        }
        self.channelTitle = channel.currentTitle
        self.channelType = channel.type
    }
    
    func programUpdate(){
        guard let program = self.myChannelModel.currentProgram else {
            self.programEmpty()
            return
        }
        self.programTitle = program.currentTitle
        self.currentProgramId = program.currentItem?.epsdRsluId
    }
    
    func channelEmpty(){
        self.channelTitle = ""
        self.programTitle = nil
        self.currentChannelId = ""
        self.currentProgramId = nil
        self.channelType = .vod
    }
    
    func programEmpty(){
        self.programTitle = nil
        self.currentProgramId = nil
    }
}

