//
//  ChildMainView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ChildMainView: View {
    enum GaugeFloat: CGFloat {
        case bottom = 0.525 // 배터리 0 퍼센트
        case top = 0.975 // 배터리 100 퍼센트
        
        func add(for percent: Double) -> CGFloat {
            self.rawValue + ((GaugeFloat.top.rawValue - GaugeFloat.bottom.rawValue) / 100.0) * percent
        }
    }
    
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM

    @State private var batteryPercent: Double = 0
    @State private var isGaugeAnimating: Bool = false
    @State private var timer: Timer?
    
    var uploadCycle: Int { userVM.user?.uploadCycle ?? 3 }
    var lastUploadDate: Date { photoVM.photos.first?.uploadDate ?? .now }
    var loveCount: Int { 12 }
    var fireCount: Int { 34 }
    var starCount: Int { 56 }
    var likeCount: Int { 78 }
    var totalUploadCount: Int { photoVM.photos.count }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Header("픽-챠!")
                
                Section(icon: Icon.heartBolt, title: "배터리") {
                    BatteryGauge(percent: batteryPercent, date: lastUploadDate)
                    
                    HStack(spacing: 12) {
                        UploadBtn("사진 찍기", icon: Icon.bolt, bgColor: .bgGray3) {
                            navigationManager.push(to: .childSendGallery)
                        }
                        
                        UploadBtn("사진 올리기", icon: Icon.bolt, bgColor: .accent) {
                            navigationManager.push(to: .childSendGallery)
                        }
                    }
                }
                .foregroundStyle(.accent)
                
                Section(icon: Icon.goal, title: "목표") {
                    Text("마지막으로 보낸지 \(lastUploadDate.timeIntervalKRString()) 됐어요")
                        .foregroundStyle(.txtPrimaryDark)
                        .font(.title2.weight(.bold))
                    
                    Text("\(uploadCycle)일에 1장 보내기")
                        .foregroundStyle(.txt838386)
                        .font(.body.weight(.bold))
                }
                .foregroundStyle(.grpTeal)
                
                Section(icon: Icon.upload, title: "누적 업로드 수") {
                    Text("\(photoVM.photos.count)장")
                        .foregroundStyle(.txtPrimaryDark)
                        .font(.title2.weight(.bold))
                }
                .foregroundStyle(.grpOrange)
                
                Section(icon: Icon.heart, title: "누적 반응 수") {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Icon.loveReaction.font(.system(size: 32))
                            Text("\(loveCount)")
                        }
                        .foregroundStyle(.pink)
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Icon.fireReaction.font(.system(size: 32))
                            Text("\(fireCount)")
                        }
                        .foregroundStyle(.yellow)
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Icon.starReaction.font(.system(size: 32))
                            Text("\(starCount)")
                        }
                        .foregroundStyle(.teal)
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Icon.likeReaction.font(.system(size: 32))
                            Text("\(likeCount)")
                        }
                        .foregroundStyle(.purple)
                        
                        Spacer()
                    }
                    .padding(8)
                }
                .foregroundStyle(.grpRed)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .bgGradient()
        .onAppear {
            startTimer()
            isGaugeAnimating = true
        }
        .onDisappear {
            
            isGaugeAnimating = false
        }
    }
    
    func startTimer() {
        updateBatteryStatus()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            updateBatteryStatus()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 배터리 상태를 계산하는 함수 입니다.
    /// let uploadCycleSeconds = Double(uploadCycle * 숫자) 를 활용해 시간 단위를 계산할 수 있습니다.
    func updateBatteryStatus() {
        guard let lastUploadDate = photoVM.photos.first?.uploadDate else {
            batteryPercent = 100
            return
        }
        
        let currentTime = Date()
        let timeElapsed = currentTime.timeIntervalSince(lastUploadDate) // 경과 시간(초)
        let uploadCycleSeconds = Double(uploadCycle * 24 * 3600) // uploadCycle을 시간 단위로, N일 지나면 0%
        
        // 배터리 백분율 계산, 1프로 이하는 1로 고정
        let currentPercentage = max(100.0 - (100 * timeElapsed / uploadCycleSeconds), 1.0)
        
        batteryPercent = round(currentPercentage)
    
        if currentPercentage <= 0 {
            stopTimer()
        }
    }

    @ViewBuilder
    func BatteryGauge(percent: Double, date lastUploaded: Date) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 8) {
                Text("\(Int(percent))%")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.txtPrimaryDark)
                    .offset(x: 2) // 시각적 보정으로 좌측으로 2px 이동
                
                Text("남았어요")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.txtVibrantTertiary)
            }
            .padding(.top, 66)
            
            BatteryGaugeBar(percent: percent)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 144)
    }
    
    
    @ViewBuilder
    func BatteryGaugeBar(percent: Double) -> some View {
        ZStack {
            // 뒤쪽 배경 게이지
            Circle()
                .trim(from: GaugeFloat.bottom.rawValue, to: GaugeFloat.top.rawValue)
                .stroke(
                    Color.bgGray6
                        .shadow(.inner(color: Color.bgPrimary, radius: 2, x: 0, y: 2)),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .frame(width: 210, height: 210)
                .offset(y: 52)
            
            // 실제 배터리 게이지
            Circle()
                .trim(
                    from: GaugeFloat.bottom.rawValue,
                    to: isGaugeAnimating
                        ? GaugeFloat.bottom.add(for: percent)
                        : GaugeFloat.bottom.rawValue
                )
                .stroke(
                    Color.battery(percent: percent)
                        .shadow(.inner(color: Color.white.opacity(0.25), radius: 4, x: 0, y: 4)),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .shadow(color: Color.wgBattery(percent: percent), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
                .frame(width: 210, height: 210)
                .offset(y: 52)
                .animation(.easeInOut(duration: 0.5), value: isGaugeAnimating)
        }
        .frame(width: 234, height: 144)
    }
    
    @ViewBuilder
    func UploadBtn(_ text: String,
                   icon: Image,
                   bgColor: Color,
                   action: @escaping () -> Void) -> some View {
        
        Button {
            action()
        } label: {
            HStack(spacing: 5) {
                Spacer()
                icon
                Text(text)
                Spacer()
            }
            .font(.body.weight(.black))
            .foregroundStyle(.txtPrimaryDark)
            .frame(height: 44)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
    }
}

extension ChildMainView {
    struct Section<Content>: View where Content: View {
        var icon: Image
        var title: String
        let content: () -> Content
        
        init(icon: Image, title: String, @ViewBuilder content: @escaping () -> Content) {
            self.icon = icon
            self.title = title
            self.content = content
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 4) {
                    icon
                    Text(title)
                        .font(.subheadline.weight(.bold))
                    
                    Spacer()
                }
                .font(.subheadline.weight(.bold))
                
                content()
            }
            .padding(11)
            .background(.grpBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    NavigationStack {
        ChildMainView()
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
