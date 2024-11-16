//
//  countupView.swift
//  CountdownSalary
//
//  Created by yook on 11/9/24.
//


import SwiftUI


// 데이터 모델
class CountupData: ObservableObject {
    @Published var dailyIncome: Double {
        didSet { saveSettings() }
    }
    @Published var workingStartTime: Date {
        didSet { saveSettings() }
    }
    @Published var workingEndTime: Date {
        didSet { saveSettings() }
    }
    @Published var increment: Double = 0.0
    @Published var elapsedTimeIncome: Double = 0.0
    
    init() {
        let savedData = UserDefaults.standard
        self.dailyIncome = savedData.double(forKey: "dailyIncome") == 0 ? 150000 : savedData.double(forKey: "dailyIncome")
        self.workingStartTime = savedData.object(forKey: "workingStartTime") as? Date ?? Calendar.current.startOfDay(for: Date())
        self.workingEndTime = savedData.object(forKey: "workingEndTime") as? Date ?? Calendar.current.date(byAdding: .hour, value: 8, to: Calendar.current.startOfDay(for: Date()))!
        calculateIncrement()
        updateElapsedIncome()
    }
    
    func saveSettings() {
        let savedData = UserDefaults.standard
        savedData.set(dailyIncome, forKey: "dailyIncome")
        savedData.set(workingStartTime, forKey: "workingStartTime")
        savedData.set(workingEndTime, forKey: "workingEndTime")
        calculateIncrement()
    }
    
    func calculateIncrement() {
        let workingSeconds = workingEndTime.timeIntervalSince(workingStartTime)
        increment = (workingSeconds > 0) ? dailyIncome / workingSeconds : 0
    }
    
    func updateElapsedIncome() {
        let currentTime = Date()
        if currentTime >= workingStartTime && currentTime <= workingEndTime {
            let elapsedSeconds = currentTime.timeIntervalSince(workingStartTime)
            elapsedTimeIncome = increment * elapsedSeconds
        } else {
            elapsedTimeIncome = currentTime < workingStartTime ? 0 : dailyIncome
        }
    }
}


struct CountupView: View {
    @EnvironmentObject var data: CountupData
    @State private var targetValue: Int = 0
    @State private var offset: [CGFloat] = [CGFloat](repeating: 0, count: 8)
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                HStack {
                    ForEach(0..<8) { index in
                        SingleDigitView(offset: offset[index])
                    }
                    Text("₩").font(.title).bold()
                }
                .frame(width: 310, height: 70)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                }
//                Text("지금까지: \(Int(data.elapsedTimeIncome)) 원").font(.title2)
                Spacer()
                
                Text("초당 \(Int(round(data.increment))) 원").font(.title)
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            )
            .onAppear {
                data.updateElapsedIncome() // 초기 근무 시간 기반 누적 수입 계산
                startCounting()           // 타이머 시작 및 동기화
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
        stopCounting() // 기존 타이머를 중지하여 중복 실행 방지

        // 타이머 시작 전에 초기 targetValue를 elapsedTimeIncome로 설정
        data.updateElapsedIncome() // 누적 수입 최신화
        targetValue = Int(round(data.elapsedTimeIncome))
        setOffsets()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // 초당 금액 계산
            let incrementValue = Int(round(data.increment))
            targetValue = (targetValue + incrementValue) % 10000000
            setOffsets()
            
            // 누적 금액 업데이트
            data.elapsedTimeIncome = Double(targetValue)
        }
    }



    
    func stopCounting() {
        timer?.invalidate()
        timer = nil
    }
}

struct SettingsView: View {
    @EnvironmentObject var data: CountupData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("하루 수입 설정")) {
                TextField("수입 (원)", value: $data.dailyIncome, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }
            Section(header: Text("근무 시간 설정")) {
                DatePicker("시작 시간", selection: $data.workingStartTime, displayedComponents: .hourAndMinute)
                    .onChange(of: data.workingStartTime) { _ in
                        if data.workingEndTime <= data.workingStartTime {
                            data.workingEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: data.workingStartTime) ?? data.workingStartTime
                        }
                    }
                DatePicker("종료 시간", selection: $data.workingEndTime, displayedComponents: .hourAndMinute)
                    .onChange(of: data.workingEndTime) { _ in
                        if data.workingEndTime <= data.workingStartTime {
                            data.workingStartTime = Calendar.current.date(byAdding: .hour, value: -1, to: data.workingEndTime) ?? data.workingEndTime
                        }
                    }
            }
        }
        .navigationTitle("설정")
        .navigationBarItems(trailing: Button("완료") {
            data.calculateIncrement()
            presentationMode.wrappedValue.dismiss()
        }
        )
        
    }
}
#Preview {
    CountupView()
}


