//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ControlBar: PageView {
    var color:Color = Color.app.white
    var progress: Float //
    @State var drag: Float = 0
    @State var dragGestureFire:Int = 0
    let onChange: (Float) -> Void
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(Color.app.white)
                        .modifier(MatchParent())
                        .opacity(0.5)
                    
                    Rectangle()
                        .foregroundColor(self.color)
                        .modifier(
                            MatchHorizontal(
                                height: geometry.size.height * CGFloat(
                                    min(1,max(self.progress,0))
                                )
                            )
                        )
                }
                .modifier(MatchVertical(width: Dimen.bar.light))
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.migro))
            }
            .modifier(MatchParent())
            .background(Color.transparent.clearUi)
            .highPriorityGesture(DragGesture(minimumDistance: 20)
                .onChanged({ value in
                    let d = 1 - min(max(0, Float(value.location.y / geometry.size.height)), 1)
                    self.drag = d
                    self.dragGestureFire += 1
                    if self.dragGestureFire%3 != 1 {return}
                    self.onChange(d)
                })
                .onEnded({ value in
                    self.dragGestureFire = 0
                })
            )
        }
    }
}

