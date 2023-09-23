//
//  CountdownSalaryApp.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import SwiftUI

@main
struct CountdownSalaryApp: App {
    @ObservedObject private var singleton = Singleton.shared
    
    var body: some Scene {
        WindowGroup {
            if singleton.userData.isInitialSetupCompleted {
                ContentView(singleton: singleton)
            } else {
                InitialSetupView(singleton: singleton) // 초기 설정 화면을 추가
            }
        }
    }
}

