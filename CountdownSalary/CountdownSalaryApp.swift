//
//  CountdownSalaryApp.swift
//  CountdownSalary
//
//  Created by yook on 2023/07/31.
//

import SwiftUI

@main
struct CountdownSalaryApp: App {
    @StateObject private var data = CountupData()
    var body: some Scene {
        WindowGroup {
            CountupView()
                .environmentObject(data)
        }
    }
}

