//
//  ViewController.swift
//  MyEnglish
//
//  Created by Yu-Bin Weng on 2021/1/10.
//

import UIKit
import PKHUD

final class ViewController: UIViewController {
        
    @IBOutlet weak var languageButtonItem: UIBarButtonItem!
    @IBOutlet weak var sortButtonItem: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    
    private let apiKey = "<your_api_key>"
    private let appID = "<your_app_id>"
    private let segueIdentifier = "OnlineDictionarySegue"
    
    private var voiceCode: Utility.VoiceCode = .english { didSet { languageItemSetting() }}
    private var api: WWAirTableAPI { return WWAirTableAPI.init(appID: appID, apiKey: apiKey) }
    
    private var sortField: NoteFields.Field = .word
    private var direction: WWAirTableAPI.Direction = .asc {
        didSet { sortButtonItemSetting(sortField: sortField, direction: direction) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
        refreshJSON()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { prepareAction(for: segue, sender: sender) }
    
    @IBAction func refreshDictionary(_ sender: UIBarButtonItem) { refreshDictionaryActions() }
    @IBAction func sortResult(_ sender: UIBarButtonItem) { refreshSortActions() }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return MyTableViewCell.records.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as? MyTableViewCell else { fatalError() }
        cell.configure(with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? MyTableViewCell,
              let string = cell.wordLabel.text
        else {
            return
        }
        
        cell.speech(string: string, voice: voiceCode)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? MyTableViewCell,
              let word = cell.wordLabel.text
        else {
            return
        }
        
        performSegue(withIdentifier: segueIdentifier, sender: word)
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        voiceCode = .english
        sortField = .word
        direction = .asc
    }
    
    /// 更新資料 (Web)
    private func refreshJSON() {
        
        DispatchQueue.main.async { HUD.show(.progress) }
        
        refreshLevels { [weak self] (_result) in
                        
            guard let this = self else { return }
            
            switch _result {
            case .failure(_):  DispatchQueue.main.async { HUD.flash(.error) }
            case .success(let levels):
                
                guard let levels = levels else { return }
                MyTableViewCell.levels = levels
                
                this.refreshWords { (_result_) in
                    
                    switch _result_ {
                    case .failure(_): DispatchQueue.main.async { HUD.flash(.error) }
                    case .success(let records):
                        
                        guard let records = records else { return }
                        
                        MyTableViewCell.records = records
                        
                        DispatchQueue.main.async {
                            this.myTableView.reloadData()
                            HUD.flash(.success)
                        }
                    }
                }
            }
        }
    }
    
    /// 下載資料 (單字)
    private func refreshWords(result: @escaping (Result<[[String: Any]]?, Error>) -> Void) {
        
        api.clear().tablename(voiceCode.tablename()).sort(field: sortField.rawValue, direction: direction).getJSON { (_result) in
            
            switch _result {
            case .failure(let error): result(.failure(error))
            case .success(let data):
                
                guard let json = data?._jsonSerialization() as? [String: Any],
                      let records = json["records"] as? [[String: Any]]
                else {
                    result(.success(nil)); return
                }
                
                result(.success(records))
            }
        }
    }
    
    /// 下載資料 (等級)
    private func refreshLevels(result: @escaping (Result<[[String: Any]]?, Error>) -> Void) {
                
        api.clear().tablename("Level").getJSON { (_result) in
            
            switch _result {
            case .failure(let error): result(.failure(error))
            case .success(let data):
                
                guard let json = data?._jsonSerialization() as? [String: Any],
                      let levels = json["records"] as? [[String: Any]]
                else {
                    result(.success(nil)); return
                }
                
                result(.success(levels))
            }
        }
    }
    
    /// 設定語系Item圖示
    private func languageItemSetting() {
        
        guard let languageInfomation = Locale._preferredLanguageInfomation(voiceCode.code()),
              let region = languageInfomation.region
        else {
            return
        }
        
        languageButtonItem.title = String(region)._flagEmoji()
    }
    
    /// 把值帶到下一頁
    /// - Parameters:
    ///   - segue: UIStoryboardSegue
    ///   - sender: Any?
    private func prepareAction(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let viewController = segue.destination as? OnlineDictionaryViewController,
              let word = sender as? String
        else {
            return
        }
        
        viewController.voiceCode = voiceCode
        viewController.word = word
    }
    
    /// 更新資料的動作 (UIAlertController)
    private func refreshDictionaryActions() {
        
        let actions: [Utility.AlertActionInfomation] = [
            (title: "取消", style: .cancel, handler: {}),
            (title: "\("US"._flagEmoji()) 英文", style: .default, handler: { self.refreshDictionaryAction(with: .english) }),
            (title: "\("JP"._flagEmoji()) 日文", style: .default, handler: { self.refreshDictionaryAction(with: .japanese) }),
            (title: "\("KR"._flagEmoji()) 韓文", style: .default, handler: { self.refreshDictionaryAction(with: .korean) }),
            (title: "\("TW"._flagEmoji()) 中文", style: .default, handler: { self.refreshDictionaryAction(with: .chinese) }),
        ]
        
        let alertController = UIAlertController._optionAlertController(with: "請選擇字典", message: nil, preferredStyle: .actionSheet, actions: actions)
        present(alertController, animated: true) {}
    }
        
    /// 更新排序的動作 (UIAlertController)
    private func refreshSortActions() {
        
        let actions: [Utility.AlertActionInfomation] = [
            (title: "取消", style: .cancel, handler: {}),
            (title: "單字 A-Z", style: .default, handler: { self.refreshSortAction(with: .word, direction: .asc) }),
            (title: "單字 Z-A", style: .default, handler: { self.refreshSortAction(with: .word, direction: .desc) }),
            (title: "等級 1-5", style: .default, handler: { self.refreshSortAction(with: .level, direction: .asc) }),
            (title: "等級 5-1", style: .default, handler: { self.refreshSortAction(with: .level, direction: .desc) }),
        ]
        
        let alertController = UIAlertController._optionAlertController(with: "請選擇字典", message: nil, preferredStyle: .actionSheet, actions: actions)
        present(alertController, animated: true) {}
    }
    
    /// 更新資料
    private func refreshDictionaryAction(with voiceCode: Utility.VoiceCode) {
        self.voiceCode = voiceCode
        self.refreshJSON()
    }
    
    /// 更新排序
    private func refreshSortAction(with sortField: NoteFields.Field, direction: WWAirTableAPI.Direction) {
        self.sortField = sortField
        self.direction = direction
        self.refreshJSON()
    }
    
    /// 更新排序的ICON圖示
    /// - Parameters:
    ///   - sortField: 排序欄位
    ///   - direction: 順著排 / 倒著排
    private func sortButtonItemSetting(sortField: NoteFields.Field, direction: WWAirTableAPI.Direction) {
        
        switch (sortField, direction) {
        case (.word, .asc): sortButtonItem.image = #imageLiteral(resourceName: "A-Z")
        case (.word, .desc): sortButtonItem.image = #imageLiteral(resourceName: "Z-A")
        case (.level, .asc): sortButtonItem.image = #imageLiteral(resourceName: "1-5")
        case (.level, .desc): sortButtonItem.image = #imageLiteral(resourceName: "5-1")
        default: break
        }
    }
}
