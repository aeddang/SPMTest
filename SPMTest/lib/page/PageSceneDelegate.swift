//
//  SceneDelegate.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/18.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import UIKit
import SwiftUI
import Combine


final class PagePresenter:ObservableObject{
    func changePage(_ pageObject:PageObject , isCloseAllPopup:Bool = true){
        if isBusy {
            PageLog.d("changePage isBusy " + pageObject.pageID , tag: "PageSceneDelegate")
            return
        }
        PageSceneDelegate.instance?.changePage( pageObject, isCloseAllPopup:isCloseAllPopup )
    }
    func changePage(_ pageID:PageID, idx:Int = 0, params:[String:Any]? = nil, isCloseAllPopup:Bool = true){
        if isBusy {
            PageLog.d("changePage isBusy " + pageID , tag: "PageSceneDelegate")
            return
        }
        let page = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: false)
        PageSceneDelegate.instance?.changePage( page , isCloseAllPopup:isCloseAllPopup)
    }
    func changePage(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0, isCloseAllPopup:Bool = true){
        if isBusy {
            PageLog.d("changePage isBusy " + pageID , tag: "PageSceneDelegate")
            return
        }
        let page = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: false)
        PageSceneDelegate.instance?.changePage( page , isCloseAllPopup:isCloseAllPopup)
    }
    func openPopup(_ pageObject:PageObject ){
        pageObject.isPopup = true
        PageSceneDelegate.instance?.openPopup( pageObject )
    }
    func openPopup(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0){
        let popup = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: true)
        PageSceneDelegate.instance?.openPopup( popup )
    }
    func closePopup(pageId:PageID?, animationType:PageAnimationType? = nil){
        guard let pageKey = pageId else { return }
        PageSceneDelegate.instance?.closePopup(pageID:pageKey, animationType:animationType )
    }
    func setLayerPopup(pageObject: PageObject, isLayer:Bool){
        pageObject.isLayer = isLayer
        pageObject.isWillCloseLayer = false
        let newTop = isLayer ? getBelowPage(page:pageObject) : pageObject
        if !isLayer {
            PageSceneDelegate.instance?.switchTopPopup(pageObject)
        }
        PageSceneDelegate.instance?.onWillChangePage(prevPage: self.currentTopPage, nextPage: newTop)
        
    }
    func closePopup(_ id:String?, animationType:PageAnimationType? = nil){
        guard let pageKey = id else { return }
        PageSceneDelegate.instance?.closePopup(id:pageKey, animationType:animationType  )
    }
    func closeAllPopup(exception pageKey:String? = nil, exceptions:[PageID]? = nil){
        PageSceneDelegate.instance?.closeAllPopup(exception: pageKey ?? "", exceptions:exceptions)
    }
    func closeAllPopupWithExceptions(){
        PageSceneDelegate.instance?.closeAllPopupWithException()
    }
    
    func goBack(){
        PageSceneDelegate.instance?.goBack()
    }
    func onPageEvent(_ pageObject: PageObject?, event:PageEvent){
        PageSceneDelegate.instance?.contentController?.onPageEvent(pageObject, event: event)
        self.event = event
        self.event = nil
    }
    
    func getBelowPage(page:PageObject)->PageObject?{
        if page.isPopup {
            if page.isLayer || page.isWillCloseLayer{
                guard let find = PageSceneDelegate.instance?.popups.filter({!$0.isLayer}).filter({!$0.isWillCloseLayer}).last else { return currentPage }
                return find
            } else {
                guard let find = PageSceneDelegate.instance?.popups.filter({!$0.isLayer}).filter({!$0.isWillCloseLayer}).firstIndex(of: page)  else { return currentPage }
                if find > 0{
                    return PageSceneDelegate.instance?.popups[find - 1]
                }
                return currentPage
            }
        } else {
            return nil
        }
    }
    
    func hasLayerPopup()->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.isLayer }
        return result != nil
    }
    
    func hasPopup(find:PageID)->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.pageID == find}
        return result != nil
    }
    func hasPopup(exception:PageID)->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.pageID != exception}
        return result != nil
    }
    
    
    func hasHistory()->Bool{
        let result = PageSceneDelegate.instance?.historys.first
        return result != nil
    }
    
    func getPopupCount()->Int{
        return PageSceneDelegate.instance?.popups.count ?? 0
    }
    
    func syncOrientation(){
        PageSceneDelegate.instance?.syncOrientation(self.currentTopPage)
    }
    
    
    func setIndicatorAutoHidden(_ isHidden:Bool){
        PageSceneDelegate.instance?.setIndicatorAutoHidden(isHidden)
    }
    
    func orientationLock(lockOrientation:UIInterfaceOrientationMask){
        DataLog.d("orientationLock pre " + lockOrientation.rawValue.description, tag:"PageSceneModel")
        AppDelegate.orientationLock = lockOrientation
    }
    
    func orientationLock(isLock:Bool = false){
        PageSceneDelegate.instance?.requestDeviceOrientationLock(isLock)
        PageLog.d("orientationLock " + isLock.description , tag: "PagePresenter")
    }
    
    func fullScreenEnter(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = nil){
        if self.isFullScreen {return}
        self.isFullScreen = true
        PageSceneDelegate.instance?.onFullScreenEnter(isLock: isLock, changeOrientation:changeOrientation)
        PageLog.d("fullScreenEnter " + isLock.description, tag: "PagePresenter")
    }
    func fullScreenExit(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = nil){
        if !self.isFullScreen {return}
        self.isFullScreen = false
        PageSceneDelegate.instance?.onFullScreenExit(isLock : isLock, changeOrientation: changeOrientation)
        PageLog.d("fullScreenExit " + isLock.description, tag: "PagePresenter")
    }
    
    func requestDeviceOrientation(_ mask:UIInterfaceOrientationMask){
        PageSceneDelegate.instance?.requestDeviceOrientation(mask)
    }
    
    
    @Published fileprivate(set) var event:PageEvent? = nil
    @Published fileprivate(set) var currentPage:PageObject? = nil
    @Published fileprivate(set) var currentPopup:PageObject? = nil
    @Published fileprivate(set) var currentTopPage:PageObject? = nil
   
    @Published var isLoading:Bool = false
    @Published var bodyColor:Color = Color.brand.bg
    @Published var dragOpercity:Double = 0.0
    @Published fileprivate(set) var isBusy:Bool = false
    @Published fileprivate(set) var isFullScreen:Bool = false
    @Published fileprivate(set) var hasPopup:Bool = false
}

