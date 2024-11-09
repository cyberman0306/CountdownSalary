//  ContentView.swift
//  CountdownSalary
//  Created by yook on 2023/07/31.
import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var singleton: Singleton
    @State private var currentTime = Date()
    
    var body: some View {
        let myInfo = singleton.userData
        var YearStdDayIncome = (myInfo.yearIncome * 10000 / 12 /  myInfo.workdays)
        var monthStdDayIncome = (myInfo.monthlyIncome * 10000 / myInfo.workdays)
        var hourStdDayIncome = (myInfo.hourlyIncome *  myInfo.monthlyWorkHours)
        NavigationStack {
            VStack(alignment: .leading) {
                Text("오늘은 \(currentTime)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                if myInfo.salaryType == .annualSalary {
                    //연봉
                    Text("😁오늘은 \(YearStdDayIncome)원 벌었네요")
                    
                    Spacer()
                    Text("오늘 번 시급 \(YearStdDayIncome / (myInfo.endWorkTime - myInfo.startWorkTime))원")
                    Text("오늘 번 분급 \(YearStdDayIncome / (myInfo.endWorkTime - myInfo.startWorkTime) / 60)원")
                    Text("오늘 번 초급 \(YearStdDayIncome / (myInfo.endWorkTime - myInfo.startWorkTime) / 60 / 60)원")
                    
                } else if myInfo.salaryType == .monthlySalary {
                    //월급
                    Text("😁오늘은 \(monthStdDayIncome)원 벌었네요")
                } else if myInfo.salaryType == .hourlyWage {
                    //시급
                    Text("😁이번달은 \(hourStdDayIncome)원 벌었네요")
                    // 시급의 경우 한달기준인지 하루기준인지 디스플레이 기준을 정해야함
                }
                
                Spacer()
                // 월급 디데이
                Text("🏃월급날까지 앞으로 \(daysUntilSalary(salaryDate: myInfo.salaryDate) ?? 0)일")
                Spacer()
                //월급 초시계
                if let timeRemaining = timeUntilSalary(salaryDate: myInfo.salaryDate) {
                    Text("⏱️월급날까지 앞으로 \(timeRemaining.days)일 \(timeRemaining.hours)시간 \(timeRemaining.minutes)분 \(timeRemaining.seconds)초")
                }
                Spacer()
            }
            .padding()
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                self.currentTime = Date()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView(singleton: singleton)) {
                        Text("설정")
                    }.navigationViewStyle(StackNavigationViewStyle())
                }
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
        
        guard let finalTargetDateHMS = calendar.date(from: targetDateComponents) else { return nil }
        
        // 두 날짜 간의 차이를 계산합니다.
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: today, to: finalTargetDateHMS)
        return (components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }
    
}


#Preview {
    @ObservedObject var singleton = Singleton.shared
    ContentView(singleton: singleton)
}
