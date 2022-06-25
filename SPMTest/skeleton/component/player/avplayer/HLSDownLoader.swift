//
//  DownLoader.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/08.
//

import Foundation
import AVKit
enum HLSDownLoaderEvent {
   case getPersistKey(Data, String)
}

class HLSDownLoader:NSObject, ObservableObject, PageProtocol,
                    AVAssetDownloadDelegate, Identifiable{
    
    
    let id:String = UUID().uuidString
    @Published private(set) var hlsEvent: HLSDownLoaderEvent? = nil {didSet{ if hlsEvent != nil { hlsEvent = nil} }}
    @Published private(set) var event: DownLoaderEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status: DownLoaderStatus = .ready
    @Published private(set) var progress:Double = 0
    
    private(set) var session:AVAssetDownloadTask? = nil
    private(set) var progressObserver:NSKeyValueObservation? = nil
    let keyProvider = AVContentKeyProvider()
    let paths = DownloadManager.directory
    private(set) var fileDir:String? = nil
    private(set) var isBackGround:Bool = false
    private(set) var keyCoreData:PersistContentKeyCoreDataManager? = nil
    private(set) var autoDownloadCoreDataManager:AutoDownloadCoreDataManager? = nil
    var fileName:String = "asset"
    var fileExtension = "movpkg"
    private(set) var keys:[String] = []
    convenience init(fileDir:String? = nil, isBackGround:Bool = false) {
        self.init()
        self.isBackGround = isBackGround
        self.fileDir = fileDir
    }
    convenience init(fileName:String, fileDir:String? = nil, isBackGround:Bool = false) {
        self.init()
        self.fileDir = fileDir
        self.fileName = fileName
        self.isBackGround = isBackGround
    }
    
    func reset(){
        self.removeAllFile()
        self.close()
        self.status = .ready
    }
    
    func close(){
        self.progressObserver = nil
        self.session?.cancel()
        self.session = nil
        
    }
    func licenseReady(){
        self.status = .progress
    }
    @discardableResult
    func start(path:String, ckcURL:String = "", licenseData:Data? = nil)->Bool{
        if self.isBackGround && self.keyCoreData == nil {
            self.keyCoreData = PersistContentKeyCoreDataManager()
            self.autoDownloadCoreDataManager = AutoDownloadCoreDataManager()
        }
        self.keys.removeAll()
        let configuration = URLSessionConfiguration.background(withIdentifier: self.id)
        let downloadSession = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: .main)
        
        self.close()
        guard let url = URL(string:path) else {
            DataLog.e(fileName + " targetUrl error", tag: self.tag)
            self.onError(err: AssetLoadError.url(reason: "targetUrl"))
            return false
        }
        
        if isExistFile() {
            DataLog.d(fileName + " is exist file", tag: self.tag)
            self.onError(err: AssetLoadError.url(reason: "is exist file"))
            return false
        }
    
        let asset = AVURLAsset(url: url)
        let drm = FairPlayDrm(ckcURL:ckcURL, certificateURL: ckcURL)
        drm.certificate = licenseData
        keyProvider.bind(asset: asset, drm: drm){ ckc, err, contentId in
            if let drmErr = err {
                self.onError(err: drmErr)
                return
            }
            guard let key = ckc else {
                self.stop()
                return
            }
            if self.isBackGround {
                self.keys.append(contentId)
                self.keyCoreData?.setData(contentId: contentId, data: key, fileId: self.fileName)
            } else {
                DispatchQueue.main.async {
                    self.hlsEvent = .getPersistKey(key, contentId)
                }
            }
            
        }
        
        let task = downloadSession.makeAssetDownloadTask(
            asset: asset,
            assetTitle: fileName,
            assetArtworkData: nil,options: nil)
    
        task?.resume()
        if !self.isBackGround {
            self.progressObserver = task?.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    self.progress = progress.fractionCompleted
                }
            }
        }
        self.session = task
        self.status = .pause
        self.resume()
        return true
    }
    
    @discardableResult
    func resume()->Bool{
        guard let session = self.session else {return false}
        if self.status != .pause {return false}
        session.resume()
        self.status = .progress
        return true
    }
    
    @discardableResult
    func pause()->Bool{
        guard let session = self.session else {return false}
        if self.status != .progress {return false}
        session.suspend()
        self.status = .pause
        return true
    }
    
    func stop(){
        self.status = .ready
        self.close()
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        // Do not move the asset from the download location
        DataLog.d("didFinishDownloadingTo " + location.absoluteString, tag: self.tag)
        let path = self.getFileFullPath()
        self.onDownloadComplete(url: location,  savedPath: path)
        //UserDefaults.standard.set(location.relativePath, forKey: "testVideoPath")
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let err = error else {return}
        self.onError(err: err)
    }

    
    private func onDownloadComplete(url:URL?, savedPath:URL){
        guard let fileURL = url else { return }
        do {
            try FileManager.default.moveItem(at: fileURL, to: savedPath)
            self.onCompleted(savedPath: savedPath)
        } catch {
            self.onError(err: error)
        }
    }
    private func onError(err:Error){
        DataLog.e(err.localizedDescription, tag: self.tag)
        self.removeAllFile()
        if !self.isBackGround {
            DispatchQueue.main.async {
                self.event = .error(err: err)
                self.status = .error
            }
        }
        self.close()
    }
    private func onCompleted(savedPath:URL){
        if self.status == .error {return}
        DataLog.d("completed " + savedPath.absoluteString, tag: self.tag)
        if !self.isBackGround {
            DispatchQueue.main.async {
                self.event = .complete(savedPath)
                self.status = .complete
            }
        } else {
            self.keyCoreData?.setData(fileId: fileName, contentIds: self.keys)
            self.autoDownloadCoreDataManager?.setData(contentId: fileName)
        }
        self.close()
    }
    
    
    func removeAllFile(){
        DispatchQueue.global(qos: .background).async {
            self.removeFile()
        }
    }
    func removeFile(){
        let filePath = self.getFileFullPath().path
        if FileManager.default.fileExists(atPath: filePath) {
            do {
               try FileManager.default.removeItem(atPath: filePath )
            }
            catch let error {
                DataLog.e(error.localizedDescription, tag: self.tag)
            }
        }
    }
    func isExistFile() ->Bool{
        let filePath = self.getFileFullPath().path
        return FileManager.default.fileExists(atPath: filePath )
    }
    func getFile() -> Data?{
        let filePath = self.getFileFullPath().path
        if FileManager.default.fileExists(atPath: filePath ) {
            return FileManager.default.contents(atPath: filePath)
        } else {
            return nil
        }
    }
    
    func getFileFullPath() -> URL {
        if let dir = self.fileDir {
            return URL(fileURLWithPath: self.paths[0])
                .appendingPathComponent(dir)
                .appendingPathComponent(fileName).appendingPathExtension(self.fileExtension)
        }
        return URL(fileURLWithPath: self.paths[0]).appendingPathComponent(fileName).appendingPathExtension(self.fileExtension)
    }
    
    
    func getCertificateData(license:String, completed: @escaping (Data?) -> Void)  {
        DataLog.d("getCertificateData", tag: self.tag)
        guard let url = URL(string:license) else {
            let drmError:DRMError = .certificate(reason: "certificateData url error")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            completed(nil)
            return
        }
        var certificateRequest = URLRequest(url: url)
        certificateRequest.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with:certificateRequest) {
            [weak self] (data, response, error) in
            if let self = self {
                guard let data = data else
                {
                    let reason = error == nil ? "no certificateData" : error!.localizedDescription
                    let drmError:DRMError = .certificate(reason: reason)
                    DataLog.e(drmError.getDescription(), tag: self.tag)
                    DispatchQueue.main.async {
                        completed(nil)
                    }
                    return
                }
                let str = String(decoding: data, as: UTF8.self)
                DataLog.d("certificate success" + str , tag: self.tag)
                DispatchQueue.main.async {
                    completed(data)
                }
            }
        }
        task.resume()
    }
    
}
