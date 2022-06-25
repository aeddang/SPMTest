//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import SQLite


class DownLoadProcessCoreDataManager:PageProtocol {
    struct Models {
        static let process = "process"
    }
    struct Keys {
        static let contentId = "contentId"
        static let path = "path"
        static let ckcURL = "ckcURL"
        static let createDate = "createDate"
    }
    
    var db:Connection? = nil
    let process:Table = Table(Models.process)
    let id = Expression<String>(Keys.contentId)
    let path = Expression<String>(Keys.path)
    let ckcURL = Expression<String>(Keys.ckcURL)
    let date = Expression<Date>(Keys.createDate)
    
    func creteTable() {
        do {
            DataLog.d("creteedTable", tag: self.tag)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let destinationPath = documents + "/db.sqlite3"
            let db = try Connection(destinationPath)
            self.db = db
            try db.run(process.create(temporary: false, ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(path)
                t.column(ckcURL)
                t.column(date)
            })
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func setData(q:DownLoadQ){
        self.setData(contentId: q.fildID, path: q.path, ckcURL: q.ckcURL)
    }
    
    func setData(contentId:String, path:String, ckcURL:String){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let insert = process.insert(
            self.id <- contentId,
            self.path <- path,
            self.ckcURL <- ckcURL,
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
            try db.run(process.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    func deleteData(contentId:String){
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return}
        let find = process.filter(id == contentId)
        do {
            try db.run(find.delete())
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllDatas()->[DownLoadQ]{
        if self.db == nil {
            creteTable()
        }
        guard let db = self.db else {return []}
        do {
            let process = try db.prepare(process)
            return process.map{ select in
                return DownLoadQ(
                    fildID: select[id],
                    path: select[path],
                    ckcURL: select[ckcURL],
                    isStart: false,
                    isAuto: true)
            }
           
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    
}
