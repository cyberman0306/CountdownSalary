//
//  countupView.swift
//  CountdownSalary
//
//  Created by yook on 11/9/24.
//
 

import SwiftUI

struct countupView: View {
    @State var targetValue: Int = 0
    @State var offset: [CGFloat] = [0, 0, 0, 0]
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 40) {
            HStack {
                SingleDigitView(offset: offset[0])
                SingleDigitView(offset: offset[1])
                SingleDigitView(offset: offset[2])
                SingleDigitView(offset: offset[3])
            }
            .frame(width: 200, height: 70)
            .overlay {
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                HStack(spacing: 63) {
//                    Rectangle().frame(width: 5, height: 65)
//                    Rectangle().frame(width: 5, height: 65)
                }
            }
            
            Button {
                startCounting()
            } label: {
                Text("Start Counting")
            }
            
            Button {
                stopCounting()
            } label: {
                Text("Stop Counting")
            }
            
        }
        .padding()
        .onAppear {
            startCounting()
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
        let digits = String(format: "%04d", targetValue).map { String($0) }
        withAnimation(.easeInOut(duration: 1.0)) {
            for (index, digit) in digits.enumerated() {
                offset[index] = CGFloat(Int(digit)!) * 70
            }
        }
    }
    
    func startCounting() {
        stopCounting() // 기존 타이머를 중지하여 중복 실행 방지
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            targetValue = (targetValue + 1) % 10000 // 0~999까지 반복
            setOffsets()
        }
    }
    
    func stopCounting() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    countupView()
}


/**
 랜덤숫자 메이커
 
 
 //
 //struct countupView: View {
 //    @State var targetValue: Int = 000
 //    @State var offset:[CGFloat] = [0,0,0]
 //
 //    var body: some View {
 //        VStack(spacing: 40) {
 //            HStack {
 //                SingleDigitView(offset: offset[0])
 //                SingleDigitView(offset: offset[1])
 //                SingleDigitView(offset: offset[2])
 //            }
 //            .frame(width: 200, height: 70)
 //            .overlay {
 //                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
 //                HStack(spacing: 63) {
 //                    Rectangle().frame(width: 5, height: 65)
 //                    Rectangle().frame(width: 5, height: 65)
 //                }
 //            }
 //
 //            Button {
 //                generateRandimNumber()
 //            } label: {
 //                Text("Generate Number")
 //            }
 //
 //        }
 //        .padding()
 //    }
 //    struct SingleDigitView: View {
 //        var offset:CGFloat = 0
 //        var body: some View {
 //            GeometryReader { geometry in
 //                VStack(spacing: 0) {
 //                    ForEach(0..<10) {number in
 //                        Text("\(number)").font(.largeTitle).bold()
 //                            .frame(width: geometry.size.width, height: geometry.size.height)
 //                    }
 //                }
 //                .offset(y: -offset)
 //            }
 //            .clipped()
 //        }
 //
 //
 //    }
 //    func setOffsets() {
 //        let digits = String(format: "%03d", targetValue).map{String($0)}
 //        withAnimation(.easeInOut(duration: 1.0)) {
 //            for (index, digit) in digits.enumerated(){
 //                offset [index] = CGFloat(Int(digit)!)*70
 //            }
 //        }
 //    }
 //    func generateRandimNumber() {
 //        targetValue = Int.random(in: 0...999)
 //        setOffsets()
 //    }
 //}
 //
 //#Preview {
 //    countupView()
 //}


 //
 //  countupView.swift
 //  CountdownSalary
 //
 //  Created by yook on 11/9/24.
 //
 
 
 
 */
