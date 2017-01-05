//
//  SQLiteConnect.swift
//  Your Email
//
//  Created by Antonio Tsai on 06/01/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

class SQLiteConnect {
    
    var db :OpaquePointer? = nil
    let sqlitePath :String
    
    init?(path :String) {
        sqlitePath = path
        db = self.openDatabase(path: sqlitePath)
        
        if db == nil {
            return nil
        }
    }
    
    // 連結資料庫 connect database
    func openDatabase(path :String) -> OpaquePointer {
        var connectdb: OpaquePointer? = nil
        if sqlite3_open(path, &connectdb) == SQLITE_OK {
            print("Successfully opened database \(path)")
            return connectdb!
        } else {
            print("Unable to open database.")
            return Optional<OpaquePointer>.none!
        }
    }
    
    // 建立資料表 create table
    func createTable(
        tableName :String, columnsInfo :[String]) -> Bool {
        let sql = "create table if not exists \(tableName) "
            + "(\(columnsInfo.joined(separator: ",")))"
            as NSString
        
        if sqlite3_exec(
            self.db, sql.utf8String, nil, nil, nil) == SQLITE_OK{
            return true
        }
        
        return false
    }
    
    // 新增資料
    func insert(
        tableName :String, rowInfo :[String:String]) -> Bool {
        var statement :OpaquePointer? = nil
        /*
        let sql = "insert into \(tableName) "
            + "(\(rowInfo.keys.joinedWithSeparator(separator: ","))) "
            + "values "
            + "(\(rowInfo.values.joinWithSeparator(",")))"
            as NSString
        */
        let sql = "insert into \(tableName) (\(rowInfo.keys.joined(separator: ","))) values (\(rowInfo.values.joined(separator: ",")))"
            as NSString
        
        if sqlite3_prepare_v2(
            self.db, sql.utf8String, -1, &statement, nil)
            == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        
        return false
    }
    
    // 讀取資料
    func fetch(
        tableName :String, cond :String?, order :String?)
        -> OpaquePointer {
            var statement :OpaquePointer? = nil
            var sql = "select * from \(tableName)"
            if let condition = cond {
                sql += " where \(condition)"
            }
            
            if let orderBy = order {
                sql += " order by \(orderBy)"
            }
            
            sqlite3_prepare_v2(
                self.db, (sql as NSString).utf8String, -1,
                &statement, nil)
            
            return statement!
    }
    
    // 更新資料
    func update(
        tableName :String,
        cond :String?, rowInfo :[String:String]) -> Bool {
        var statement :OpaquePointer? = nil
        var sql = "update \(tableName) set "
        
        // row info
        var info :[String] = []
        for (k, v) in rowInfo {
            info.append("\(k) = \(v)")
        }
        sql += info.joined(separator: ",")
        
        // condition
        if let condition = cond {
            sql += " where \(condition)"
        }
        
        if sqlite3_prepare_v2(
            self.db, (sql as NSString).utf8String, -1,
            &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        
        return false
        
    }
    
    // 刪除資料
    func delete(tableName :String, cond :String?) -> Bool {
        var statement :OpaquePointer? = nil
        var sql = "delete from \(tableName)"
        
        // condition
        if let condition = cond {
            sql += " where \(condition)"
        }
        
        if sqlite3_prepare_v2(
            self.db, (sql as NSString).utf8String, -1,
            &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        
        return false
    }
    
}
