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
        print("Current Time (Device Time Zone):", Date())
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
        resetToToday() // workingStartTime과 workingEndTime 날짜를 오늘로 고정
        let workingSeconds = workingEndTime.timeIntervalSince(workingStartTime)
        increment = (workingSeconds > 0) ? dailyIncome / workingSeconds : 0

        print("Working Start Time: \(workingStartTime)")
        print("Working End Time: \(workingEndTime)")
        print("Working seconds: \(workingSeconds)")
        print("Increment (dailyIncome / workingSeconds): \(increment)")
    }

    func resetToToday() {
        let currentDate = Date()
        let calendar = Calendar.current

        // workingStartTime을 오늘 날짜로 설정
        let startHour = calendar.component(.hour, from: workingStartTime)
        let startMinute = calendar.component(.minute, from: workingStartTime)
        print("startHour: \(startHour)")
        print("startMinute: \(startMinute)")
        workingStartTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: currentDate)!

        // workingEndTime을 오늘 날짜로 설정
        let endHour = calendar.component(.hour, from: workingEndTime)
        let endMinute = calendar.component(.minute, from: workingEndTime)
        workingEndTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: currentDate)!
    }

    
    func updateElapsedIncome() {
        let currentTime = Date()
        let calendar = Calendar.current
        
        // 근무 시간의 오늘 날짜를 기준으로 설정
        let todayStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: workingStartTime),
                                           minute: calendar.component(.minute, from: workingStartTime),
                                           second: 0,
                                           of: currentTime) ?? workingStartTime
        
        let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: workingEndTime),
                                         minute: calendar.component(.minute, from: workingEndTime),
                                         second: 0,
                                         of: currentTime) ?? workingEndTime

        if currentTime >= todayStartTime && currentTime <= todayEndTime {
            let elapsedSeconds = currentTime.timeIntervalSince(todayStartTime)
            elapsedTimeIncome = increment * elapsedSeconds
            print("Elapsed Seconds: \(elapsedSeconds)")
            print("Elapsed Time Income: \(elapsedTimeIncome)")

        } else {
            elapsedTimeIncome = currentTime < todayStartTime ? 0 : dailyIncome
            print("Elapsed Time Income: \(elapsedTimeIncome)")
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
                data.resetToToday()
                data.calculateIncrement()
                startCounting()
            }

            
            .onDisappear {
                print("ondisappear")
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
    func resetCountIfNeeded() {
        let currentTime = Date()
        let calendar = Calendar.current

        let todayStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: data.workingStartTime),
                                           minute: calendar.component(.minute, from: data.workingStartTime),
                                           second: 0,
                                           of: currentTime) ?? data.workingStartTime
        
        let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: data.workingEndTime),
                                         minute: calendar.component(.minute, from: data.workingEndTime),
                                         second: 0,
                                         of: currentTime) ?? data.workingEndTime

        print("Today Start Time: \(todayStartTime)")
        print("Today End Time: \(todayEndTime)")
        print("Current Time: \(currentTime)")

        
        // 근무 시작 전 초기화
        if currentTime < todayStartTime {
            targetValue = 0
            data.elapsedTimeIncome = 0.0
            setOffsets()
            stopCounting()
        }
        // 근무 종료 후 타이머 멈춤
        else if currentTime > todayEndTime {
            stopCounting()
        }
    }

    
    func startCounting() {
        stopCounting() // 기존 타이머를 중지하여 중복 실행 방지
        print("Working Start Time: \(data.workingStartTime)")
           print("Working End Time: \(data.workingEndTime)")
           print("Daily Income: \(data.dailyIncome)")
           print("Increment: \(data.increment)")
        // 타이머 시작 전에 초기 targetValue를 elapsedTimeIncome로 설정
        data.updateElapsedIncome() // 누적 수입 최신화
//        resetCountIfNeeded() // 초기화 체크
        
        
        let currentTime = Date()
        let calendar = Calendar.current

        let todayStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: data.workingStartTime),
                                           minute: calendar.component(.minute, from: data.workingStartTime),
                                           second: 0,
                                           of: currentTime) ?? data.workingStartTime
        
        let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: data.workingEndTime),
                                         minute: calendar.component(.minute, from: data.workingEndTime),
                                         second: 0,
                                         of: currentTime) ?? data.workingEndTime

        // 근무 시작 전 초기화
        if currentTime < todayStartTime {
            targetValue = 0
            data.elapsedTimeIncome = 0.0
            setOffsets()
            stopCounting()
            return
        }
        // 근무 종료 후 타이머 멈춤
        else if currentTime > todayEndTime {
            stopCounting()
            return
        }
        
        
        
        
        
        
        
        targetValue = Int(round(data.elapsedTimeIncome))
        setOffsets()
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let currentTime = Date()

            // 종료 시간을 초과한 경우 타이머 중지
            let calendar = Calendar.current
            let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: data.workingEndTime),
                                             minute: calendar.component(.minute, from: data.workingEndTime),
                                             second: 0,
                                             of: currentTime) ?? data.workingEndTime
            
            if currentTime >= todayEndTime {
                stopCounting()
                return
            }

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


