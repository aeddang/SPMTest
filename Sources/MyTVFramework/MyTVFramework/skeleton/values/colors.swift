//
//  colors.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension Color {
    init(rgb: Int) {
        let r = Double((rgb >> 16) & 0xFF)/255.0
        let g = Double((rgb >> 8) & 0xFF)/255.0
        let b = Double((rgb ) & 0xFF)/255.0
        self.init(
            red: r,
            green: g,
            blue: b
        )
    }
    
    struct brand {
        public static let primary = app.blue80
        public static let primaryLight = app.blue40
        public static let secondary = app.darkBlue100
        public static let accent =  app.blue100
        public static let bg = Color.black
        
    }
    struct bg {
        public static let subBg = Color.init(red: 244/255, green: 246/255, blue: 249/255)
        public static let scrim = Color.init(red: 212/255, green: 212/255, blue: 212/255)
    }
    
    struct app {
        public static let white =  Color.white
        public static let black = Color.init(red: 33/255, green: 33/255, blue: 33/255)
        public static let black80 = Color.init(red: 127/255, green: 127/255, blue: 127/255)
        public static let black40 = Color.init(red: 167/255, green: 167/255, blue: 167/255)
        
        public static let blue100 = Color.init(red: 0/255, green: 31/255, blue: 254/255)
        public static let blue80 = Color.init(red: 51/255, green: 76/255, blue: 255/255)
        public static let blue70 = Color.init(red: 76/255, green: 98/255, blue: 254/255)
        public static let blue60 = Color.init(red: 102/255, green: 121/255, blue: 255/255)
        public static let blue40 = Color.init(red: 153/255, green: 165/255, blue: 255/255)
        public static let blue15 = Color.init(red: 217/255, green: 222/255, blue: 255/255)
        public static let blue10 = Color.init(red: 229/255, green: 233/255, blue: 255/255)
        public static let blue05 = Color.init(red: 242/255, green: 244/255, blue: 255/255)
        public static let blue04 = Color.init(red: 245/255, green: 246/255, blue: 255/255)
        
        public static let darkBlue100 = Color.init(red: 9/255, green: 24/255, blue: 64/255)
        public static let darkBlue80 = Color.init(red: 59/255, green: 71/255, blue: 103/255)
        public static let darkBlue70 = Color.init(red: 83/255, green: 93/255, blue: 121/255)
        public static let darkBlue60 = Color.init(red: 118/255, green: 123/255, blue: 137/255)
        public static let darkBlue50 = Color.init(red: 129/255, green: 136/255, blue: 156/255)
        public static let darkBlue40 = Color.init(red: 157/255, green: 163/255, blue: 179/255)
        public static let darkBlue20 = Color.init(red: 206/255, green: 209/255, blue: 217/255)
        public static let darkBlue10 = Color.init(red: 231/255, green: 233/255, blue: 237/255)
        public static let darkBlue05 = Color.init(red: 244/255, green: 246/255, blue: 249/255)
        
         
        public static let yellow = Color.init(red: 254/255, green: 246/255, blue: 61/255)
        public static let red = Color.init(red: 244/255, green: 74/255, blue: 77/255)
        
        public static let stateBlue = Color.init(red: 0/255, green: 157/255, blue: 255/255)
        public static let stateGreen = Color.init(red: 0/255, green: 187/255, blue: 42/255)
        public static let stateOrange = Color.init(red: 238/255, green: 93/255, blue: 0/255)
        public static let stateRed = Color.init(red: 255/255, green: 58/255, blue: 0/255)
    }
    
    struct transparent {
        public static let clear = Color.black.opacity(0.0)
        public static let clearUi = Color.black.opacity(0.0001)
        public static let black80 = Color.black.opacity(0.8)
        public static let black70 = Color.black.opacity(0.7)
        public static let black50 = Color.black.opacity(0.5)
        public static let black45 = Color.black.opacity(0.45)
        public static let black15 = Color.black.opacity(0.15)
        
        public static let white70 = Color.white.opacity(0.7)
        public static let white50 = Color.white.opacity(0.5)
        public static let white45 = Color.white.opacity(0.45)
        public static let white20 = Color.white.opacity(0.20) 
        public static let white15 = Color.white.opacity(0.15)
        public static let white10 = Color.white.opacity(0.10)
    }
}


