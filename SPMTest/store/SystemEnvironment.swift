//
//  SystemEnvironment.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation
import UIKit
import CoreTelephony
import BackgroundTasks

struct SystemEnvironment {
    static let model:String = AppUtil.model
    static let systemVersion:String = UIDevice.current.systemVersion
    static let bundleVersion:String = AppUtil.version
    static let bundleId:String = "com.skb.apollo.MyTVFramework"
    static let buildNumber:String = AppUtil.build
    static var firstLaunch :Bool = false
    static var isTablet = AppUtil.isPad()
    static var isStage:Bool = true
    static var isWideScreen = AppUtil.isWideScreen()
    static var apolloId:String? = nil
    static var apolloToken:String? = nil
    static var contentKeyExfireTime:Double = 90 * 24 * 60 * 60
    static var epgUpdateTime:Double = 1 * 60 * 60
    static var deviceId:String {
        get{
            if let id = apolloId {return id}
            return getDeviceId()
        }
    }
    private static func getDeviceId() -> String{
        let newId = "IA" + (UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString)
        return newId
    }
    
    static var serverConfig: [String:String] = [String:String]()
    
}



