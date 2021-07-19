//
//  Cells.swift
//  MyEnglish
//
//  Created by Yu-Bin Weng on 2021/1/10.
//

import UIKit
import AVFoundation

final class MyTableViewCell: UITableViewCell {
    
    static var records: [[String: Any]] = []
    static var levels: [[String: Any]] = []

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var levelColorView: UIView!
    
    func configure(with indexPath: IndexPath) {
        
        guard let record = Self.records[safe: indexPath.row],
              let info = Record._build(record: record),
              let fields = NoteFields._build(fields: info.fields),
              let backgroundColor = levelColor(fields.level)
        else {
            return
        }
        
        indexLabel.text = (indexPath.row + 1)._repeatString(count: 3)
        wordLabel.text = fields.word
        notesLabel.text = fields.notes
        
        levelColorView.backgroundColor = backgroundColor
    }
}

extension MyTableViewCell: CellReusable, AVSpeechSynthesizerDelegate {
    
    ///  [文字發聲](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/讓開不了口的-app-開口說話-48c674f8f69e)
    /// - Parameter string: 要讀的文字
    func speech(string: String, voice: Utility.VoiceCode = .english) {
        
        let synthesizer = AVSpeechSynthesizer._build(delegate: self)
        synthesizer._speak(string: string, voice: voice)
    }
    
    /// 取得該等級的顏色
    /// - Parameter level: 等級 (1~5)
    /// - Returns: UIColor?
    private func levelColor(_ level: Int) -> UIColor? {
        
        let colors = Self.levels.compactMap { (record) -> String? in
            
            guard let info = Record._build(record: record),
                  let fields = LevelFields._build(fields: info.fields),
                  fields.level == level
            else {
                return nil
            }
            
            return fields.color
        }
        
        guard let colorString = colors.first else { return nil }
        
        return UIColor(rgb: colorString)
    }
}

