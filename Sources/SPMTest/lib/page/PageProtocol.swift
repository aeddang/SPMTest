//
//  PageProtocol.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import SwiftUI


typealias PageID = String
typealias PageParam = String

enum PageAnimationType {
    case none, vertical, horizontal, opacity
    case reverseVertical, reverseHorizontal
}

class PageObject : Equatable, Identifiable{
    var pageID: PageID
    var pageIDX:Int
    var pageGroupID:String? = nil
    var params:[PageParam:Any]?
    var isPopup:Bool
    var isCloseException:Bool = false
    var zIndex:Int = 0
    var isDimed:Bool
    var isHome:Bool = false
    var isAnimation:Bool = false
    var isLayer:Bool = false
    var isWillCloseLayer:Bool = false
    var sendLog:Bool = false
    var animationType:PageAnimationType = .horizontal
    let id:String = UUID().uuidString
    init(
        pageID:PageID,
        pageIDX:Int = 0,
        pageGroupID:String? = nil,
        params:[PageParam:Any]? = nil,
        isPopup:Bool = false,
        isDimed:Bool = false
       // pageKey:String = UUID().uuidString
    ){
        self.pageID = pageID
        self.pageIDX = pageIDX
        self.pageGroupID = pageGroupID
        self.params = params
        self.isPopup = isPopup
        self.isDimed = isDimed
        //self.id = pageKey
    }
    
    @discardableResult
    func addParam(key:PageParam, value:Any?)->PageObject{
        guard let value = value else { return self }
        if params == nil {
            params = [PageParam:Any]()
        }
        params![key] = value
        return self
    }
    @discardableResult
    func removeParam(key:PageParam)->PageObject{
        if params == nil { return self }
        params![key] = nil 
        return self
    }
    @discardableResult
    func addParam(params:[PageParam:Any]?)->PageObject{
        guard let params = params else {
            return self
        }
        if self.params == nil {
            self.params = params
            return self
        }
        params.forEach{
            self.params![$0.key] = $0.value
        }
        return self
    }
    
    func getParamValue(key:PageParam)->Any?{
        if params == nil { return nil }
        return params![key]
    }
    
    public static func isSamePage(l:PageObject?, r:PageObject?)-> Bool {
        guard let l = l else {return false}
        guard let r = r else {return false}
        if !l.isPopup && !r.isPopup {
            let same = l.pageID == r.pageID
            return same
        }
        return l.id == r.id
    }
    public static func == (l:PageObject, r:PageObject)-> Bool {
        return l.id == r.id
    }
}

enum PageStatus:String {
    case initate,
    appear,
    disAppear,
    transactionComplete,
    becomeActive,
    disconnect ,
    resignActive  ,
    enterForeground ,
    enterBackground
}

enum PageLayer:String {
    case top,
    below,
    bottom
}

enum SceneOrientation :String{
    case portrait, landscape
    var logConfig: String {
        switch self {
        case .portrait: return "vertical"
        case .landscape: return "horizontal"
        }
    }
}



open class PageObservable: ObservableObject  {
    @Published var status:PageStatus = .initate
    @Published var layer:PageLayer = .top
    @Published var pageObject:PageObject?
    @Published var pagePosition:CGPoint = CGPoint()
    @Published var pageOpacity:Double = 1.0
    @Published var isBackground:Bool = false
    @Published var isAnimationComplete:Bool = false
}



protocol PageProtocol {}
extension PageProtocol {
    var tag:String {
        get{ "\(String(describing: Self.self))" }
    }
}
protocol PageContentProtocol:PageProtocol {
    
    var childView:PageViewProtocol? { get }
    var pageObservable:PageObservable { get }
    func onSetPageObject(_ page:PageObject)
    func onPageReload()
    func onPageEvent(_ pageObject:PageObject?, event:PageEvent)
    func onPageChanged(_ pageObject:PageObject?)
    func onPageAdded(_ pageObject:PageObject?)
    func onPageRemoved(_ pageObject:PageObject?)
    func onCategoryChanged(_ prevPageObject:PageObject?)
    
    func onInitAnimationComplete()
    func onAppear()
    func onDisAppear()
    func onRemoveAnimationStart()
    func onSceneDidBecomeActive()
    func onSceneDidDisconnect()
    func onSceneWillResignActive()
    func onSceneWillEnterForeground()
    func onSceneDidEnterBackground()
    func onPageTop()
    func onPageBelow()
    func onPageBottom()
    
    func initAnimationComplete()
    func removeAnimationStart()
    func sceneDidBecomeActive(_ scene: UIScene)
    func sceneDidDisconnect(_ scene: UIScene)
    func sceneWillResignActive(_ scene: UIScene)
    func sceneWillEnterForeground(_ scene: UIScene)
    func sceneDidEnterBackground(_ scene: UIScene)
    func pageTop()
    func pageBelow()
    func pageBottom()
    
    
  
}
extension PageContentProtocol {
    //override func
    var pageObservable:PageObservable { get { PageObservable() } }
    func onSetPageObject(_ page:PageObject){}
    func onPageReload(){}
    func onPageChanged(_ pageObject:PageObject?){}
    func onPageEvent(_ pageObject:PageObject?, event:PageEvent){}
    func onPageAdded(_ pageObject:PageObject?){}
    func onPageRemoved(_ pageObject:PageObject?){}
    func onCategoryChanged(_ prevPageObject:PageObject?){}
    
    func onInitAnimationComplete(){}
    func onRemoveAnimationStart(){}
    func onSceneDidBecomeActive(){}
    func onSceneDidDisconnect(){}
    func onSceneWillResignActive(){}
    func onSceneWillEnterForeground(){}
    func onSceneDidEnterBackground(){}
    func onAppear(){}
    func onDisAppear(){}
    func onPageTop(){}
    func onPageBelow(){}
    func onPageBottom(){}
    
