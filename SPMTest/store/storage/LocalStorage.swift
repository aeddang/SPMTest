//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class LocalStorage {
    struct Keys {
        static let VS = "1.0"
        static let initate = "initate"
        static let deviceId = "initate"
    }
    let defaults = UserDefaults.standard
    
    
    var initate:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.initate)
        }
        get{
            return defaults.object(forKey: Keys.initate) == nil
        }
    }
   
}
