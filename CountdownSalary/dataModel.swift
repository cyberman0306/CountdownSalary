//
//  dataModel.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import Foundation

struct UserData {
    var yearIncome: Int
    var workdays: Int
    var dailyworks: Int
    var startWorkTime: Int
    var endWorkTime: Int
}

class Singleton: ObservableObject {
    static let shared = Singleton()

    @Published var userData: UserData

    private init() {
        let yearIncome = UserDefaults.standard.integer(forKey: "YearIncome")
        let workdays = UserDefaults.standard.integer(forKey: "Workdays")
        let dailyworks = UserDefaults.standard.integer(forKey: "Dailyworks")
        let startWorkTime = UserDefaults.standard.integer(forKey: "StartWorkTime")
        let endWorkTime = UserDefaults.standard.integer(forKey: "EndWorkTime")
        userData = UserData(yearIncome: yearIncome, workdays: workdays, dailyworks: dailyworks, startWorkTime: startWorkTime, endWorkTime: endWorkTime)
    }
    // UserDefaults의 integer(forKey:) 메서드는 값을 반환할 수 없는 경우에는 0을 반환하므로, 옵셔널 처리나 기본값을 제공하는 것은 필요하지 않습니다. 따라서 ?? 0 부분은 필요하지 않습니다.


    func save() {
        UserDefaults.standard.set(userData.yearIncome, forKey: "YearIncome")
        UserDefaults.standard.set(userData.workdays, forKey: "Workdays")
        UserDefaults.standard.set(userData.dailyworks, forKey: "Dailyworks")
        UserDefaults.standard.set(userData.startWorkTime, forKey: "StartWorkTime")
        UserDefaults.standard.set(userData.endWorkTime, forKey: "EndWorkTime")
    }
}
