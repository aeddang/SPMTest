//
//  DownloadTaskProvider.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/15.
//

import Foundation

class DownLoadTaskProvider : ObservableObject {
      
    @Published private(set) var request:DownLoadQ? = nil
        {didSet{ if request != nil { request = nil} }}
    @Published var event:DownLoadTaskEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    
    @Published var downLoadEvent:DownLoadEvent? = nil
        {didSet{ if downLoadEvent != nil { downLoadEvent = nil} }}
    
    private(set) var tasks:[String:HLSDownLoader] = [:]
    private let recoveryLoader = HLSDownLoader()
    private(set) var loadedFiles:[String:HLSFile] = [:]
    
    let processCoreData = DownLoadProcessCoreDataManager()
    let keyCoreData = PersistContentKeyCoreDataManager()
    let assetResourceLoader = CustomAssetResourceLoader()
    // for ui
    func recovery(){
        let recoveryTask = self.processCoreData.getAllDatas()
        if recoveryTask.isEmpty {return}
        self.recoveryLoader.getCertificateData(license: recoveryTask.first?.ckcURL ?? ""){ key in
            if key == nil {
                self.event = .recoveryFail
            } else {
                recoveryTask.forEach{ q in
                    var licenseQ = q
                    licenseQ.licenseKey = key
                    self.request(q:licenseQ)
                }
            }
        }
    }
    func getDownLoadTaskStatus(id:String) -> DownLoadTaskStatus {
        if loadedFiles[id] != nil {return .loaded}
        if let task = tasks[id] {
            return .loading(task.status)
        }
        return .none
    }
    
    func getCertificateData(ckcURL:String, completed: @escaping (Data?) -> Void){
        self.recoveryLoader.getCertificateData(license: ckcURL, completed:completed)
    }
    func getAssetInfo(path:String, completed: @escaping (AssetPlayerInfo?) -> Void){
        self.assetResourceLoader.handleManifast(nil, path: path, completed: completed)
    }
    
    func request(q:DownLoadQ){
        switch q.type {
        case .clear :
            self.clearTask(id: q.fildID)
            self.event = .remove(id: q.fildID)
        default :
            self.request = q
        }
    }
    
    // only repository ui호출 금지
    func addAllLoadedFiles(_ files:[HLSFile]){
        files.forEach{ file in
            self.loadedFiles[file.id] = file
            self.downLoadEvent = .add(id: file.id, file)
        }
    }
    
    func removeLoadedFile(_ file:HLSFile){
        self.loadedFiles.removeValue(forKey: file.id)
    }
    
    func addTask(_ task:HLSDownLoader, q:DownLoadQ){
        let id = task.fileName
        if tasks[id] != nil {
            self.event = .existTask(id:id)
            return
        }
        if loadedFiles[id] != nil {
            self.event = .existFile(id:id)
            return
        }
        if !q.isAuto {
            processCoreData.setData(q:q)
        }
        tasks[id] = task
        self.event = .add(id:id, task, q)
    }
    
    func removeTask(id:String){
        self.clearTask(id: id)
        self.event = .remove(id: id)
        self.loadedFiles.removeValue(forKey: id)
        self.downLoadEvent = .remove(id: id)
    }
    
    func completedTask(id:String, path:String, file:HLSFile?){
        self.clearTask(id: id)
        self.event = .complete(id:id, path:path)
        
        if let file = file {
            self.loadedFiles[id] = file
            self.downLoadEvent = .add(id: id, file)
        }
    }
    func errorTask(id:String, err:Error){
        self.event = .error(id: id, err: err)
    }
    
    private func clearTask(id:String){
        if let remove = tasks.removeValue(forKey: id) {
            processCoreData.deleteData(contentId: remove.fileName)
        }
    }
    
}

struct DownLoadQ :Identifiable, Equatable{
    var id:String = UUID().uuidString
    var type:DownLoadQType = .load
    var fildID:String
    var path:String = ""
    var ckcURL:String = ""
    var isStart:Bool = true
    var isAuto:Bool = false
    var licenseKey:Data? = nil
    public static func == (l:DownLoadQ, r:DownLoadQ)-> Bool {
        return l.fildID == r.fildID
    }
}
enum DownLoadQType {
    case load,
         delete, // 완전삭제 (파일 + DB)
         clear //테스크에서만 삭제(파일+DB는 남아있음)
}

enum DownLoadTaskEvent {
    case add(id:String, HLSDownLoader, DownLoadQ), remove(id:String), existTask(id:String), existFile(id:String), recoveryFail
    case complete(id:String, path:String), error(id:String, err:Error), start(id:String, fileSize:Double)
}
enum DownLoadEvent {
    case add(id:String, HLSFile), remove(id:String)
}

enum DownLoadTaskStatus {
    case none , loaded, loading(DownLoaderStatus)
}
