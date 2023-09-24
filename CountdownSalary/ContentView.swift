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
        var YearStdDayIncome = (myInfo.yearIncome * 10000 / 12 /  myInfo.workdays)
        var monthStdDayIncome = (myInfo.monthlyIncome * 10000 / myInfo.workdays)
        var hourStdDayIncome = (myInfo.hourlyIncome *  myInfo.monthlyWorkHours)
        NavigationStack {
            VStack(alignment: .leading) {
                
                Text("오늘은 \(currentTime)")
                Spacer()
                
                if myInfo.salaryType == .annualSalary {
                    //연봉
                    Text("오늘은 \(YearStdDayIncome)원 벌었네요😁")
                } else if myInfo.salaryType == .monthlySalary {
                    //월급
                    Text("오늘은 \(monthStdDayIncome)원 벌었네요😁")
                } else if myInfo.salaryType == .hourlyWage {
                    //시급
                    Text("오늘은 \(hourStdDayIncome)원 벌었네요😁")
                }
                Spacer()
                // 월급 디데이
                Text("월급날까지 \(daysUntilSalary(salaryDate: myInfo.salaryDate) ?? 0)일 남았네요🏃")
                Spacer()
                //월급 초시계
                if let timeRemaining = timeUntilSalary(salaryDate: myInfo.salaryDate) {
                    Text("월급날까지 \(timeRemaining.days)일 \(timeRemaining.hours)시간 \(timeRemaining.minutes)분 \(timeRemaining.seconds)초 남았네요⏱️")
                }
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: SettingView(singleton: singleton)) {
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
    @ObservedObject var singleton: Singleton
    @Environment(\.presentationMode) var presentationMode
    
    @State private var yearIncomeText: String = "\(Singleton.shared.userData.yearIncome)"
    @State private var monthlyIncomeText: String = "\(Singleton.shared.userData.monthlyIncome)"
    @State private var hourlyIncomeText: String = "\(Singleton.shared.userData.hourlyIncome)"
    @State private var workdaysText: String = "\(Singleton.shared.userData.workdays)"
    @State private var dailyworksText: String = "\(Singleton.shared.userData.dailyworks)"
    @State private var startWorkTimeText: String = "\(Singleton.shared.userData.startWorkTime)"
    @State private var endWorkTimeText: String = "\(Singleton.shared.userData.endWorkTime)"
    @State private var salaryDate: String = "\(Singleton.shared.userData.salaryDate)"
    @State private var selectedSalaryType: SalaryType = Singleton.shared.userData.salaryType
    @State private var monthlyWorkHours: String = "\(Singleton.shared.userData.monthlyWorkHours)"

    private var userData: [(String, Binding<String>, String, String, [Int])] {
        [
        ("Workdays", $workdaysText, "이번달은 며칠 일하나요", "일", Array(1..<31)),
         ("Daily works", $dailyworksText, "하루에 몇 시간 일하나요", "시간", Array(1..<24)),
         ("Daily works", $monthlyWorkHours, "한달에 몇 시간 일하나요", "시간", Array(1..<720)),
         ("Start work time", $startWorkTimeText, "출근 시간은", "시", Array(0..<24)),
         ("End work time", $endWorkTimeText, "퇴근 시간은 (예시: 18시)", "시", Array(0..<24)),
         ("Salary date", $salaryDate, "내 월급날은", "일", Array(0..<28))]
    }
    
    var body: some View {
        let myInfo = singleton.userData
        ScrollView {
            VStack {
                Picker("급여 유형 선택", selection: $selectedSalaryType) {
                    Text("연봉").tag(SalaryType.annualSalary)
                    Text("월급").tag(SalaryType.monthlySalary)
                    Text("시급").tag(SalaryType.hourlyWage)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedSalaryType) { newValue in
                    singleton.updateSalaryType(newValue)
                }
                if myInfo.salaryType == .annualSalary {
                    
                    Text("내 연봉은")
                    HStack {
                        TextField("내 연봉은", text: $yearIncomeText)
                            .onReceive(Just($yearIncomeText.wrappedValue)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    $yearIncomeText.wrappedValue = filtered
                                }
                            }
                            .keyboardType(.numberPad)
                            .font(.body)
                            .frame(width: 40, height: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                // 밑줄을 추가
                                Rectangle()
                                    .frame(height: 1)
                                    .shadow(color: .black, radius: 1, x: 0, y: 1) // 그림자 추가
                                , alignment: .bottom)
                        Text("만원")
                    }

                    Divider()
                    
                    ForEach([userData[0], userData[1], userData[3], userData[4], userData[5]], id: \.0)
                    { placeholder, textBinding, description, std, limit in
                        VStack {
                            HStack {
                                Text(description)
                                    .font(.body)
                             
                            }
                            HStack {
                                // String을 Int로 변환
                                let intValue = Binding<Int>(
                                    get: {
                                        Int(textBinding.wrappedValue) ?? 0
                                    },
                                    set: {
                                        textBinding.wrappedValue = "\($0)"
                                    }
                                )
                                Picker(selection: intValue, label: Text(description)) {
                                    ForEach(limit, id: \.self) { num in
                                        Text("\(num)").tag(num) // tag의 값을 Int로 설정
                                    }
                                }
                               .frame(width: 50, height: 100)
                               .clipped()
                               .pickerStyle(WheelPickerStyle())
                                Text(std)
                                
                            }
                            
                        }
                        Divider()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Save") {
                            Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 3500
                            Singleton.shared.userData.workdays = Int(workdaysText) ?? 21
                            Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 8
                            Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 9
                            Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 18
                            Singleton.shared.userData.salaryDate = Int(salaryDate) ?? 25
                            Singleton.shared.userData.salaryType = selectedSalaryType
                            Singleton.shared.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        
                    }.padding()
                    
                } else if myInfo.salaryType == .monthlySalary {
                    Text("내 월급은")
                    HStack {
                        TextField("내 월급은", text: $monthlyIncomeText)
                            .onReceive(Just($monthlyIncomeText.wrappedValue)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    $monthlyIncomeText.wrappedValue = filtered
                                }
                            }
                            .keyboardType(.numberPad)
                            .font(.body)
                            .frame(width: 40, height: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                // 밑줄을 추가
                                Rectangle()
                                    .frame(height: 1)
                                    .shadow(color: .black, radius: 1, x: 0, y: 1) // 그림자 추가
                                , alignment: .bottom)
                        Text("만원")
                    }

                    Divider()
                    
                    ForEach([userData[0], userData[1], userData[3], userData[4], userData[5]], id: \.0) { placeholder, textBinding, description, std, limit in
                        VStack {
                            HStack {
                                Text(description)
                                    .font(.body)
                             
                            }
                            HStack {
                                // String을 Int로 변환
                                let intValue = Binding<Int>(
                                    get: {
                                        Int(textBinding.wrappedValue) ?? 0
                                    },
                                    set: {
                                        textBinding.wrappedValue = "\($0)"
                                    }
                                )
                                Picker(selection: intValue, label: Text(description)) {
                                    ForEach(limit, id: \.self) { num in
                                        Text("\(num)").tag(num) // tag의 값을 Int로 설정
                                    }
                                }
                               .frame(width: 50, height: 100)
                               .clipped()
                               .pickerStyle(WheelPickerStyle())
                                Text(std)
                                
                            }
                            
                        }
                        Divider()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Save") {
                            Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 3500
                            Singleton.shared.userData.monthlyIncome = Int(monthlyIncomeText) ?? 235
                            Singleton.shared.userData.workdays = Int(workdaysText) ?? 21
                            Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 8
                            Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 9
                            Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 18
                            Singleton.shared.userData.salaryDate = Int(salaryDate) ?? 25
                            Singleton.shared.userData.salaryType = selectedSalaryType
                            Singleton.shared.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        
                    }.padding()
                } else if myInfo.salaryType == .hourlyWage {
                    Text("내 시급은")
                    HStack {
                        TextField("내 시급은", text: $hourlyIncomeText)
                            .onReceive(Just($hourlyIncomeText.wrappedValue)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    $hourlyIncomeText.wrappedValue = filtered
                                }
                            }
                            .keyboardType(.numberPad)
                            .font(.body)
                            .frame(width: 40, height: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                // 밑줄을 추가
                                Rectangle()
                                    .frame(height: 1)
                                    .shadow(color: .black, radius: 1, x: 0, y: 1) // 그림자 추가
                                , alignment: .bottom)
                        Text("원")
                    }

                    Divider()
                    
                    ForEach([userData[2], userData[3], userData[4], userData[5]], id: \.0) { placeholder, textBinding, description, std, limit in
                        VStack {
                            HStack {
                                Text(description)
                                    .font(.body)
                             
                            }
                            HStack {
                                // String을 Int로 변환
                                let intValue = Binding<Int>(
                                    get: {
                                        Int(textBinding.wrappedValue) ?? 0
                                    },
                                    set: {
                                        textBinding.wrappedValue = "\($0)"
                                    }
                                )
                                Picker(selection: intValue, label: Text(description)) {
                                    ForEach(limit, id: \.self) { num in
                                        Text("\(num)").tag(num) // tag의 값을 Int로 설정
                                    }
                                }
                               .frame(width: 100, height: 100)
                               .clipped()
                               .pickerStyle(WheelPickerStyle())
                                Text(std)
                                
                            }
                            
                        }
                        Divider()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Save") {
                            Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 3500
                            Singleton.shared.userData.monthlyIncome = Int(monthlyIncomeText) ?? 235
                            Singleton.shared.userData.hourlyIncome = Int(hourlyIncomeText) ?? 235
                            Singleton.shared.userData.monthlyWorkHours = Int(monthlyWorkHours) ?? 160
                            Singleton.shared.userData.workdays = Int(workdaysText) ?? 21
                            Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 8
                            Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 9
                            Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 18
                            Singleton.shared.userData.salaryDate = Int(salaryDate) ?? 25
                            Singleton.shared.userData.salaryType = selectedSalaryType
                            Singleton.shared.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        
                    }.padding()
                } else {
                    Text("error!")
                }
                
            }
            .padding()
            .onAppear (perform : UIApplication.shared.hideKeyboard)
        }
        
    }
}
