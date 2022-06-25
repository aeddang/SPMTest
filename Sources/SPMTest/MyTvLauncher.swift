//
//  MyTvLuncher.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/23.
//

import Foundation
public enum LauncherEvent {
    case updated, updatedLogLv(MyTvAppLogLv)
}
public enum LauncherRequest {
    case moveChannel(channelId:String), moveProgram(channelId:String, programId:String)
}
public enum MyTvAppStatus {
    case initate
}

public enum MyTvAppLogLv {
    case none, info, debug, all
    var lv: Int {
        switch self {
        case .all: return 9999
        case .none: return 0
        case .debug: return 2
        case .info: return 1
        }
    }
}

public protocol MyTvLauncherProtocol {
    var id:String? { get }
    var token:String? { get }
    var logLv:MyTvAppLogLv? { get }
    var event:LauncherEvent? { get }
    var request:LauncherRequest? { get }
    var status:MyTvAppStatus? { get }
    
    func initBackgroundDownLoadTask()
    func requestCaptureImages(completed:(String) -> Void)
    func requestUserInfo(completed:(String) -> Void)
    func requestLog(json:String)
    func requestAdultCertification(json:String, completed:(String) -> Void)
    func close()
}

open class MyTvLauncherObservable : MyTvLauncherProtocol, ObservableObject{
    public var id: String? = nil
    public var token: String? = nil  
    public var logLv: MyTvAppLogLv? = nil
    @Published public var event: LauncherEvent? = nil
    @Published public var request: LauncherRequest? = nil
    @Published public var status: MyTvAppStatus? = nil
    
    public init() {}
    public func initBackgroundDownLoadTask(){ MyTvBackgroundDownLoadTask().setup() }
    open func requestCaptureImages(completed: (String) -> Void) {}
    open func requestUserInfo(completed: (String) -> Void) {}
    open func requestLog(json: String) {}
    open func requestAdultCertification(json: String, completed: (String) -> Void) {}
    open func close() {}
}
