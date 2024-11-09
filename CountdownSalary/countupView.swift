//
//  countupView.swift
//  CountdownSalary
//
//  Created by yook on 11/9/24.
//


import SwiftUI

struct countupView: View {
    @State var targetValue: Int = 0
    @State var offset: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0]
    @State private var timer: Timer?
    @State private var dailyIncome: String = "150000"  // 하루 수입 입력값
    @State private var workingHours: String = "8" // 하루 일하는 시간 입력값
    @State private var increment: Double = 0.0   // 초당 증가값
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            HStack{
                Text("하루 수입 ").font(.largeTitle).bold()
                TextField("", text: $dailyIncome).font(.title).bold()
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
                    .onChange(of: dailyIncome) { _ in calculateIncrement() }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                    }
                Text("원").font(.largeTitle).bold()
            }
            HStack{
                Text("하루 근무 ").font(.largeTitle).bold()
                TextField("", text: $workingHours).font(.title).bold()
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onChange(of: workingHours) { _ in calculateIncrement() }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                    }
                Text("시간").font(.largeTitle).bold()
            }
            HStack{
                Text("초급 \(Int(round(increment))) 원").font(.largeTitle).bold()
                 
            }
            Spacer()
            HStack {
                SingleDigitView(offset: offset[0])
                SingleDigitView(offset: offset[1])
                SingleDigitView(offset: offset[2])
                SingleDigitView(offset: offset[3])
                SingleDigitView(offset: offset[4])
                SingleDigitView(offset: offset[5])
                SingleDigitView(offset: offset[6])
                SingleDigitView(offset: offset[7])
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
        .onAppear {
            startCounting()
            calculateIncrement()
        }
        .onDisappear {
            stopCounting()
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
        stopCounting() // 기존 타이머를 중지하여 중복 실행 방지
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            targetValue = Int(round(Double(targetValue) + increment)) % 10000000 // 반올림하여 0~999까지 반복
            setOffsets()
        }
    }
    
    func stopCounting() {
        timer?.invalidate()
        timer = nil
    }
    func calculateIncrement() {
        // 하루 수입과 일하는 시간을 Double로 변환 후 계산
        if let income = Double(dailyIncome), let hours = Double(workingHours), hours > 0 {
            increment = income / hours / 3600 // 하루 수입 / 시간 / 60초
        }
    }
}

#Preview {
    countupView()
}


