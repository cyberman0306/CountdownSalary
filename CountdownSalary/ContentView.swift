//
//  ContentView.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var singleton: Singleton
    @State private var currentTime = Date()

    var body: some View {
        let myInfo = singleton.userData
        NavigationStack {
            VStack {
//                ForEach([("Year income", myInfo.yearIncome, "만원"),
//                         ("Workdays", myInfo.workdays, "일"),
//                         ("Daily works", myInfo.dailyworks, "시간"),
//                         ("Start work time", myInfo.startWorkTime, "시작시간"),
//                         ("End work time", myInfo.endWorkTime, "퇴근시간"),
//                         ("salaryDate", myInfo.salaryDate, "월급날"),
//                        ], id: \.0) { text, value, sort in
//                    HStack {
//                        Text("\(value)")
//                            .font(.title)
//                            .fontWeight(.bold)
//                        //Spacer()
//                        Text(sort)
//                    }
//                    .padding()
//                }
                Text("오늘은 \(currentTime)")
                Spacer()
                //일급
                Text("오늘은 \(myInfo.yearIncome * 10000 / 12 /  myInfo.workdays )원 벌었네요")
                // 월급 디데이
                Text("월급날까지 \(daysUntilSalary(salaryDate: myInfo.salaryDate) ?? 0)일 남았네요")
                            
                //월급 초시계
                if let timeRemaining = timeUntilSalary(salaryDate: myInfo.salaryDate) {
                    Text("월급날까지 \(timeRemaining.days)일 \(timeRemaining.hours)시간 \(timeRemaining.minutes)분 \(timeRemaining.seconds)초 남았네요")
                }
                
                Spacer()
                
                NavigationLink(destination: SettingView()) {
                    Text("Go to Setting")
                        //.font(.title)
                        //.fontWeight(.bold)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding()
                .navigationViewStyle(StackNavigationViewStyle())

            }
            .padding()
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                        self.currentTime = Date()
            }
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
    
    private var userData: [(String, Binding<String>, String, String)] {
            [("Year income", $yearIncomeText, "내 연봉은", "만원"),
             ("Workdays", $workdaysText, "이번달은 며칠 일하나요", "시간"),
             ("Daily works", $dailyworksText, "하루에 몇 시간 일하나요", "시간"),
             ("Start work time", $startWorkTimeText, "출근 시간은", "시"),
             ("End work time", $endWorkTimeText, "퇴근 시간은 (예시: 18시)", "시"),
             ("Salary date", $salaryDate, "내 월급날은", "일")]
        }
    
    
    // 숫자로 변환 가능한지 검사하는 함수
    func isNumber(_ text: String) -> Bool {
        return Int(text) != nil
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(userData, id: \.0) { placeholder, textBinding, description, std in
                    VStack {
                        HStack {
                            Text(description)
                                .font(.body)
                               // .fontWeight(.bold)
                            //Spacer()
                        }
                        HStack {
                            TextField(placeholder, text: textBinding)
                                .onReceive(Just(textBinding.wrappedValue)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        textBinding.wrappedValue = filtered
                                    }
                                }
                                .keyboardType(.numberPad)
                                .font(.body)
                                .frame(width: 40, height: 5)
                                .multilineTextAlignment(.center)
                                .padding()
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.accentColor, lineWidth: 0.3)
//                                )
                                .background(
                                        // 밑줄을 추가
                                        Rectangle()
                                            .frame(height: 1)
                                            .shadow(color: .black, radius: 1, x: 0, y: 1) // 그림자 추가
                                    , alignment: .bottom)
                            Text(std)

                        }
                    
                    }
                    Divider()
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
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(5)
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
            .onAppear (perform : UIApplication.shared.hideKeyboard)
        }

    }
}
