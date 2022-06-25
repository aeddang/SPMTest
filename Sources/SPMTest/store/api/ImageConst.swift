//
//  ImageConst.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//

import Foundation
import SwiftUI

class ImageSet{
    private(set) var logo:String? = nil
    private(set) var logoMini:String? = nil
    private(set) var still:String? = nil
    private(set) var thumb:String? = nil
    private(set) var hero:String? = nil
    
    var image:String? {
        get{
            return self.still ?? self.thumb
        }
    }
    
    func setData(datas:[ImageTypeItem]?, csvId:String? = nil)->ImageSet?{
        guard let datas = datas else {return nil}
        var isExist = false
        datas.forEach{ data in
            let key = data.type?.uppercased() ?? ""
            if let path = data.url {
                if (key.contains("LOGO_MINI") == true) {
                    isExist = true
                    self.logoMini = ImagePath.imagePath(filePath: path, size: CGSize(width: Dimen.item.smallImage,height: 0))
                } else if (key.contains("LOGO") == true) {
                    isExist = true
                    self.logo = ImagePath.imagePath(filePath: path, size: CGSize(width: Dimen.item.middleImage,height: 0))
                } else if (key.contains("STILL") == true) {
                    isExist = true
                    self.still = ImagePath.replaceResizingPathInImageUrl(
                        origin: path.replace("#SEARCH_SECONDS#", with: "300"),
                        prePathOfResizePath: "des/",
                        size: CGSize(width: Dimen.item.bigImage,height: 0), csvId: csvId
                    )
                       
                } else if (key.contains("THUMB") == true) {
                    isExist = true
                    self.thumb = ImagePath.imagePath(filePath: path, size: CGSize(width: Dimen.item.middleImage,height: 0))
                } else if (key.contains("HERO") == true) {
                    isExist = true
                    self.hero = ImagePath.imagePath(filePath: path, size: CGSize(width: Dimen.item.middleImage,height: 0))
                }
            }
        }
        return isExist ? self : nil
    }
    
    func setData(thumb:String? = nil, size:CGFloat =  Dimen.item.bigImage)->ImageSet?{
        guard let path = thumb else {return nil}
        self.thumb = ImagePath.thumbImagePath( filePath: path, size: CGSize(width: size,height: 0))
        return self
    }
    func setData(still:String? = nil, thumb:String? = nil, size:CGFloat =  Dimen.item.bigImage)->ImageSet?{
        var path = still ?? thumb ?? ""
        if path.isEmpty { path = thumb ?? "" }
        self.still = ImagePath.thumbImagePath( filePath: path, size: CGSize(width: size,height: 0))
        return self
    }
}


struct ImagePath {
    static func imagePath(
        filePath: String?,
        size: CGSize = CGSize(width: 0,height: 0),
        convType: IIPConvertType = .none,
        locType: IIPLocType = .none,
        server:ApiServer = .IIP) -> String?{
        if filePath == nil || filePath == "" {return nil}
        if filePath!.contains("http") {return filePath}
        let cType = convType
        let path = ApiPath.getRestApiPath(server) + "/"
        return getIIPUrl(path: path, filePath: filePath ?? "", size: size, convType: cType, locType: locType)
    }
    
    static func thumbImagePath(
        filePath: String?,
        size: CGSize = CGSize(width: 0,height: 0),
        convType: IIPConvertType = .none,
        locType: IIPLocType = .none,
        server:ApiServer = .IIP) -> String? {
        
        if filePath == nil || filePath == "" {return nil}
        if filePath!.contains("http") {return filePath}
        let path = ApiPath.getRestApiPath(server)
        let apiPath = "/thumbnails/iip/"
        let cType = convType
        return getIIPUrl(path: path + apiPath, filePath: filePath ?? "", size: size, convType: cType, locType: locType)
    }

    static func getIIPUrl(path:String, filePath: String, size: CGSize, convType: IIPConvertType = .none, locType: IIPLocType = .none) -> String {
        let scale:CGFloat = UIScreen.main.scale
        let width = min(1280, floor(size.width * scale))
        let height = min(1280, floor(size.height * scale))
        
        var str = ""
        switch convType {
        case .crop, .extension:
            str = "_\(convType.rawValue)"
            if locType != .none {
                let conv:Int = Int(convType.rawValue) ?? 0
                str = "_\(conv + locType.rawValue)"
            }
        case .alpha, .blur:
            str = "_\(convType.rawValue)"
        default:break
        }
        return ("\(path)\(Int(width))_\(Int(height))\(str)\(filePath)")
    }
    
    static func replaceResizingPathInImageUrl(origin: String, prePathOfResizePath: String, size: CGSize, csvId:String? = nil)-> String {
        let server = ApiPath.getRestApiPath(.IIP)
        let scale:CGFloat = UIScreen.main.scale
        let width:Int = Int(min(1280, floor(size.width * scale)))
        let height:Int = Int(min(1280, floor(size.height * scale)))
        let resolution = width.description + "_" + height.description
        if origin.contains("%s"){
            let paths = origin.components(separatedBy: "%s")
            if paths.count == 3 {
                return server + paths[0] + resolution + paths[1] + (csvId ?? "") + paths[2]
            }
            return ""
        } else {
            let paths = origin.components(separatedBy: prePathOfResizePath)
            if paths.count == 2 {
                let trail = paths[1]
                if let idx = trail.firstIndex(of: "/") {
                    return server + paths[0] + prePathOfResizePath + resolution + String(trail[idx...])
                }
            }
            return ""
        }
    }
}

enum IIPConvertType: String {
    case none = "0"
    case crop = "20"
    case `extension` = "30"
    case alpha = "A20"
    case blur = "B20"
}

enum IIPLocType: Int {
    case none = -1
    case center = 0
    case top = 1
    case bottom = 2
    case left = 4
    case right = 8
}
