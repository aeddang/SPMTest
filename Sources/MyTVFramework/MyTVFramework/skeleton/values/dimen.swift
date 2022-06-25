//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct Dimen{
    private static let isPad =  AppUtil.isPad()
    struct margin {
        public static let heavy:CGFloat = 50// not define
        public static let medium:CGFloat = 32
        public static let mediumExtra:CGFloat = 25
        public static let regular:CGFloat = 20
        public static let regularExtra:CGFloat = 18
        public static let light:CGFloat = 14
        public static let lightExtra:CGFloat = 13
        public static let thin:CGFloat = 12
        public static let thinExtra:CGFloat = 10
        public static let tiny:CGFloat = 8
        public static let tinyExtra:CGFloat = 6
        public static let micro:CGFloat = 2
    }

    struct icon {
        public static let heavy:CGFloat = 60
        public static let medium:CGFloat =  41
        public static let regular:CGFloat = 36
        public static let light:CGFloat = 28
        public static let thin:CGFloat = 24
        public static let thinExtra:CGFloat = 22
        public static let tiny:CGFloat = 20
        public static let tinyExtra:CGFloat = 17
        public static let micro:CGFloat = 12// not define
    }
    
    struct tab {
        public static let heavy:CGFloat = 104
        public static let medium:CGFloat = 90
        public static let regular:CGFloat = 70
        public static let light:CGFloat = 36// not define
        public static let thin:CGFloat = 18// not define
    }
    
    struct button {
        public static let heavy:CGFloat =  80// not define
        public static let medium:CGFloat = 50// not define
        public static let regular:CGFloat = 48
        public static let light:CGFloat = 40
        public static let thin:CGFloat = 22
        
        public static let heavyRect:CGSize = CGSize(width: 90, height: 42)// not define
        public static let mediumRect:CGSize = CGSize(width: 132, height: 40)
        public static let regularRect:CGSize = CGSize(width: 48, height: 26)// not define
        public static let lightRect:CGSize = CGSize(width: 38, height: 20)// not define
    }

    struct radius {
        public static let heavyUltra:CGFloat = 27
        public static let heavy:CGFloat = 20
        public static let medium:CGFloat = 12
        public static let regular:CGFloat = 10
        public static let light:CGFloat = 8
        public static let migro:CGFloat = 2
    }
    
    struct bar {
        public static let medium:CGFloat = 21
        public static let regular:CGFloat = 15// not define
        public static let light:CGFloat = 4
    }
    
    struct line {
        public static let heavy:CGFloat = 4// not define
        public static let medium:CGFloat = 3// not define
        public static let regular:CGFloat = 2// not define
        public static let light:CGFloat = 1// not define
    }
    
    struct stroke {
        public static let heavy:CGFloat = 5// not define
        public static let medium:CGFloat = 3// not define
        public static let regular:CGFloat = 2// not define
        public static let light:CGFloat = 1// not define
    }
    
    struct app {
        public static let bottom:CGFloat = 60 // not define
        public static let top:CGFloat = 80 // not define
        public static let keyboard:CGFloat = isPad ? 400 : 300
    }
    
    struct item {
        static let character:CGSize = CGSize(width: 80, height: 80)
        static let bigImage:CGFloat = 480 // not define
        static let middleImage:CGFloat = 240 // not define
        static let smallImage:CGFloat = 120 // not define
    }
    
    
}