struct SceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
}

class PageSceneDelegate: UIResponder, UIWindowSceneDelegate, PageProtocol {
    static let CHANGE_DURATION = Duration.ani.long
    
    static fileprivate var instance:PageSceneDelegate?
    var window: UIWindow? = nil
   
    fileprivate let changeDelay = 0.01
    fileprivate let changeAniDelay =  CHANGE_DURATION
    private(set) var contentController:PageContentController? = nil
    fileprivate var historys:[PageObject] = []
    fileprivate var popups:[PageObject] = []
    let pagePresenter = PagePresenter()
    let sceneObserver = PageSceneObserver()
    private(set) lazy var pageModel:PageModel = getPageModel()
    
    private var changeSubscription:AnyCancellable?
    private var popupSubscriptions:[String:AnyCancellable] = [String:AnyCancellable]()
    deinit {
        changeSubscription?.cancel()
        changeSubscription = nil
        preventDuplicateSubscription?.cancel()
        preventDuplicateSubscription = nil
        popupSubscriptions.forEach{ $0.value.cancel() }
        popupSubscriptions.removeAll()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        PageSceneDelegate.instance = self
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            setupRootViewController(window)
            window.makeKeyAndVisible()
        }
        onInitPage()
    }
    func getPageModel() -> PageModel { return SceneModel()}
    
    private func setupRootViewController(_ window: UIWindow){
        contentController = PageContentController()
        onInitController(controller: contentController!)
        let view = contentController?
            .environmentObject(pagePresenter)
            .environmentObject(sceneObserver)
        
        let rootViewController = PageHostingController(rootView: adjustEnvironmentObjects(view))
        rootViewController.sceneObserver = sceneObserver
        rootViewController.view.backgroundColor = Color.brand.bg.uiColor()
        window.rootViewController = rootViewController
        window.backgroundColor = Color.brand.bg.uiColor()
        window.overrideUserInterfaceStyle = .light
       
    }
    
    private func updateUserInterfaceStyle(style:UIStatusBarStyle){
        guard let window = self.window , let rootViewController = window.rootViewController as? PageHostingController<AnyView> else {return}
        rootViewController.statusBarStyle = style
        switch style {
        case .default:
            window.overrideUserInterfaceStyle = .unspecified
        case .lightContent:
            window.overrideUserInterfaceStyle = .light
        case .darkContent:
            window.overrideUserInterfaceStyle = .dark
        default: break
        }
    }
    
    private let preventDelay =  0.2
    private var preventDuplicate = false
    private var preventDuplicateSubscription:AnyCancellable?
    final func preventDuplicateStart(){
        self.preventDuplicateSubscription?.cancel()
        self.preventDuplicate = true
        preventDuplicateSubscription = Timer.publish(
            every: self.preventDelay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.pagePresenter.isBusy = false
                self.preventDuplicateSubscription?.cancel()
                self.preventDuplicateSubscription = nil
                self.preventDuplicate = false
        }
    }

    final func changePage(_ newPage:PageObject, isBack:Bool = false, isCloseAllPopup:Bool = true){
        PageLog.d("changePage " + newPage.pageID + " " + isBack.description, tag: self.tag)
        if pageModel.currentPageObject?.pageID == newPage.pageID {
            if( pageModel.currentPageObject?.params?.keys == newPage.params?.keys){
                pageModel.currentPageObject?.params = newPage.params
                self.contentController?.reloadPage()
                return
            }
        }
        if !pageModel.isChangePageAble( newPage ) { return }
        if !willChangeAblePage( newPage, isCloseAllPopup:isCloseAllPopup) { return }
        if pageModel.isHomePage( newPage ){ historys.removeAll() }
        let prevContent = contentController?.currnetPage
        let prevPage = pageModel.currentPageObject
        if prevPage == newPage  {
            prevContent?.pageReload()
            return
        }
        
        var closePopups = 0
        if isCloseAllPopup {
            closePopups = closeAllPopup(exception: "", exceptions: self.pageModel.getCloseExceptions(), isWillChangeCheck: false)
        }
        pagePresenter.isBusy = true
        var pageOffset:CGFloat = 0
        if let historyPage = prevPage {
            if isBack {
                pageOffset = -UIScreen.main.bounds.width
            }else{
                pageOffset = (historyPage.pageIDX > newPage.pageIDX) ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
                if pageModel.isHistoryPage( historyPage ){
                    historys.append(historyPage)
                    
                }
            }
            prevPage?.isAnimation = newPage.isAnimation 
            prevContent?.removeAnimationStart()
            prevContent?.pageObservable.pagePosition.x = -pageOffset
            
        }
        var nextContent:PageViewProtocol? = getPageContentBody(newPage)
        nextContent?.setPageObject(newPage)
        nextContent?.pageObservable.pagePosition.x = pageOffset
        if self.popups.filter({!$0.isLayer && !$0.isCloseException}).isEmpty {
            onWillChangePage(prevPage: prevPage, nextPage: newPage)
        }
        contentController?.addPage(nextContent!)
        if pageModel.isChangedCategory(prevPage: prevPage, nextPage: newPage) { nextContent?.categoryChanged(prevPage) }
        
        let delay = newPage.isAnimation ? self.changeAniDelay : self.changeDelay
        var delayAfter = (closePopups > 0) ? self.changeAniDelay - delay : 0
        changeSubscription = Timer.publish(
            every: delay, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                if delayAfter > 0 {
                    delayAfter = delayAfter - delay // 팝업있을경우 부드러운 전환을 위함
                    PageLog.d("initAnimationProgress", tag: self.tag)
                } else {
                    
                    if prevContent != nil { self.contentController?.removePage()}
                    self.changeSubscription?.cancel()
                    self.changeSubscription = nil
                    self.pagePresenter.isBusy = false
                    PageLog.d("initAnimationComplete", tag: self.tag)
                }
                nextContent?.initAnimationComplete()
                nextContent = nil
        }
        pageModel.currentPageObject = newPage
    }
    
    final func openPopup(_ popup:PageObject){
        PageLog.d("openPopup " + popup.pageID, tag: self.tag)
        if !popups.isEmpty {
            if let prev = popups.last {
                if prev.pageID == popup.pageID && self.preventDuplicate { return }
            }
        }
        preventDuplicateStart()
        if !willChangeAblePage( popup ) { return }
        popups.append(popup)
        pagePresenter.hasPopup = true
        let popupContent = getPageContentBody(popup)
        popupContent.setPageObject(popup)
        onWillChangePage(prevPage: nil, nextPage: popup)
       
        
        var delay = self.changeDelay
        if let pageObject = popupContent.pageObject {
            delay = pageObject.animationType == .none ? self.changeDelay : self.changeAniDelay
            //let opacity = pageObject.animationType == .none ? 1.0 : 0.0
            switch  pageObject.animationType {
            case .vertical:
                popupContent.pageObservable.pagePosition.y = UIScreen.main.bounds.height
            case .horizontal:
                popupContent.pageObservable.pagePosition.x = UIScreen.main.bounds.width
            case .reverseVertical:
                popupContent.pageObservable.pagePosition.y = -UIScreen.main.bounds.height
            case .reverseHorizontal:
                popupContent.pageObservable.pagePosition.x = -UIScreen.main.bounds.width
            default: break
            }
            //popupContent.pageObservable.pageOpacity = opacity
        }
        contentController?.addPopup(popupContent)
        let key = popup.id
        let subscription = Timer.publish(
            every: delay,
            on: .main,
            in: .common)
            .autoconnect()
            .sink() {_ in
                
                self.popupSubscriptions[key]?.cancel()
                self.popupSubscriptions.removeValue(forKey: key)
                popupContent.initAnimationComplete()
            }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    final func closePopup(pageID:PageID, animationType:PageAnimationType? = nil){
        PageLog.d("closePopup " + pageID, tag: self.tag)
        guard let findIdx = popups.firstIndex(where: { $0.pageID == pageID}) else { return }
        self.closePopup(id:popups[findIdx].id, animationType:animationType)
    }
    final func closePopup(id:String, animationType:PageAnimationType? = nil){
        PageLog.d("closePopup " + id, tag: self.tag)
        guard let findIdx = popups.firstIndex(where: { $0.id == id}) else { return }
        popups.remove(at: findIdx)
        pagePresenter.hasPopup = !popups.isEmpty
        guard let popupContent = contentController?.getPopup(id) else { return }
        popupContent.removeAnimationStart()
        PageLog.d("closePopup Start" + id, tag: self.tag)
        var delay = self.changeDelay
        let ani = animationType ?? popupContent.pageObject?.animationType ?? .none
        if let pageObject = popupContent.pageObject {
            delay = ani == .none ? self.changeDelay : self.changeAniDelay
            let opacity = ani == .opacity ? 0.0 : 1.0
            switch  ani {
            case .vertical:
                popupContent.pageObservable.pagePosition.y = UIScreen.main.bounds.height
            case .horizontal:
                popupContent.pageObservable.pagePosition.x = UIScreen.main.bounds.width
            case .reverseVertical:
                popupContent.pageObservable.pagePosition.y = -UIScreen.main.bounds.height
            case .reverseHorizontal:
                popupContent.pageObservable.pagePosition.x = -UIScreen.main.bounds.width
            default: break
            }
            popupContent.pageObservable.pageOpacity = opacity
        }
        
        if ani == .none {
            PageLog.d("closePopup completed" + id, tag: self.tag)
            self.contentController?.removePopup(id)
        } else {
            let subscription = Timer.publish(
                every: delay,
                on: .main,
                in: .common)
                .autoconnect()
                .sink() {_ in
                    PageLog.d("closePopup completed" + id, tag: self.tag)
                    self.popupSubscriptions[id]?.cancel()
                    self.popupSubscriptions.removeValue(forKey: id)
                    self.contentController?.removePopup(id)
                }
            popupSubscriptions.updateValue(subscription, forKey: id)
        }
        
        let next = popups.isEmpty
            ? contentController?.currnetPage?.pageObject
            : popups.last
        onWillChangePage(prevPage: nil, nextPage: next)
        
        
    }
    func closeAllPopupWithException(){
        self.closeAllPopup(exception: "", exceptions: self.pageModel.getCloseExceptions())
    }
    
    @discardableResult
    final func closeAllPopup(exception pageKey:String = "", exceptions:[PageID]? = nil, isWillChangeCheck:Bool = true) -> Int{
        PageLog.d("closeAllPopup", tag: self.tag)
        if popups.isEmpty { return 0 }
        
        let key = UUID().description
        var removePops:[String] = []
        popups.removeAll( where: { pop in
            var remove = true
            if pop.id == pageKey { remove = false }
            if pop.isLayer {return false}
            if pop.isCloseException {return false}
            if let exps = exceptions {
                if let _ = exps.first(where: { pop.pageID == $0 }) { remove = false }
            }
            if remove {
                removePops.append(pop.id)
            }
            return remove
        })
        
        pagePresenter.hasPopup = !popups.isEmpty
        var delay = self.changeDelay
        contentController?.pageControllerObservable.popups.forEach{  pop in
            let key = pop.pageObject?.id
            if pop.pageObject?.isCloseException == true {return}
            if pop.pageObject?.isLayer == true {return}
            if key == pageKey { return }
            var remove = true
            if let exps = exceptions {
                if let _ = exps.first(where: { pop.pageID == $0 }) { remove = false }
            }
            if remove {
                PageLog.d("closeAllPopup remove " + pop.pageID, tag:self.tag)
                pop.removeAnimationStart()
                if let pageObject =  pop.pageObject {
                    delay = pageObject.animationType != .none ? self.changeAniDelay : delay
                   
                    let opacity = pageObject.animationType == .none ? 1.0 : 0.0
                    
                    switch  pageObject.animationType {
                    case .vertical:
                        pop.pageObservable.pagePosition.y = UIScreen.main.bounds.height
                    case .horizontal:
                        pop.pageObservable.pagePosition.x = UIScreen.main.bounds.width
                    default: break
                    }
        
                    pop.pageObservable.pageOpacity = opacity
                }
                //pop.pageObservable.pagePosition.y = UIScreen.main.bounds.height
                pop.pageObservable.pageOpacity = 0.0
            }
        }
        if isWillChangeCheck {
            onWillChangePage(prevPage: nil, nextPage: contentController?.currnetPage?.pageObservable.pageObject)
        }
        let subscription = Timer.publish(
            every: delay,
            on: .main,
            in: .common)
            .autoconnect()
                .sink() {_ in
                    self.popupSubscriptions[key]?.cancel()
                    self.popupSubscriptions.removeValue(forKey: key)
                    self.contentController?.removeAllPopup(removePops:removePops)
                   
            }
        popupSubscriptions.updateValue(subscription, forKey: key)
        return removePops.count
    }
    
    final func goBack(){
        var popups:[PageObject] = []
        if let exps = pageModel.getCloseExceptions() {
            popups = self.popups.filter{ top in
                exps.first(where: { $0 == top.pageID }) == nil
            }
        }else{
            popups = self.popups.filter{!($0.isWillCloseLayer || $0.isCloseException)}
        }
        let isHistoryBack = popups.isEmpty
    
        guard let back = isHistoryBack ? pageModel.currentPageObject : popups[popups.count-1] else { return }
        if isHistoryBack {
            guard let next = historys.last else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            historys.removeLast()
            changePage(next, isBack: true)
        }else{
            guard let next = popups.count > 1
                ? popups[popups.count-2]
                : pageModel.currentPageObject
                else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            closePopup(id:back.id)
        }
    }
    
    func onInitPage(){}
    func onInitController(controller:PageContentController){}
    func getPageContentProtocol(_ page:PageObject) -> PageViewProtocol{ return PageContent() }
    func adjustEnvironmentObjects<T>(_ view:T) -> AnyView where T : View { return AnyView(view) }
    func isGoBackAble(prevPage:PageObject?, nextPage:PageObject?) -> Bool { return true }
    
    func getPageContentBody(_ page:PageObject) -> PageViewProtocol{
        return PageContentBody(childView:getPageContentProtocol(page))
    }
    func willChangeAblePage(_ page:PageObject?, isCloseAllPopup:Bool = false)->Bool{ return true }
    func switchTopPopup(_ page:PageObject) {
        PageSceneDelegate.instance?.contentController?.switchTopPopup(page.id)
        guard let idx = self.popups.firstIndex(of: page) else {return}
        self.popups.remove(at: idx)
        self.popups.append(page)
    }
    func onWillChangePage(prevPage:PageObject?, nextPage:PageObject?){
        
        guard let nextPage = nextPage else {return}
        if nextPage.isPopup == true && popups.first(where: {nextPage.id == $0.id}) == nil {return}
        guard let willChangePage = ( !nextPage.isLayer && !nextPage.isWillCloseLayer
                ? nextPage
                : pagePresenter.getBelowPage(page: nextPage) )
              else { return }
        
        PageLog.d("willChangePage isLayer " + nextPage.isLayer.description, tag:self.tag)
        PageLog.d("willChangePage isWillCloseLayer " + nextPage.isWillCloseLayer.description, tag:self.tag)
        PageLog.d("willChangePage " + willChangePage.pageID, tag:self.tag)
    
        if willChangePage.isPopup {
            pagePresenter.currentPopup = willChangePage
        }else{
            pagePresenter.currentPage = willChangePage
            pagePresenter.currentPopup = nil
        }
        pagePresenter.currentTopPage = willChangePage
        pageModel.topPageObject = willChangePage
        if let style = self.getPageModel().getUIStatusBarStyle(willChangePage) {
            self.updateUserInterfaceStyle(style: style)
        }
        self.syncOrientation(willChangePage)
    }
    
    func syncOrientation(_ syncPage:PageObject? = nil) {
        let willChangeOrientationMask = pageModel.getPageOrientation(syncPage)
        AppDelegate.orientationLock = pageModel.getPageOrientationLock(syncPage) ?? .all
        DataLog.d("orientationLock syncOrientation " + AppDelegate.orientationLock.rawValue.description, tag:self.tag)
        guard let willChangeOrientation = willChangeOrientationMask else { return }
        if  willChangeOrientation == .all { return }
        self.requestDeviceOrientation(willChangeOrientation)
    }
    
    func setIndicatorAutoHidden(_ isHidden:Bool){
        if let controller = self.window?.rootViewController as? PageHostingController<AnyView> {
            controller.isIndicatorAutoHidden = isHidden
            DispatchQueue.main.async {
                controller.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
        }
    }
    
    func onFullScreenEnter(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = .landscape){
        self.setIndicatorAutoHidden(true)
        var orientation:UIInterfaceOrientationMask? = nil
        let pageOrientation = pageModel.getPageOrientationLock(nil) ?? .all
        if let changeOrientation = changeOrientation {
            orientation = changeOrientation
            AppDelegate.orientationLock = isLock ? changeOrientation : pageOrientation
        } else if SystemEnvironment.isTablet {
            let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.portrait
            switch interfaceOrientation {
            case .portrait, .unknown:
                orientation = .landscapeRight
            case .portraitUpsideDown:
                orientation = .landscapeRight
            case .landscapeLeft, .landscapeRight:
                orientation = nil
            @unknown default:
                orientation = .landscapeRight
            }
            AppDelegate.orientationLock = isLock ? .landscape : pageOrientation
        } else {
            orientation = .landscapeRight
            AppDelegate.orientationLock = isLock ? .landscape : pageOrientation
        }
        
        guard let orientation = orientation else { return }
        if self.needOrientationChange(changeOrientation: orientation) {
            self.requestDeviceOrientation(orientation)
        }
    }
    func onFullScreenExit(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = nil){
        self.setIndicatorAutoHidden(false)
        var orientation:UIInterfaceOrientationMask? = nil
        let pageOrientation = pageModel.getPageOrientationLock(nil) ?? .all
        if let changeOrientation = changeOrientation {
            orientation = changeOrientation
            AppDelegate.orientationLock = isLock ? changeOrientation : pageOrientation
        } else if SystemEnvironment.isTablet {
            orientation = nil
            if isLock {
                let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.portrait
                switch interfaceOrientation {
                case .portrait:
                    AppDelegate.orientationLock = .portrait
                case .portraitUpsideDown:
                    AppDelegate.orientationLock = .portraitUpsideDown
                case .landscapeLeft, .landscapeRight:
                    AppDelegate.orientationLock = .landscape
                case .unknown: break
                @unknown default: break
                }
            } else {
                AppDelegate.orientationLock = pageOrientation
            }
            
        } else {
            orientation = .portrait
            AppDelegate.orientationLock = isLock ? .portrait : pageOrientation
        }
       
        guard let orientation = orientation else { return }
        if self.needOrientationChange(changeOrientation: orientation) {
            self.requestDeviceOrientation(orientation)
        }
        
    }
    
    func needOrientationChange(changeOrientation:UIInterfaceOrientationMask? = nil) -> Bool {
        guard let willChangeOrientation = changeOrientation else { return false }
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        if willChangeOrientation == .portrait {
            if interfaceOrientation == .portrait || interfaceOrientation == .portraitUpsideDown { return false }
        } else {
            if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight { return false }
        }
        return true
    }
    
    func requestDeviceOrientationLock(_ lock:Bool){
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        
        let orientationLock = lock
            ? getDeviceOrientationMask(orientation: interfaceOrientation)
            : pageModel.getPageOrientationLock(nil) ?? .all
       
        DataLog.d("orientationLock " + orientationLock.rawValue.description, tag:"PageSceneModel")
        AppDelegate.orientationLock = orientationLock
    }
    
    final func requestDeviceOrientation(_ mask:UIInterfaceOrientationMask, isForce:Bool = false){
        let changeOrientation:UIInterfaceOrientation? = getChangeDeviceOrientation(mask: mask)
        if isForce {
            PageLog.d("requestDeviceOrientation mask force" , tag: "PageScene")
            UINavigationController.attemptRotationToDeviceOrientation()
            return
        }
        
        guard let change = changeOrientation else { return }
        DispatchQueue.main.async {
            UIDevice.current.setValue(change.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
            PageLog.d("requestDeviceOrientation mask" + change.rawValue.description, tag: "PageScene")
        }
        
       
    }

    final func getChangeDeviceOrientation(mask:UIInterfaceOrientationMask) -> UIInterfaceOrientation? {
        
        let sceneOrientation = sceneObserver.sceneOrientation
        var current:UIDeviceOrientation? = UIDevice.current.orientation
        if sceneOrientation == .portrait {
            switch current {
            case .landscapeLeft, .landscapeRight: current = nil
            default:break
            }
        } else {
            switch current {
            case .portrait, .portraitUpsideDown: current = nil
            default:break
            }
        }
        
        if current == .portrait {
            switch mask {
                case .landscape, .landscapeRight: return .landscapeRight
                case .landscapeLeft: return .landscapeLeft
                //ase .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else if current == .portraitUpsideDown {
            switch mask {
                case .landscapeRight: return .landscapeRight
                case .landscape, .landscapeLeft: return .landscapeLeft
                case .portrait:return AppUtil.isPad() ? nil : .portrait
                default:return nil
            }
        }
        else if current == .landscapeRight{
            switch mask {
                //case .landscapeLeft: return .landscapeLeft
                case .portrait:return .portrait
                case .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else if current == .landscapeLeft{
            switch mask {
                //case .landscapeRight: return .landscapeRight
                case .portrait:return .portrait
                case .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else {
            
            switch mask {
            case .landscape: return sceneOrientation == .landscape ? nil : .landscapeRight
            case .landscapeLeft: return sceneOrientation == .landscape ? nil : .landscapeLeft
            case .landscapeRight: return sceneOrientation == .landscape ? nil : .landscapeRight
            case .portraitUpsideDown: return sceneOrientation == .portrait ? nil : .portraitUpsideDown
            case .portrait: return sceneOrientation == .portrait ? nil : .portrait
            default:return nil
            }
            
        }
    }
    final func getDeviceOrientationMask(orientation:UIInterfaceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown:return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        default: return .portrait
        }
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        contentController?.sceneDidDisconnect(scene)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        contentController?.sceneDidBecomeActive(scene)
    }
    func sceneWillResignActive(_ scene: UIScene) {
        contentController?.sceneWillResignActive(scene)
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        contentController?.sceneWillEnterForeground(scene)
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        contentController?.sceneDidEnterBackground(scene)
    }
}

