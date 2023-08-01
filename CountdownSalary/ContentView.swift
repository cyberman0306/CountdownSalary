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
                Text("Year income: \(Singleton.shared.userData.yearIncome)")
                Text("Workdays: \(Singleton.shared.userData.workdays)")
                Text("Daily works: \(Singleton.shared.userData.dailyworks)")
                Text("Start work time: \(Singleton.shared.userData.startWorkTime)")
                Text("End work time: \(Singleton.shared.userData.endWorkTime)")
                NavigationLink(destination: SettingView()) {
                    Text("Go to Setting")
                }
            }
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

    // 숫자로 변환 가능한지 검사하는 함수
    func isNumber(_ text: String) -> Bool {
        return Int(text) != nil
    }

    var body: some View {
        VStack {
            TextField("Year income", text: $yearIncomeText)
                .keyboardType(.numberPad)
            TextField("Workdays", text: $workdaysText)
                .keyboardType(.numberPad)
            TextField("Daily works", text: $dailyworksText)
                .keyboardType(.numberPad)
            TextField("Start work time", text: $startWorkTimeText)
                .keyboardType(.numberPad)
            TextField("End work time", text: $endWorkTimeText)
                .keyboardType(.numberPad)
            Button("Save") {
                Singleton.shared.userData.yearIncome = Int(yearIncomeText) ?? 0
                Singleton.shared.userData.workdays = Int(workdaysText) ?? 0
                Singleton.shared.userData.dailyworks = Int(dailyworksText) ?? 0
                Singleton.shared.userData.startWorkTime = Int(startWorkTimeText) ?? 0
                Singleton.shared.userData.endWorkTime = Int(endWorkTimeText) ?? 0
                Singleton.shared.save()
                self.presentationMode.wrappedValue.dismiss()
            }
            // 모든 필드가 숫자로 변환 가능한 경우에만 버튼을 활성화
            .disabled(!isNumber(yearIncomeText) || !isNumber(workdaysText) || !isNumber(dailyworksText) || !isNumber(startWorkTimeText) || !isNumber(endWorkTimeText))
        }
        .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
