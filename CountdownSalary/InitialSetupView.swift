//
//  InitialSetupView.swift
//  CountdownSalary
//
//  Created by yook on 2023/09/23.
//

import SwiftUI
import Combine

struct InitialSetupView: View {
    @ObservedObject var singleton: Singleton
    
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
    
    
    var body: some View {
        ScrollView {
            VStack {
                Text("월급 카운트다운을 위해 내 정보를 입력해주세요")
                    .padding()
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
                Spacer()
                HStack {
                    Spacer()
                    Button("Save") {
                        Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 0
                        Singleton.shared.userData.workdays = Int(workdaysText) ?? 0
                        Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 0
                        Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 0
                        Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 0
                        Singleton.shared.userData.salaryDate = Int(salaryDate) ?? 0
                        Singleton.shared.userData.isInitialSetupCompleted = true
                        Singleton.shared.save()
                        }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    // 모든 필드가 숫자로 변환 가능한 경우에만 버튼을 활성화
                    .disabled(!isNumber(yearIncomeText) || !isNumber(workdaysText) ||
                              !isNumber(dailyworksText) || !isNumber(startWorkTimeText)
                              || !isNumber(endWorkTimeText))

                }.padding()
                
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

