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

// MARK: - ?????????
extension ViewController {
    
    /// ???????????????
    private func initSetting() {
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        voiceCode = .english
        sortField = .word
        direction = .asc
    }
    
    /// ???????????? (Web)
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
    
    /// ???????????? (??????)
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
    
    /// ???????????? (??????)
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
    
    /// ????????????Item??????
    private func languageItemSetting() {
        
        guard let languageInfomation = Locale._preferredLanguageInfomation(voiceCode.code()),
              let region = languageInfomation.region
        else {
            return
        }
        
        languageButtonItem.title = String(region)._flagEmoji()
    }
    
    /// ?????????????????????
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
    
    /// ????????????????????? (UIAlertController)
    private func refreshDictionaryActions() {
        
        let actions: [Utility.AlertActionInfomation] = [
            (title: "??????", style: .cancel, handler: {}),
            (title: "\("US"._flagEmoji()) ??????", style: .default, handler: { self.refreshDictionaryAction(with: .english) }),
            (title: "\("JP"._flagEmoji()) ??????", style: .default, handler: { self.refreshDictionaryAction(with: .japanese) }),
            (title: "\("KR"._flagEmoji()) ??????", style: .default, handler: { self.refreshDictionaryAction(with: .korean) }),
            (title: "\("TW"._flagEmoji()) ??????", style: .default, handler: { self.refreshDictionaryAction(with: .chinese) }),
        ]
        
        let alertController = UIAlertController._optionAlertController(with: "???????????????", message: nil, preferredStyle: .actionSheet, actions: actions)
        present(alertController, animated: true) {}
    }
        
    /// ????????????????????? (UIAlertController)
    private func refreshSortActions() {
        
        let actions: [Utility.AlertActionInfomation] = [
            (title: "??????", style: .cancel, handler: {}),
            (title: "?????? A-Z", style: .default, handler: { self.refreshSortAction(with: .word, direction: .asc) }),
            (title: "?????? Z-A", style: .default, handler: { self.refreshSortAction(with: .word, direction: .desc) }),
            (title: "?????? 1-5", style: .default, handler: { self.refreshSortAction(with: .level, direction: .asc) }),
            (title: "?????? 5-1", style: .default, handler: { self.refreshSortAction(with: .level, direction: .desc) }),
        ]
        
        let alertController = UIAlertController._optionAlertController(with: "???????????????", message: nil, preferredStyle: .actionSheet, actions: actions)
        present(alertController, animated: true) {}
    }
    
    /// ????????????
    private func refreshDictionaryAction(with voiceCode: Utility.VoiceCode) {
        self.voiceCode = voiceCode
        self.refreshJSON()
    }
    
    /// ????????????
    private func refreshSortAction(with sortField: NoteFields.Field, direction: WWAirTableAPI.Direction) {
        self.sortField = sortField
        self.direction = direction
        self.refreshJSON()
    }
    
    /// ???????????????ICON??????
    /// - Parameters:
    ///   - sortField: ????????????
    ///   - direction: ????????? / ?????????
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
