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
        NavigationView {
            VStack {
                ForEach([("Year income", singleton.userData.yearIncome),
                         ("Workdays", singleton.userData.workdays),
                         ("Daily works", singleton.userData.dailyworks),
                         ("Start work time", singleton.userData.startWorkTime),
                         ("End work time", singleton.userData.endWorkTime)], id: \.0) { text, value in
                    HStack {
                        Text("\(text): \(value)")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Text("만원")
                    }
                    .padding()
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
            }
            .padding()
        }
    }
}


struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var yearIncomeText: String = "\(Singleton.shared.userData.yearIncome)"
    @State private var workdaysText: String = "\(Singleton.shared.userData.workdays)"
    @State private var dailyworksText: String = "\(Singleton.shared.userData.dailyworks)"
    @State private var startWorkTimeText: String = "\(Singleton.shared.userData.startWorkTime)"
    @State private var endWorkTimeText: String = "\(Singleton.shared.userData.endWorkTime)"
    
    private var userData: [(String, Binding<String>)] {
        [("Year income", $yearIncomeText),
         ("Workdays", $workdaysText),
         ("Daily works", $dailyworksText),
         ("Start work time", $startWorkTimeText),
         ("End work time", $endWorkTimeText)]
    }
    
    
    // 숫자로 변환 가능한지 검사하는 함수
    func isNumber(_ text: String) -> Bool {
        return Int(text) != nil
    }
    
    var body: some View {
        VStack {
            ForEach(userData, id: \.0) { placeholder, textBinding in
                HStack {
                    TextField(placeholder, text: textBinding)
                        .keyboardType(.numberPad)
                        .font(.title)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    Text("만원")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            
            Button("Save") {
                Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 0
                Singleton.shared.userData.workdays = Int(workdaysText) ?? 0
                Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 0
                Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 0
                Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 0
                Singleton.shared.save()
                self.presentationMode.wrappedValue.dismiss()
            }
            .font(.title)
            .fontWeight(.bold)
            .padding()
            // 모든 필드가 숫자로 변환 가능한 경우에만 버튼을 활성화
            .disabled(!isNumber(yearIncomeText) || !isNumber(workdaysText) || !isNumber(dailyworksText) || !isNumber(startWorkTimeText) || !isNumber(endWorkTimeText))
            
            if !isNumber(yearIncomeText) || !isNumber(workdaysText) || !isNumber(dailyworksText) || !isNumber(startWorkTimeText) || !isNumber(endWorkTimeText) {
                Text("숫자만 넣어줘요잉")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
