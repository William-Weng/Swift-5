//
//  DatePickerViewController.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/7/7.
//

import UIKit

final class DatePickerViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    
    private let pickerInformation: (years: [String], months: [String]) = ([2021...2200]._repeating(), [1...12]._repeating())
    
    private lazy var pickerView = UIPickerView._build(delegateAndDataSource: self, doneAction: #selector(doneAction(_:)), cancelAction: #selector(cancelAction(_:)))
    
    weak var myDelegte: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dateTextField.inputView = pickerView.keyboard
        dateTextField.inputAccessoryView = pickerView.toolbar
        dateTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.dismiss(animated: true, completion: nil) }
    
    @objc func doneAction(_ item: UIBarButtonItem) {
        
        let yearIndex = pickerView.keyboard.selectedRow(inComponent: 0)
        let monthIndex = pickerView.keyboard.selectedRow(inComponent: 1)
        
        guard let year = pickerInformation.years[safe: yearIndex],
              let month = pickerInformation.months[safe: monthIndex],
              let selectedDate = "\(year)-\(month)"._date(dateFormat: .yearMonth)
        else {
            return
        }
        
        let differYear = selectedDate._component(.year) - CalendarCollectionViewCell.CurrentDate._component(.year)
        let differMonth = selectedDate._component(.month) - CalendarCollectionViewCell.CurrentDate._component(.month)
        let monthOffset = differYear * 12 + differMonth

        self.dismiss(animated: true) {
            self.myDelegte?.updateCalendar(currentDate: CalendarCollectionViewCell.CurrentDate, offset: monthOffset)
        }
    }
    
    @objc func cancelAction(_ item: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension DatePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0: return pickerInformation.years.count
        case 1: return pickerInformation.months.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        var text: String?
        
        switch component {
        case 0: text = pickerInformation.years[safe: row]
        case 1: text = pickerInformation.months[safe: row]
        default: text = nil
        }
        
        label.text = text
        label.font = UIFont.systemFont(ofSize: 36)
        label.sizeToFit()
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{ return 44 }
}
