//
//  countupView.swift
//  CountdownSalary
//
//  Created by yook on 11/9/24.
//


import SwiftUI

// 데이터 모델
class CountupData: ObservableObject {
    @Published var dailyIncome: Double = 150000 // 하루 수입
    @Published var workingHours: Double = 8     // 하루 근무 시간
    @Published var increment: Double = 0.0      // 초당 증가값
    
    func calculateIncrement() {
        guard workingHours > 0 else { increment = 0; return }
        increment = dailyIncome / workingHours / 3600
    }
}


struct CountupView: View {
    @State var targetValue: Int = 0
    @State var offset: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0]
    @State private var timer: Timer?
    @EnvironmentObject var data: CountupData // 데이터 공유
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                Text("초당 \(Int(round(data.increment))) 원").font(.largeTitle).bold()
                Spacer()
                HStack {
                    ForEach(0..<8) { index in
                        SingleDigitView(offset: offset[index])
                    }
                    Text("원").font(.largeTitle).bold()
                }
                .frame(width: 310, height: 70)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("카운트업")
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title)
                }
            )
            .onAppear {
                startCounting()
            }
            .onDisappear {
                stopCounting()
            }
        }
    }
    
    struct SingleDigitView: View {
        var offset: CGFloat = 0
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<10) { number in
                        Text("\(number)").font(.largeTitle).bold()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .offset(y: -offset)
            }
            .clipped()
        }
    }
    
    func setOffsets() {
        let digits = String(format: "%08d", targetValue).map { String($0) }
        withAnimation(.easeInOut(duration: 1.0)) {
            for (index, digit) in digits.enumerated() {
                offset[index] = CGFloat(Int(digit)!) * 70
            }
        }
    }
    
    func startCounting() {
        stopCounting() // 기존 타이머 중지
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            targetValue = Int(round(Double(targetValue) + data.increment)) % 10000000
            setOffsets()
        }
    }
    
    func stopCounting() {
        timer?.invalidate()
        timer = nil
    }
}

// 설정 화면
struct SettingsView: View {
    @EnvironmentObject var data: CountupData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("하루 수입 설정")) {
                TextField("수입 (원)", value: $data.dailyIncome, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("하루 근무 시간 설정")) {
                TextField("근무 시간 (시간)", value: $data.workingHours, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("설정")
        .navigationBarItems(trailing: Button("완료") {
            data.calculateIncrement()
            presentationMode.wrappedValue.dismiss()
        })
    }
}

#Preview {
    CountupView()
}


