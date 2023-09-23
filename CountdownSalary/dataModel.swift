//
//  dataModel.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import Foundation

struct UserData {
    var yearIncome: Int = 5000
    var workdays: Int = 21
    var dailyworks: Int = 8
    var startWorkTime: Int = 9
    var endWorkTime: Int = 18
    var salaryDate: Int = 25
    var isInitialSetupCompleted: Bool = false
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
        let salaryDate = UserDefaults.standard.integer(forKey: "salaryDate")
        let isInitialSetupCompleted = UserDefaults.standard.bool(forKey: "isInitialSetupCompleted")
        
        userData = UserData(
                yearIncome: yearIncome == 0 ? UserData().yearIncome : yearIncome,
                workdays: workdays == 0 ? UserData().workdays : workdays,
                dailyworks: dailyworks == 0 ? UserData().dailyworks : dailyworks,
                startWorkTime: startWorkTime == 0 ? UserData().startWorkTime : startWorkTime,
                endWorkTime: endWorkTime == 0 ? UserData().endWorkTime : endWorkTime,
                salaryDate: salaryDate == 0 ? UserData().salaryDate : salaryDate,
                isInitialSetupCompleted: isInitialSetupCompleted
            )
    }


    func save() {
        UserDefaults.standard.set(userData.yearIncome, forKey: "YearIncome")
        UserDefaults.standard.set(userData.workdays, forKey: "Workdays")
        UserDefaults.standard.set(userData.dailyworks, forKey: "Dailyworks")
        UserDefaults.standard.set(userData.startWorkTime, forKey: "StartWorkTime")
        UserDefaults.standard.set(userData.endWorkTime, forKey: "EndWorkTime")
        UserDefaults.standard.set(userData.salaryDate, forKey: "salaryDate")
        UserDefaults.standard.set(userData.isInitialSetupCompleted, forKey: "isInitialSetupCompleted")
    }
}