    //super func
    @discardableResult
    func setPageObject(_ page:PageObject)->PageViewProtocol?{
        pageObservable.pageObject = page
        childView?.setPageObject(page)
        onSetPageObject(page)
        return self as? PageViewProtocol
    }
    func pageReload(){
        childView?.pageReload()
        onPageReload()
    }
    
    func pageEvent(_ pageObject:PageObject?, event:PageEvent){
        childView?.pageEvent(pageObject, event:event)
        onPageEvent(pageObject, event:event)
    }
    func pageChanged(_ pageObject:PageObject?){
        childView?.pageChanged(pageObject)
        onPageChanged(pageObject)
    }
    func pageAdded(_ pageObject:PageObject?){
        childView?.pageAdded(pageObject)
        onPageAdded(pageObject)
    }
    func pageRemoved(_ pageObject:PageObject?){
        childView?.pageRemoved(pageObject)
        onPageRemoved(pageObject)
    }
    
    func categoryChanged(_ prevPageObject:PageObject?){
        childView?.categoryChanged(prevPageObject)
        onCategoryChanged( prevPageObject )
    }
    func appear(){
        childView?.appear()
        pageObservable.status = .appear
        onAppear()
    }
    func disAppear(){
        childView?.disAppear()
        pageObservable.status = .disAppear
        onDisAppear()
    }
    func initAnimationComplete(){
        childView?.initAnimationComplete()
        pageObservable.isAnimationComplete = true
        pageObservable.status = .transactionComplete
        
        onInitAnimationComplete()
    }
    func removeAnimationStart(){
        childView?.removeAnimationStart()
        pageObservable.isAnimationComplete = false
        onRemoveAnimationStart()
    }
    func sceneDidBecomeActive(_ scene: UIScene){
        childView?.sceneDidBecomeActive( scene )
        pageObservable.status = .becomeActive
       
        onSceneDidBecomeActive()
    }
    func sceneDidDisconnect(_ scene: UIScene){
        childView?.sceneDidDisconnect( scene )
        pageObservable.status = .disconnect
        onSceneDidDisconnect()
    }
    func sceneWillResignActive(_ scene: UIScene){
        childView?.sceneWillResignActive( scene )
        pageObservable.status = .resignActive
        onSceneWillResignActive()
    }
    func sceneWillEnterForeground(_ scene: UIScene){
        childView?.sceneWillEnterForeground( scene )
        pageObservable.status = .enterForeground
        pageObservable.isBackground = false
        onSceneWillEnterForeground()
    }
    func sceneDidEnterBackground(_ scene: UIScene){
        childView?.sceneDidEnterBackground( scene )
        pageObservable.status = .enterBackground
        pageObservable.isBackground = true
        onSceneDidEnterBackground()
    }
    func pageTop(){
        if pageObservable.layer == .top {return}
        childView?.pageTop()
        pageObservable.layer = .top
        onPageTop()
    }
    func pageBelow(){
        if pageObservable.layer == .below {return}
        childView?.pageBelow()
        pageObservable.layer = .below
        onPageBelow()
    }
    func pageBottom(){
        if pageObservable.layer == .bottom {return}
        childView?.pageBottom()
        pageObservable.layer = .bottom
        onPageBottom()
    }
}

protocol PageViewProtocol : PageContentProtocol{
    var pageObject:PageObject? { get }
    var pageID:PageID { get }
    var zIndex:Int { get }
    var id:String { get }
    var contentBody:AnyView { get }
}

protocol PageView : View, PageViewProtocol, Identifiable{}
extension PageView {
    
    var childView:PageViewProtocol? {
        get{ nil }
    }
    var pageObject:PageObject?{
        get{ pageObservable.pageObject }
    }
    var pageID:PageID{
        get{ pageObservable.pageObject?.pageID ?? ""}
    }
    var zIndex:Int{
        get{ pageObservable.pageObject?.zIndex ?? 0}
    }
    var id:String{
        get{ pageObservable.pageObject?.id ?? ""}
    }
    var contentBody:AnyView { get{
        return AnyView(self)
    }}
}

protocol PageModel {
    var currentPageObject:PageObject? {get set}
    var topPageObject:PageObject? {get set}
    func getHome(idx:Int) -> PageObject?
    func isHomePage(_ pageObject:PageObject ) -> Bool
    func isHistoryPage(_ pageObject:PageObject ) -> Bool
    func isChangedCategory(prevPage:PageObject?, nextPage:PageObject?) -> Bool
    func isChangePageAble(_ pageObject: PageObject) -> Bool
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask?
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask?
    func getUIStatusBarStyle(_ pageObject:PageObject?) -> UIStatusBarStyle?
    func getCloseExceptions() -> [PageID]?
}
extension PageModel{
    func getHome(idx:Int) -> PageObject? { return nil }
    func isHomePage(_ pageObject:PageObject ) -> Bool { return false }
    func isHistoryPage(_ pageObject:PageObject ) -> Bool { return true }
    func isChangedCategory(prevPage:PageObject?, nextPage:PageObject?) -> Bool { return false }
    func isChangePageAble(_ pageObject: PageObject) -> Bool { return true }
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? { return nil }
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? { return nil }
    func getUIStatusBarStyle(_ pageObject:PageObject?) -> UIStatusBarStyle? { return nil }
    func getCloseExceptions() -> [PageID]? { return nil }
}

typealias PageEventType = String
struct PageEvent {
    private(set) var id:String = ""
    private(set) var type:PageEventType = ""
    var data: Any? = nil
}


protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}
