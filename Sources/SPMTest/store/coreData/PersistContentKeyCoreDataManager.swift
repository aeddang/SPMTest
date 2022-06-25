//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import SQLite

class PersistContentKeyCoreDataManager:PageProtocol {
    struct Models {
        static let keys = "PersistContentKeyItem"
        static let keySet = "PersistContentKeySetItem"
    }
    struct Keys {
        static let contentId = "contentId"
        static let keyData = "keyData"
        static let createDate = "createDate"
        static let keyDatas = "keyDatas"
    }
    
    var db:Connection? = nil
    let keys:Table = Table(Models.keys)
    let keySet:Table = Table(Models.keySet)
    let id = Expression<String>(Keys.contentId)
    let keyData = Expression<Data>(Keys.keyData)
    let keyDatas = Expression<String>(Keys.keyDatas)
    let date = Expression<Date>(Keys.createDate)
    
    func creteTable() {
        do {
            DataLog.d("creteedTable", tag: self.tag)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let destinationPath = documents + "/db.sqlite3"
            let db = try Connection(destinationPath)
            self.db = db
            try db.run(keys.create(temporary: false, ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(keyData)
                t.column(date)
            })
            try db.run(keySet.create(temporary: false, ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(keyDatas)
                t.column(date)
            })
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
    
        }
    }
    
    func setData(contentId:String, data:Data, fileId:String=""){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let insert = keys.insert(self.keyData <- data, self.id <- fileId+contentId, self.date <- AppUtil.networkTimeDate())
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
            try db.run(keys.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func deleteData(contentId:String, fileId:String=""){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let find = keys.filter(id == fileId+contentId)
        do {
            try db.run(find.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllDatas()->[(String, Data, Date)]{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return []}
        do {
            let keys = try db.prepare(keys)
            return keys.map{ select in
                let id = select[id]
                let key = select[keyData]
                let date = select[date]
                return (id, key, date)
            }
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    func getData(contentId:String, fileId:String="")->(String, Data, Date)?{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return nil}
        var find:Data? = nil
        var creatDate:Date? = nil
        do {
            let keys = try db.prepare(keys)
            let select = keys.first(where: { select in
                let id = select[id]
                return id == fileId+contentId
            })
            find = select?[keyData]
            creatDate = select?[date]
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
        guard let key = find, let date = creatDate else {return nil}
        return (contentId, key, date)
    }
    
    //group
    func setData(fileId:String, contentIds:[String]){
        if contentIds.isEmpty {return}
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        var keyDatas = contentIds.reduce("", {
            return $0 + "," + $1
        })
        keyDatas.removeFirst()
        let insert = keySet.insert(self.keyDatas <- keyDatas , self.id <- fileId, self.date <- AppUtil.networkTimeDate())
        do {
            try db.run(insert)
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func deleteData(fileId:String){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let find = keySet.filter(id == fileId)
        do {
            try db.run(find.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func getData(fileId:String)->([String], Date)?{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return nil}
        var find:[String] = []
        var creatDate:Date? = nil
        do {
            let sets = try db.prepare(keySet)
            let select = sets.first(where: { select in
                let id = select[id]
                return id == fileId
            })
            if let keyString = select?[keyDatas] {
                find = keyString.components(separatedBy: ",")
                creatDate = select?[date]
            }
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
        guard let date = creatDate else {return nil}
        return (find, date)
    }
}
