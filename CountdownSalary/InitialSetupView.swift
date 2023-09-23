//
//  InitialSetupView.swift
//  CountdownSalary
//
//  Created by yook on 2023/09/23.
//

import SwiftUI

struct InitialSetupView: View {
    @ObservedObject var singleton: Singleton
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Setup Complete") {
            singleton.userData.isInitialSetupCompleted = true
            singleton.save()
        }
    }
}

