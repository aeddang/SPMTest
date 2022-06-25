//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import SQLite
extension ContentCoreData {
    static func encode<T:Encodable>(data:T?) -> String? {
        guard let data = data else { return nil }
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
    
    static func decode<T:Decodable>(jsonString:String)->T?{
        let jsonData = jsonString.data(using: .utf8)!
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
            return decodedData
        } catch {
            DataLog.e(error.localizedDescription, tag: " ContentCoreData")
            return nil
        }

    }
}

struct ContentCoreData{
    var contentId:String
    var title:String
    var metaData:String
    var createDate:Date
}

class ContentCoreDataManager:PageProtocol {
    struct Models {
        static let contents = "contents"
    }
    struct Keys {
        static let contentId = "contentId"
        static let title = "title"
        static let metaData = "metaData"
        static let createDate = "createDate"
    }
    
    var db:Connection? = nil
    let contents:Table = Table(Models.contents)
   
    let id = Expression<String>(Keys.contentId)
    let title = Expression<String>(Keys.title)
    let metaData = Expression<String>(Keys.metaData)
    let date = Expression<Date>(Keys.createDate)
    
    func creteTable() {
        do {
            DataLog.d("creteedTable", tag: self.tag)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let destinationPath = documents + "/db.sqlite3"
            let db = try Connection(destinationPath)
            self.db = db
            try db.run(contents.create(temporary: false, ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(title)
                t.column(metaData)
                t.column(date)
            })
           
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func setData(contentId:String, title:String="", metaDataJsonString:String = ""){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let insert = contents.insert(
            self.id <- contentId,
            self.title <- title,
            self.metaData <- metaDataJsonString,
            self.date <- AppUtil.networkTimeDate())
        do {
            try db.run(insert)
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func deleteAllData(){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        do {
            try db.run(contents.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func deleteData(contentId:String){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let find = contents.filter(id == contentId)
        do {
            try db.run(find.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllDatas()->[ContentCoreData]{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return []}
        do {
            let contents = try db.prepare(contents)
            return contents.map{ select in
                return ContentCoreData(
                    contentId: select[id],
                    title: select[title],
                    metaData: select[metaData],
                    createDate: select[date])
            }
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    func getData(contentId:String)->(ContentCoreData)?{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return nil}
        do {
            let contents = try db.prepare(contents)
            let select = contents.first(where: { select in
                let id = select[id]
                return id == contentId
            })
            if let find = select {
                return ContentCoreData(
                   contentId: find[id],
                   title: find[title],
                   metaData: find[metaData],
                   createDate: find[date])
            }
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
        return nil
    }
}
