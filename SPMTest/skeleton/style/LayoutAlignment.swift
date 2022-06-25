//
//  LayoutAli.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


struct LayoutTop: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:-pos + margin)
    }
}

struct LayoutBotttom: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:pos - margin)
    }
}

struct LayoutLeft: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) - margin
        return content
            .frame(width:width)
            .offset(x:-pos)
    }
}

struct LayoutRight: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) + margin
        return content
            .frame(width:width)
            .offset(x:pos)
    }
}

struct LayoutCenter: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct MatchParent: ViewModifier {
    var marginX:CGFloat = 0
    var marginY:CGFloat = 0
    var margin:CGFloat? = nil
    func body(content: Content) -> some View {
        let mx = margin == nil ? marginX : margin!
        let my = margin == nil ? marginY : margin!
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (mx * 2.0), minHeight:0, maxHeight: .infinity - (my * 2.0))
            .offset(x:mx, y:my)
    }
}
struct MatchHorizontal: ViewModifier {
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
    }
}

struct MatchVertical: ViewModifier {
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
    }
}

struct LineHorizontal: ViewModifier {
    var height:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    var color:Color = Color.app.white
    var opacity:Double = 0.1
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
            .background(self.color).opacity(self.opacity)
            
            
    }
}
struct LineVertical: ViewModifier {
    var width:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    var color:Color = Color.app.white
    var opacity:Double = 0.1
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
            .background(self.color).opacity(self.opacity)
            
            
    }
}

struct LineVerticalDotted: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y:rect.height))
        return path
    }
}


struct ListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginHorizontal:CGFloat = 0
    var spacing:CGFloat = Dimen.margin.thin
    var marginTop:CGFloat = 0
     
    func body(content: Content) -> some View {
        return content
            .padding(
                .init(
                    top: (index == firstIndex) ? marginTop : 0,
                    leading:  marginHorizontal,
                    bottom: spacing,
                    trailing: marginHorizontal)
            )
            .listRowInsets(
                .init(
                    )
            )
        
    }
}

struct HolizentalListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginVertical:CGFloat = 0
    var spacing:CGFloat = Dimen.margin.thin
    var marginTop:CGFloat = 0
    var bgColor:Color = Color.brand.bg
    
    func body(content: Content) -> some View {
        return content
            .padding(
                EdgeInsets(
                    top: marginVertical,
                    leading:  (index == firstIndex) ? marginTop : 0,
                    bottom: marginVertical,
                    trailing: spacing)
            )
            .listRowInsets(
                EdgeInsets(
                    top: 0, leading: 0, bottom: 0, trailing: 0
                )
            )
        
    }
}

struct BottomFunctionTab: ViewModifier {
    var margin:CGFloat = Dimen.margin.regular
    var bgColor:Color = Color.app.darkBlue100
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, Dimen.margin.mediumExtra)
            .padding(.horizontal, margin)
            .background(bgColor)
            .mask(
                ZStack(alignment: .bottom){
                    RoundedRectangle(cornerRadius: Dimen.radius.medium)
                    Rectangle().modifier(MatchHorizontal(height: Dimen.radius.medium))
                }
            )
    }
}
