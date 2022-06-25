//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
extension OptionSelectBox{
    static let rates:[(Float, String)] = [
        (0.8, "x0.8"),
        (1.0,String.player.rateDefault+"(x1.0)"),
        (1.2, "x1.2"),
        (1.5, "x1.5"),
        (2.0, "x2.0")
    ]
    
    enum SelectOptionType:String {
        case rate
        var title: String {
            switch self {
            case .rate: return String.player.rate
            }
        }
    }
    
    struct BtnData:Identifiable{
        let id = UUID.init()
        let title:String
        let accessibility:String
        let index:Int
        var value:Any? = nil
    }
}
struct OptionSelectBox: PageView {
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    @State var isShowing:Bool = false
    @State var btns:[BtnData] = []
    @State var selectedIdx:Int = -1
    @State var type:SelectOptionType = .rate
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ZStack{
                HStack(spacing: Dimen.margin.regular){
                    Text(self.type.title)
                        .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .frame(height:Dimen.button.thin)
                    ForEach(self.btns) { btn in
                        RectButton(
                            text: btn.title,
                            isSelected: self.selectedIdx == btn.index
                        ){ _ in
                            
                            switch type {
                            case .rate :
                                guard let value = btn.value as? Float else { return }
                                self.viewModel.event = .rate(value, isUser: true)
                            }
                            self.viewModel.selectOptionType = nil
                        }
                        .accessibility(label: Text( btn.title))
                    }
                }
            }
            .modifier(MatchParent())
            .padding(.leading, Dimen.icon.thin)
            ImageButton(
                defaultImage: Asset.icon.close,
                size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
            ){ idx in
                self.viewModel.selectOptionType = nil
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
        .onReceive(self.viewModel.$selectOptionType) { type in
            guard let type  = type else{
                withAnimation{
                    self.isShowing = false
                }
                return
            }
            self.type = type
            self.viewModel.playerUiStatus = .hidden
            self.selectedIdx = -1
            switch type {
            case .rate :
                self.btns = zip(0...Self.rates.count, Self.rates).map{ idx, r in
                    if self.viewModel.rate == r.0 {
                        self.selectedIdx = idx
                    }
                    return BtnData(
                        title: r.1 ,
                        accessibility:r.1 + String.player.rate,
                        index: idx, value: r.0)
                }
            }
            withAnimation{
                self.isShowing = true
            }
            
        }
    }
    
}

