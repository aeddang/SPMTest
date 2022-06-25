//
//  DownLoadManager.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/12.
//

import Foundation
import Combine

class HLSFile:Identifiable{
    let id: String
    var filePath: String = ""
    var persistKeys: [(String, Data, Date)] = []
    var isExfire:Bool = false
    var isAuto:Bool = false
    var meta:ContentCoreData? = nil
    init(
        id: String,
        filePath: String = "",
        persistKeys: [(String, Data, Date)] = [],
        isExfire:Bool = false,
        isAuto:Bool = false,
        meta:ContentCoreData? = nil
    ){
        self.id = id
        self.filePath = filePath
        self.persistKeys = persistKeys
        self.isExfire = isExfire
        self.isAuto = isAuto
        self.meta = meta
    }
}

class DownloadManager : PageProtocol{
    
    let keyCoreData = PersistContentKeyCoreDataManager()
    let contentCoreData = ContentCoreDataManager()
    let autoDownloadCoreDataManager = AutoDownloadCoreDataManager()
    static let directory = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    private(set) var fileDir:String? = nil
    private(set) lazy var filePathProvider:HLSDownLoader = HLSDownLoader(fileDir: self.fileDir)
    private var anyCancellable = Set<AnyCancellable>()
    private var autoDownLoadFiles:[String] = []
    convenience init(fileDir:String? = nil) {
        self.init()
        self.fileDir = fileDir
        self.autoDownLoadFiles = self.autoDownloadCoreDataManager.getAllDatas()
    }
    
    @discardableResult
    func download(id:String,
                  path:String, ckcURL:String , licenseData:Data? = nil,
                  isStart:Bool = true,
                  isBackGround:Bool = false,
                  completed: ((String?, Error?) -> Void)? = nil) -> HLSDownLoader
    {
        let downLoader = HLSDownLoader(fileName: id, fileDir: self.fileDir, isBackGround: isBackGround)
        var keys:[String] = []
        downLoader.$hlsEvent.sink(receiveValue: { evt in
            switch evt {
            case .getPersistKey(let ckcData, let contentId) :
                keys.append(contentId)
                self.keyCoreData.setData(contentId: contentId, data: ckcData, fileId: id)

            default : break
            }
        }).store(in: &anyCancellable)
          
        downLoader.$event.sink(receiveValue: { evt in
            switch evt {
            case .complete(let path) :
                self.keyCoreData.setData(fileId: id, contentIds: keys)
                completed?(path.path, nil)
            case .error(let err) :
                completed?(nil,err)
                
            default : break
            }
        }).store(in: &anyCancellable)
        if isStart {
            if licenseData == nil {
                downLoader.licenseReady()
                downLoader.getCertificateData(license: ckcURL){ cert in
                    downLoader.start(path: path, ckcURL: ckcURL, licenseData: cert)
                }
            } else {
                downLoader.start(path: path, ckcURL: ckcURL, licenseData: licenseData)
            }
        }
        return downLoader
        
    }
    
    @discardableResult
    func deleteFile(id:String)->Bool{
        self.filePathProvider.fileName = id
        self.filePathProvider.removeAllFile()
        guard let data = self.keyCoreData.getData(fileId: id) else {return false}
        self.keyCoreData.deleteData(fileId: id)
        self.contentCoreData.deleteData(contentId: id)
        data.0.forEach{
            self.keyCoreData.deleteData(contentId: $0, fileId: id)
        }
        return true
    }
    
    func getFile(id:String)->HLSFile?{
        guard let data = self.keyCoreData.getData(fileId: id) else {return nil}
        let now = AppUtil.networkTimeDate()
        let keys = data.0
        let createDate = data.1
        let keepTime:Double = createDate.timeIntervalSince1970 - now.timeIntervalSince1970
        self.filePathProvider.fileName = id
        let meta = self.contentCoreData.getData(contentId: id)
        if keepTime >= ( SystemEnvironment.contentKeyExfireTime ) {
            self.keyCoreData.deleteData(fileId: id)
            self.contentCoreData.deleteData(contentId: id)
            self.filePathProvider.removeAllFile()
            keys.forEach{
                self.keyCoreData.deleteData(contentId: $0, fileId: id)
            }
            DataLog.d(id + "expire content", tag: self.tag)
            return HLSFile(id:id, isExfire: true, meta: meta)
        } else {
            var persistKeys:[(String,Data,Date)] = []
            keys.forEach{
                if let key = self.keyCoreData.getData(contentId: $0, fileId: id) {
                    persistKeys.append(key)
                }
            }
            let isAuto = self.autoDownLoadFiles.first(where: {$0 == id}) != nil
            return HLSFile(id:id,
                           filePath:self.filePathProvider.getFileFullPath().path,
                           persistKeys:persistKeys,
                           isAuto:isAuto,
                           meta: meta)
        }
       
    }
    
    func getAllFiles()->[HLSFile]{
        let dir = Self.directory[0] + (fileDir ?? "")
        let paths = try? FileManager.default.contentsOfDirectory(atPath: dir)
        guard let existFiles = paths else {return []}
        let now = AppUtil.networkTimeDate()
        return existFiles.filter{$0.hasSuffix("movpkg")}.map{ path in
            let url = URL(fileURLWithPath: path)
            let id = url.deletingPathExtension().lastPathComponent
            let meta = self.contentCoreData.getData(contentId: id)
            var persistKeys:[(String,Data,Date)] = []
            if let keys = self.keyCoreData.getData(fileId: id) {
                let createDate = keys.1
                let keepTime:Double = createDate.timeIntervalSince1970 - now.timeIntervalSince1970
                if keepTime >= ( SystemEnvironment.contentKeyExfireTime ) {
                    self.filePathProvider.fileName = id
                    self.filePathProvider.removeAllFile()
                    self.contentCoreData.deleteData(contentId: id)
                    self.keyCoreData.deleteData(fileId: id)
                    keys.0.forEach{
                        self.keyCoreData.deleteData(contentId: $0, fileId: id)
                    }
                    DataLog.d(id + "expire content", tag: self.tag)
                    
                } else {
                    keys.0.forEach{
                        if let key = self.keyCoreData.getData(contentId: $0, fileId: id) {
                            persistKeys.append(key)
                        }
                    }
                }
            }
            if persistKeys.isEmpty { return HLSFile(id:id, isExfire: true, meta: meta) }
            return HLSFile(id:id, filePath:dir + "/" + path, persistKeys:persistKeys, meta: meta)
        }
    }
   
    func updatedKey(id:String, contentId:String, key:Data? = nil ){
        self.keyCoreData.deleteData(contentId: contentId, fileId: id)
        guard let newKey = key else {return}
        self.keyCoreData.setData(contentId: contentId, data: newKey, fileId: id)
    }
    
    func getPersistKeys(id:String)->[(String,Data,Date)]{
        var persistKeys:[(String,Data,Date)] = []
        let now = AppUtil.networkTimeDate()
        if let keys = self.keyCoreData.getData(fileId: id) {
            let createDate = keys.1
            let keepTime:Double = createDate.timeIntervalSince1970 - now.timeIntervalSince1970
            if keepTime < ( SystemEnvironment.contentKeyExfireTime ) {
                keys.0.forEach{
                    if let key = self.keyCoreData.getData(contentId: $0, fileId: id) {
                        persistKeys.append(key)
                    }
                }
            }
        }
        return persistKeys
    }
}
