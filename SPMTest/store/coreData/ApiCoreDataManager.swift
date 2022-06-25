//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import SQLite

class ApiCoreDataManager:PageProtocol {
    struct Models {
        static let item = "ApiItem"
    }
    struct Keys {
        static let itemId = "id"
        static let itemJson = "jsonString"
    }
    
    var db:Connection? = nil
    let apis:Table = Table(Models.item)
    let id = Expression<String>(Keys.itemId)
    let jsonString = Expression<String>(Keys.itemJson)
    
    
    func creteTable() {
        do {
            DataLog.d("creteedTable", tag: self.tag)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let destinationPath = documents + "/db.sqlite3"
            let db = try Connection(destinationPath)
            self.db = db
            try db.run(apis.create(temporary: false, ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(jsonString)
            })
            
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }

    func setData<T:Encodable>(key:String, data:T?){
        if self.db == nil {
            creteTable()
        }
        guard let data = data else { return }
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let insert = apis.insert(self.jsonString <- jsonString, self.id <- key)
        do {
            try db?.run(insert)
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getData<T:Decodable>(key:String)->T?{
        if self.db == nil {
            creteTable()
            return nil
        }
        var find:String? = nil
        do {
            for select in try db!.prepare(apis) {
                let id = select[id]
                if id == key {
                    let json = select[jsonString]
                    find = json
                }
            }
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
        
        guard let jsonString = find else { return nil }
        let jsonData = jsonString.data(using: .utf8)!
        do {
            let savedData = try JSONDecoder().decode(T.self, from: jsonData)
            return savedData
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }

    }
    
}
