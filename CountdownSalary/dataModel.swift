//
//  dataModel.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import Foundation

enum SalaryType: String, Codable {
    case annualSalary // 연봉
    case monthlySalary // 월급
    case hourlyWage // 시급
}

struct UserData: Codable {
    var salaryType: SalaryType = .annualSalary
    var yearIncome: Int = 5000
    var monthlyIncome: Int = 315
    var hourlyIncome: Int = 9800
    var workdays: Int = 21
    var dailyworks: Int = 8
    var startWorkTime: Int = 9
    var endWorkTime: Int = 18
    var salaryDate: Int = 25
    var isInitialSetupCompleted: Bool = false
    var monthlyWorkHours: Int = 160
    
    
}

class Singleton: ObservableObject {
    static let shared = Singleton()

    @Published var userData: UserData

    private init() {
        let load = UserDefaults.standard
        let yearIncome = load.integer(forKey: "YearIncome")
        let monthlyIncome = load.integer(forKey: "monthlyIncome")
        let hourlyIncome = load.integer(forKey: "hourlyIncome")
        let workdays = load.integer(forKey: "Workdays")
        let dailyworks = load.integer(forKey: "Dailyworks")
        let startWorkTime = load.integer(forKey: "StartWorkTime")
        let endWorkTime = load.integer(forKey: "EndWorkTime")
        let salaryDate = load.integer(forKey: "salaryDate")
        let isInitialSetupCompleted = load.bool(forKey: "isInitialSetupCompleted")
        let salaryTypeString = load.string(forKey: "salaryType") ?? SalaryType.annualSalary.rawValue
        let salaryType = SalaryType(rawValue: salaryTypeString) ?? .annualSalary
        let monthlyWorkHours = load.integer(forKey: "monthlyWorkHours")
               
        //SalaryType enum은 String을 원시 값으로 가지고 있으므로, 이 값을 UserDefaults에 저장하거나 읽을 때는 rawValue를 사용해야 합니다.
        
        userData = UserData(
                    salaryType: salaryType,
                    yearIncome: yearIncome == 0 ? UserData().yearIncome : yearIncome,
                    monthlyIncome: monthlyIncome == 0 ? UserData().monthlyIncome : monthlyIncome,
                    hourlyIncome: monthlyIncome == 0 ? UserData().hourlyIncome : monthlyIncome,
                    workdays: workdays == 0 ? UserData().workdays : workdays,
                    dailyworks: dailyworks == 0 ? UserData().dailyworks : dailyworks,
                    startWorkTime: startWorkTime == 0 ? UserData().startWorkTime : startWorkTime,
                    endWorkTime: endWorkTime == 0 ? UserData().endWorkTime : endWorkTime,
                    salaryDate: salaryDate == 0 ? UserData().salaryDate : salaryDate,
                    isInitialSetupCompleted: isInitialSetupCompleted,
                    monthlyWorkHours: monthlyWorkHours == 0 ? UserData().monthlyWorkHours : monthlyWorkHours
                )
        
 
    }


    func save() {
        let save = UserDefaults.standard
        save.set(userData.yearIncome, forKey: "YearIncome")
        save.set(userData.monthlyIncome, forKey: "monthlyIncome")
        save.set(userData.hourlyIncome, forKey: "hourlyIncome")
        save.set(userData.workdays, forKey: "Workdays")
        save.set(userData.dailyworks, forKey: "Dailyworks")
        save.set(userData.startWorkTime, forKey: "StartWorkTime")
        save.set(userData.endWorkTime, forKey: "EndWorkTime")
        save.set(userData.salaryDate, forKey: "salaryDate")
        save.set(userData.isInitialSetupCompleted, forKey: "isInitialSetupCompleted")
        save.set(userData.salaryType.rawValue, forKey: "salaryType")
        save.set(userData.monthlyWorkHours, forKey: "monthlyWorkHours")
    }
    
    func updateSalaryType(_ type: SalaryType) {
        userData.salaryType = type
        save()
    }
}
