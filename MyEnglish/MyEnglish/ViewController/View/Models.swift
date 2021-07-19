//
//  Models.swift
//  MyEnglish
//
//  Created by Yu-Bin Weng on 2021/1/10.
//

import UIKit

struct Record {
    
    let id: String
    let createdTime: String
    let fields: Any
    
    static func _build(record: [String: Any]) -> Record? {
        
        guard let id = record["id"] as? String,
              let createdTime = record["createdTime"] as? String,
              let fields = record["fields"]
        else {
            return nil
        }
        
        return Record(id: id, createdTime: createdTime, fields: fields)
    }
}

struct NoteFields {
    
    enum Field: String {
        case level = "Level"
        case word = "Word"
        case notes = "Notes"
    }
    
    let level: Int
    let word: String
    let notes: String
    
    static func _build(fields: Any?) -> NoteFields? {
        
        guard let fields = fields as? [String: Any],
              let level = fields[Field.level.rawValue] as? Int,
              let word = fields[Field.word.rawValue] as? String,
              let notes = fields[Field.notes.rawValue] as? String
        else {
            return nil
        }
        
        return NoteFields(level: level, word: word, notes: notes)
    }
}

struct LevelFields {
    
    enum Field: String {
        case level = "Level"
        case name = "Name"
        case color = "Color"
    }
    
    let level: Int
    let name: String
    let color: String
    
    static func _build(fields: Any?) -> LevelFields? {
        
        guard let fields = fields as? [String: Any],
              let level = fields[Field.level.rawValue] as? Int,
              let name = fields[Field.name.rawValue] as? String,
              let color = fields[Field.color.rawValue] as? String
        else {
            return nil
        }
        
        return LevelFields(level: level, name: name, color: color)
    }
}
