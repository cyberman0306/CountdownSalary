//
//  ContentView.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var singleton = Singleton.shared
    
    var body: some View {
        let myInfo = singleton.userData
        NavigationStack {
            VStack {
                ForEach([("Year income", myInfo.yearIncome, "만원"),
                         ("Workdays", myInfo.workdays, "일"),
                         ("Daily works", myInfo.dailyworks, "시간"),
                         ("Start work time", myInfo.startWorkTime, "시작시간"),
                         ("End work time", myInfo.endWorkTime, "퇴근시간"),
                         ("salaryDate", myInfo.salaryDate, "월급날"),
                        ], id: \.0) { text, value, sort in
                    HStack {
                        Text("\(value)")
                            .font(.title)
                            .fontWeight(.bold)
                        //Spacer()
                        Text(sort)
                    }
                    .padding()
                }
                Text("오늘은 \(myInfo.yearIncome * 10000 / 12 /  myInfo.workdays )원 벌었네요")
                //Text("오늘은 \(Date()), 월급날까지 일 남았네요")
                Text("오늘은 \(Date()), 월급날까지 \(daysUntilSalary(salaryDate: myInfo.salaryDate) ?? 0)일 남았네요")
                
                if let timeRemaining = timeUntilSalary(salaryDate: myInfo.salaryDate) {
                    Text("월급날까지 \(timeRemaining.days)일 \(timeRemaining.hours)시간 \(timeRemaining.minutes)분 \(timeRemaining.seconds)초 남았네요")
                }

                
                NavigationLink(destination: SettingView()) {
                    Text("Go to Setting")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .padding()
        }
    }
    
    func daysUntilSalary(salaryDate: Int) -> Int? {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘의 월과 연도를 가져옵니다.
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // 해당 월의 salaryDate를 기반으로 Date 구성
        var targetDateComponents = DateComponents(year: currentYear, month: currentMonth, day: salaryDate)
        
        // 만약 salaryDate가 오늘보다 지난 날짜라면, 다음 달로 설정
        if let targetDate = calendar.date(from: targetDateComponents), targetDate < today {
            targetDateComponents.month = currentMonth + 1
        }
        
        guard var finalTargetDate = calendar.date(from: targetDateComponents) else { return nil }
        
        // finalTargetDate의 시간을 해당 날의 마지막 시간으로 설정
        finalTargetDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: finalTargetDate)!
        
        // 두 날짜 간의 차이를 계산합니다.
        let daysUntil = calendar.dateComponents([.day], from: today, to: finalTargetDate)
        return daysUntil.day
    }

    
    func timeUntilSalary(salaryDate: Int) -> (days: Int, hours: Int, minutes: Int, seconds: Int)? {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘의 월과 연도를 가져옵니다.
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // 해당 월의 salaryDate를 기반으로 Date 구성
        var targetDateComponents = DateComponents(year: currentYear, month: currentMonth, day: salaryDate)
        
        // 만약 salaryDate가 오늘보다 지난 날짜라면, 다음 달로 설정
        if let targetDate = calendar.date(from: targetDateComponents), targetDate < today {
            targetDateComponents.month = currentMonth + 1
        }
        
        guard var finalTargetDateHMS = calendar.date(from: targetDateComponents) else { return nil }
        
        // finalTargetDate의 시간을 해당 날의 마지막 시간으로 설정
        //finalTargetDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: finalTargetDate)!
        
        // 두 날짜 간의 차이를 계산합니다.
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: today, to: finalTargetDateHMS)
        return (components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }

}


struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var yearIncomeText: String = "\(Singleton.shared.userData.yearIncome)"
    @State private var workdaysText: String = "\(Singleton.shared.userData.workdays)"
    @State private var dailyworksText: String = "\(Singleton.shared.userData.dailyworks)"
    @State private var startWorkTimeText: String = "\(Singleton.shared.userData.startWorkTime)"
    @State private var endWorkTimeText: String = "\(Singleton.shared.userData.endWorkTime)"
    @State private var salaryDate: String = "\(Singleton.shared.userData.salaryDate)"
    
    private var userData: [(String, Binding<String>, String)] {
            [("Year income", $yearIncomeText, "내 연봉은"),
             ("Workdays", $workdaysText, "이번달은 며칠 일하나요"),
             ("Daily works", $dailyworksText, "하루에 몇 시간 일하나요"),
             ("Start work time", $startWorkTimeText, "출근 시간은"),
             ("End work time", $endWorkTimeText, "퇴근 시간은"),
             ("Salary date", $salaryDate, "내 월급날은")]
        }
    
    
    // 숫자로 변환 가능한지 검사하는 함수
    func isNumber(_ text: String) -> Bool {
        return Int(text) != nil
    }
    
    var body: some View {
        
        VStack {
            ForEach(userData, id: \.0) { placeholder, textBinding, description in
                VStack {
                    HStack {
                        Text(description)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    TextField(placeholder, text: textBinding)
                        .keyboardType(.numberPad)
                        .font(.title)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
            
            Button("Save") {
                Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 0
                Singleton.shared.userData.workdays = Int(workdaysText) ?? 0
                Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 0
                Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 0
                Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 0
                Singleton.shared.userData.salaryDate = Int(salaryDate) ?? 0
                Singleton.shared.save()
                self.presentationMode.wrappedValue.dismiss()
            }
            .font(.title)
            .fontWeight(.bold)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            // 모든 필드가 숫자로 변환 가능한 경우에만 버튼을 활성화
            .disabled(!isNumber(yearIncomeText) || !isNumber(workdaysText) ||
                      !isNumber(dailyworksText) || !isNumber(startWorkTimeText)
                      || !isNumber(endWorkTimeText))
            
            if !isNumber(yearIncomeText) || !isNumber(workdaysText) ||
                !isNumber(dailyworksText) || !isNumber(startWorkTimeText) ||
                !isNumber(endWorkTimeText) {
                Text("숫자만 넣어줘요잉")
                    .foregroundColor(.red)
            }
            
        }
        .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
