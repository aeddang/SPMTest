//
//  Log.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import os.log

protocol Log {
    static var tag:String { get }
    static var lv:Int { get }
}
struct LogManager  {
    static var isLaunchTrace = false
    static fileprivate(set) var memoryLog:String = ""
    static fileprivate(set) var traceLog:String = ""
    static var isMemory = Self.isLaunchTrace
    {
        didSet{
            if !isMemory {
                Self.memoryLog = ""
            }
        }
    }
}

extension Log {
    static func log(_ message: String, tag:String? = nil , log: OSLog = .default, type: OSLogType = .default) {
        let t = (tag == nil) ? Self.tag : Self.tag + " -> " + tag!
        os_log("%@ %@", log: log, type: type, t, message)
        
    }
    
    static func t(_ message: String, tag:String? = nil) {
        if LogManager.isMemory {
            LogManager.traceLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
    }
    static func i(_ message: String, tag:String? = nil, lv:Int = 1) {
        if Self.lv < lv {return}
        Self.log(message, tag:tag, log:.default, type:.info )
    }
    
    static func d(_ message: String, tag:String? = nil, lv:Int = 2) {
        if Self.lv < lv {return}
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        #if DEBUG
        Self.log(message, tag:tag, log:.default, type:.debug )
        #endif
    }
    
    static func e(_ message: String, tag:String? = nil, lv:Int = 1) {
        if Self.lv < lv {return}
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        Self.log(message, tag:tag, log:.default, type:.error )
    }
}
struct PageLog:Log {
    static var tag: String = "Page"
    static var lv: Int = 1
}

struct ComponentLog:Log {
    static var tag: String = "Component"
    static var lv: Int = 1
}

struct DataLog:Log {
    static var tag: String = "Data"
    static var lv: Int = 1
}
