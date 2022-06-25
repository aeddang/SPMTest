//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
extension CaptionSelectBox{
    static let sizeTitles:[String] = [
        String.player.captionSizeLv1, String.player.captionSizeLv2, String.player.captionSizeLv3
    ]
    static let sizes:[CGFloat] = [
        110, 130, 150
    ]
    
    class LangData:InfinityData{
        private(set) var title:String = ""
        private(set) var value:String = ""
        private(set) var size:CGFloat = 0
        
        func setData(title:String, index:Int = 0, value:String = "", size:CGFloat = 0)->LangData{
            self.title = title
            self.index = index
            self.value = value
            self.size = size
            return self
        }
    }
}
struct CaptionSelectBox: PageView {
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var isShowing:Bool = false
    @State var langs:[LangData] = []
    @State var selectedIdx:Int = -1
    @State var selectedSize:Int = 0
    
    let sizes:[CaptionSelectBox.LangData] = zip(0..<CaptionSelectBox.sizeTitles.count, CaptionSelectBox.sizeTitles)
        .map{ idx, title in
            CaptionSelectBox.LangData().setData(title:title, index:idx, value:idx.description)
        }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                VStack(spacing: Dimen.margin.thin){
                    Text(String.player.caption) 
                        .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .frame(height:Dimen.button.thin)
                    Text(String.player.captionSize)
                        .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .frame(height:Dimen.button.thin)
                }
            }
            .frame(width: 160)
            ZStack(alignment: .leading){
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .horizontal,
                    showIndicators:false,
                    marginVertical: 0,
                    marginHorizontal: Dimen.margin.regular,
                    spacing: Dimen.margin.regular,
                    isRecycle:true,
                    useTracking: true
                ){
                    ForEach(self.langs) { btn in
                        RectButton(
                            text: btn.title,
                            isSelected: self.selectedIdx == btn.index
                        ){ _ in
                            self.viewModel.selectedCaptionLang = btn.value
                        }
                        .id( btn.hashId )
                        .accessibility(label: Text( btn.title))
                    }
                }
                .modifier(MatchHorizontal(height: Dimen.button.thin))
                HStack(spacing: Dimen.margin.regular){
                    ForEach(self.sizes) { btn in
                        RectButton(
                            text: btn.title,
                            isSelected: self.selectedSize == btn.index
                        ){ _ in
                            
                            if self.selectedIdx == 0 {return}
                            self.viewModel.selectedCaptionSize = btn.index
                        }
                        .id( btn.hashId )
                        .accessibility(label: Text( btn.title))
                    }
                }
                .padding(.leading, Dimen.margin.regular)
                HStack(spacing:0){
                    LinearGradient(
                        gradient:Gradient(colors: [Color.app.darkBlue100, Color.app.darkBlue100.opacity(0)]),
                        startPoint:.leading,
                        endPoint:.trailing
                    )
                    .modifier(MatchVertical(width: Dimen.margin.regular))
                    Spacer().modifier(MatchHorizontal(height: 0))
                    LinearGradient(
                        gradient:Gradient(colors: [Color.app.darkBlue100.opacity(0), Color.app.darkBlue100]),
                        startPoint:.leading,
                        endPoint:.trailing
                    )
                    .modifier(MatchVertical(width: Dimen.margin.regular))
                }
                .accessibility(hidden: true)
            }
            
            ImageButton(
                defaultImage: Asset.icon.close,
                size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
            ){ idx in
                self.viewModel.isCaptionSelect = false
            }
        }
        .modifier(BottomFunctionTab())
        .modifier(MatchHorizontal(height: 104))
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view : withAnimation{self.isShowing=false}
                default : break
                }
            }
        }
        .onReceive(self.viewModel.$subtitles){ langs in
            guard let langs = langs else {
                self.langs = []
                return
            }
            if langs.isEmpty {
                self.langs = []
                return
            }
            var subtitles = zip(1...langs.count,langs).map{idx, lang in
                LangData().setData(title: lang.decription , index:idx, value: lang.rawValue)
            }
            subtitles.insert( LangData().setData(title: String.player.captionOff, index:0,  value: ""), at: 0)
            self.langs = subtitles
            self.setupLang()
            if self.selectedIdx == -1 {return}
            self.viewModel.event = .captionChange(
                lang: self.langs[self.selectedIdx].value,
                size: Self.sizes[self.selectedSize])
        }
        .onReceive(self.viewModel.$isCaptionSelect) { select in
            withAnimation{
                self.isShowing = select
            }
            if select {
                self.viewModel.playerUiStatus = .hidden
                self.setupLang()
                self.selectedSize = self.viewModel.selectedCaptionSize
            }
        }
        .onReceive(self.viewModel.$selectedCaptionSize) { size in
            self.selectedSize = size
        }
        .onReceive(self.viewModel.$selectedCaptionLang) { lang in
            self.setupLang()
        }
    }
    
    private func setupLang(){
        if let find = self.langs.first(where: {$0.value == self.viewModel.selectedCaptionLang}){
            self.selectedIdx = find.index
            if self.langs.count <= self.selectedIdx {return}
            let id = self.langs[self.selectedIdx].hashId
            if self.viewModel.isPlay {
                self.viewModel.event = .pause(isUser: false)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                    self.viewModel.event = .resume(isUser: false)
                    self.infinityScrollModel.uiEvent = .scrollMove(id)
                }
                
            } else {
                self.infinityScrollModel.uiEvent = .scrollMove(id)
            }
            
        } else {
            self.selectedIdx = self.viewModel.selectedCaptionLang.isEmpty == false ? 1 : 0
        }
        
    }
    
}

