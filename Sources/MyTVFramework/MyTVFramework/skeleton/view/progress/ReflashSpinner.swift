//
//  ReflashSpinner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/05.
//
import Foundation
import SwiftUI

struct ReflashSpinner: PageComponent {
    @Binding var progress:Double
    var progressMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    var text:String? = nil
    var body: some View {
        VStack{
            Image(Asset.ani.loading, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                .rotationEffect(.degrees(self.progress * 2.0 ) )
                .colorMultiply(self.progress > self.progressMax ? Color.app.white : Color.app.black40)
            if text != nil {
                Text(text!)
                .modifier(LightTextStyle(size: Font.size.light, color: Color.app.black40))
            }
        }
        .modifier(MatchHorizontal(height: 90, margin: 0))
        .opacity(self.progress / self.progressMax)
    }//body
}

#if DEBUG
struct ReflashSpinner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ReflashSpinner(progress: .constant(90))
                .environmentObject(PagePresenter())
        
                .frame(width: 375, height: 500, alignment: .center)
        }
    }
}
#endif

