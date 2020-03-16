//
//  ViewController.swift
//  RecordCalendar
//
//  Created by 桑原望 on 2020/03/14.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

//ディスプレイサイズ取得
let w = UIScreen.main.bounds.size.width
let h = UIScreen.main.bounds.size.height

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    let labelDate = UILabel(frame: CGRect(x: 5, y: 500, width: 400, height: 50))
    let labelTitle = UILabel(frame: CGRect(x: 0, y: 530, width: 180, height: 50))
    
    let dateView = FSCalendar(frame: CGRect (x: 0, y: 30, width: w, height: 400))
    let Date = UILabel(frame: CGRect(x: 5, y: 430, width: 200, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //カレンダー設定
       self.dateView.dataSource = self
        self.dateView.delegate = self
        self.dateView.today = nil
       self.dateView.tintColor = .red
       self.view.backgroundColor = .white
        dateView.backgroundColor = .white
      //  カスタマイズしたviewを追加
       view.addSubview(dateView)
        //日付表示設定
        Date.text = ""
        Date.font = UIFont.systemFont(ofSize: 60.0)
        Date.textColor = .black
        view.addSubview(Date)
    
    //「主なスケジュール」表示設定
    labelTitle.text = ""
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont.systemFont(ofSize: 20.0)
        view.addSubview(labelTitle)
        //スケジュール内容表示設定
        labelDate.text = ""
        labelDate.font = UIFont.systemFont(ofSize: 18.0)
        view.addSubview(labelDate)
        //スケジュール追加ボタン
        let addBtn = UIButton(frame: CGRect(x: w - 70, y: h - 70, width: 60, height: 60))
        addBtn.setTitle("+", for: UIControl.State())
        addBtn.setTitleColor(.white, for: UIControl.State())
        addBtn.backgroundColor = .orange
        addBtn.layer.cornerRadius = 30.0
        addBtn.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        view.addSubview(addBtn)
    }
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    //祝日判定を行い結果を返す
    func judgeHoliday(_ date : Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        //祝日判定を行う日にちの年、月、に日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    //date型　-> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int) {
         let tmpCalendar = Calendar(identifier: .gregorian)
               //祝日判定を行う日にちの年、月、に日を取得
               let year = tmpCalendar.component(.year, from: date)
               let month = tmpCalendar.component(.month, from: date)
               let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    //曜日判定
    func getWeekIdx(_ date:Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    //土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定
        if self.judgeHoliday(date) {
            return UIColor.red
        }
        //土日の判定
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {
            return UIColor.red
        }
        else if weekday == 7 {
            return UIColor.blue
        }
        return nil
    }
    //スケジュール登録ページへ遷移
    @objc func onClick(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SecondController = storyboard.instantiateViewController(withIdentifier: "Insert")
        present(SecondController, animated: true, completion: nil)
    }
    //スケジュール表示
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        labelTitle.text = "主なスケジュール"
        labelTitle.backgroundColor = .orange
        view.addSubview(labelTitle)
    
    //予定がある場合、スケジュールをDBから取得し表示
    //無い場合、「スケジュールはありません」と表示
        labelDate.text = "スケジュールはありません"
        labelDate.textColor = .lightGray
        view.addSubview(labelDate)
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        let da = "\(year)/\(m)/\(d)"
        //クリックしたら日付が表示される
        Date.text = "\(m)/\(d)"
        view.addSubview(Date)
        //スケジュール取得
        let realm = try! Realm()
        var result = realm.objects(Event.self)
        result = result.filter("date = '\(da)'")
        print(result)
        for ev in result {
            if ev.date == da {
                
                labelDate.text = ev.event
                labelDate.textColor = .black
                view.addSubview(labelDate)
            }
        }
    }
  
        
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
    
       // return self.gregorian.isDateInToday(date) ? "今日" : nil
        let tmpDate = Calendar(identifier: .gregorian)
               let year = tmpDate.component(.year, from: date)
               let month = tmpDate.component(.month, from: date)
               let day = tmpDate.component(.day, from: date)
               let m = String(format: "%02d", month)
               let d = String(format: "%02d", day)
               let da = "\(year)/\(m)/\(d)"
//
       let realm = try! Realm()
              var result = realm.objects(Event.self)
              result = result.filter("date = '\(da)'")
              print(result)
              for ev in result {
                  if ev.date == da {
                    return ev.event
    }
    }
        return "0"
    
    }
//    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        let selectDay = getDay(date)
//    }

}
