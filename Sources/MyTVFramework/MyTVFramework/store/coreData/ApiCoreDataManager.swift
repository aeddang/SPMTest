//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
//import SQLite

class ApiCoreDataManager:PageProtocol {
    struct Models {
        static let item = "ApiItem"
    }
    struct Keys {
        static let itemId = "id"
        static let itemJson = "jsonString"
    }
    /*
    var db:Connection? = nil
    let apis:Table = Table(Models.item)
    let id = Expression<String>(Keys.itemId)
    let jsonString = Expression<String>(Keys.itemJson)
    */
    
    func creteTable() {
        
    }

    func setData<T:Encodable>(key:String, data:T?){
        
    }
    
    func getData<T:Decodable>(key:String)->T?{
        
        return nil
        

    }
    
}
