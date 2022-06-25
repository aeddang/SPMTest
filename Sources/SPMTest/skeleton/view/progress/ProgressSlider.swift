//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ProgressSlider: PageView {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var progress: Float // or some value binded
    var useGesture:Bool = true
    var progressHeight:CGFloat = Dimen.bar.light
    var thumbSize:CGFloat = 0
    var color:Color = Color.brand.primary
    var radius:CGFloat = Dimen.radius.migro
    var onChange: ((Float) -> Void)? = nil
    var onChanged: ((Float) -> Void)? = nil
    
    @State var dragOpacity:Double = 0.0
    @State var drag: Float = 0.0
    @State var isThumbDrag: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.app.white)
                        .frame(
                            width: geometry.size.width,
                            height: progressHeight
                        )
                        .opacity(0.15)
                    
                    Rectangle()
                        .foregroundColor(self.color)
                        .frame(
                            width: geometry.size.width * CGFloat(min(1,max(self.progress,0))),
                            height: progressHeight
                        )
                    Rectangle()
                        .foregroundColor(Color.app.white)
                        .opacity(self.dragOpacity)
                        .frame(
                            width: geometry.size.width * CGFloat(self.drag),
                            height: progressHeight)
                }
                .clipShape(RoundedRectangle(cornerRadius: self.radius))
                if self.thumbSize > 0 {
                    Circle()
                        .foregroundColor(Color.brand.primary)
                        .frame(width: self.thumbSize, height: self.thumbSize)
                        .offset( x: self.getThumbPosition(geometry:geometry) )
                        
                }
            }
            .modifier(MatchParent())
            .background(Color.transparent.clearUi)
            .highPriorityGesture(DragGesture(minimumDistance: 20)
                .onChanged({ value in
                    if !useGesture { return }
                    self.isThumbDrag = true
                    let d = min(max(0, Float(value.location.x / geometry.size.width)), 1)
                    self.drag = d
                    self.dragOpacity = 0.3
                    if let change = self.onChange {
                        change(self.drag)
                    }
                })
                .onEnded({ value in
                    if !useGesture { return }
                    self.onProgressCompleted()
                }))
        }
        .onReceive(pageObservable.$status){ status in
            switch status {
            case .resignActive :
                if self.isThumbDrag {
                    onProgressCompleted()
                }
            default : break
            }
            
        }
    }
    
    private func onProgressCompleted(){
        self.isThumbDrag = false
        if let changed = self.onChanged {
            changed(self.drag)
        }
        self.dragOpacity = 0.0
    }
    
    func getThumbPosition(geometry:GeometryProxy)->CGFloat{
        if self.isThumbDrag {
            return geometry.size.width * CGFloat(self.drag) - (self.thumbSize/2)
        }
        var pos = geometry.size.width * CGFloat(self.progress)
        pos = min(geometry.size.width-self.thumbSize, pos)
        return pos
    }
}
#if DEBUG
struct ProgressSlider_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ProgressSlider(
                progress:  0.5,
                thumbSize: 10
            )
            .frame(width: 375, alignment: .center)
        }
    }
}
#endif
