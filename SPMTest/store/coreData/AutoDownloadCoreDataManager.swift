//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import SQLite


class AutoDownloadCoreDataManager:PageProtocol {
    struct Models {
        static let contents = "autoContents"
    }
    struct Keys {
        static let contentId = "contentId"
        static let createDate = "createDate"
    }
    
    var db:Connection? = nil
    let contents:Table = Table(Models.contents)
   
    let id = Expression<String>(Keys.contentId)
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
                t.column(date)
            })
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func setData(contentId:String){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let insert = contents.insert(
            self.id <- contentId,
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
    
    func getAllDatas()->[String]{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return []}
        do {
            let contents = try db.prepare(contents)
            return contents.map{ select in
                return select[id]
            }
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    func getData(contentId:String)->Date?{
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
                return find[date]
            }
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
        return nil
    }
}
