//
//  SocialMediaSharingManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Social
import UIKit
import LinkPresentation

struct SocialMediaShareable {
    let id = UUID.init().uuidString
    var image:UIImage?
    var url:URL?
    var title:String?
    var text:String?
    var linkText:String?
}

extension SocialMediaSharingManage {
    static let sharinglink = "/sharinglink"
    static let familyInvite = "/view/v3.0/applink?type=family_invite"
    static let event = "/view/v3.0/applink?type=event_url"
    
}

struct SocialMediaSharingManage{
    
    static func share(_ object: SocialMediaShareable, for serviceType: String) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object,for: serviceType, from: vc)
    }
    
    static func share(_ object: SocialMediaShareable, for serviceType: String, from presentingVC: UIViewController) {
        if let composeVC = SLComposeViewController(forServiceType:serviceType) {
            composeVC.add(object.image)
            composeVC.add(object.url)
            composeVC.setInitialText(object.text)
            presentingVC.present(composeVC, animated: true, completion: nil)
        }
    }
    
    static func share(_ object: SocialMediaShareable, completion: ((Bool) -> Void)? = nil) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object, from: vc, completion:completion)
    }
    
    static func share(_ object: SocialMediaShareable, from presentingVC: UIViewController, completion: ((Bool) -> Void)? = nil ) {
        var sharedObjects: [AnyObject] = []
        if let img = object.image { sharedObjects.append(img) }
        if let txt = object.title , let url = object.url{
            sharedObjects.append(
                ShareActivityItemSource(url: url, icon: object.image, title: txt, isUrl:false)
            )
        }
        if let txt = object.text , let url = object.url{
            sharedObjects.append(
                ShareActivityItemSource(url: url, title: txt, isUrl:false)
            )
        }
        if let url = object.url {
            sharedObjects.append(
                ShareActivityItemSource(url: url, icon: nil,
                                        isUrl: true ,
                                        linkText: object.linkText)
            )
        }
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = presentingVC.view
        
        activityViewController.popoverPresentationController?.sourceRect = CGRect(
            x: presentingVC.view.bounds.width / 2,
            y: presentingVC.view.bounds.height / 2, width: 0, height: 0)
        activityViewController.excludedActivityTypes =  [ UIActivity.ActivityType.airDrop]
        presentingVC.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { (type, completed, items, error) in
            if completed && error == nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
        
    }
}


class ShareActivityItemSource: NSObject, UIActivityItemSource {
    
    private let url: URL
    private let icon: UIImage?
    private let title: String
    private let isUrl: Bool
    private let linkText: String?
    
    init(url: URL, icon: UIImage? = nil, title: String? = nil, isUrl: Bool = true,  linkText: String? = nil) {
        self.url = url
        self.icon = icon
        self.title = title ?? ""
        self.isUrl = isUrl
        self.linkText = linkText
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return isUrl ? url : title
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if linkText?.isEmpty == false { return linkText }
        if isUrl {
            return self.title + "\n" + self.url.absoluteString
        } else {
            return self.title
        }
        /*
        if activityType == .message {
            if isUrl {
                return self.title + "\n" + self.url.absoluteString
            } else {
                return self.title
            }
        }
        return isUrl ? self.url : self.title*/
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        if isUrl {
            return nil
        } else {
            let metadata = LPLinkMetadata()
            let shareIcon = icon ?? UIImage(named: "AppIcon") ?? UIImage()
            metadata.iconProvider = NSItemProvider(object: shareIcon )
            metadata.title = title
            metadata.url = url
            metadata.originalURL = url
            return metadata
        }
    }
}
