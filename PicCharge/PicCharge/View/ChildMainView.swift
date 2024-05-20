//
//  ChildMainView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildMainView: View {
    enum CGCircleGaugeFloat: CGFloat {
        case bottom = 0.525 // 배터리 0 퍼센트
        case top = 0.975 // 배터리 100 퍼센트
        
        func add(for percent: Double) -> CGFloat {
            self.rawValue + (CGCircleGaugeFloat.top.rawValue - CGCircleGaugeFloat.bottom.rawValue) / 100 * percent
        }
    }
    
    @Environment(NavigationManager.self) var navigationManager
    
    @State private var batteryPercent: Double = 20
    @State private var totalLikeCount: Int = 1223
    @State private var totalUploadCount: Int = 320
    @State private var uploadCycle: Int = 3
    @State private var lastUploaded: Date = Calendar.current.date(byAdding: .hour, value: -28, to: Date())!
    @State private var isGaugeAnimating: Bool = false
    @State private var infoPage: Int = 1
    
    var body: some View {
        ZStack {
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.bgGreen, Color.bgGreen.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        navigationManager.push(to: .childSelectGallery)
                    } label: {
                        NavigationButtonLabel(
                            for: "사진 올리기",
                            Icon: Icon.addPhoto,
                            bgColor: .bgGray
                        )
                    }
                    
                    Button {
                        navigationManager.push(to: .childCamera)
                    } label: {
                        NavigationButtonLabel(
                            for: "사진 찍기",
                            Icon: Icon.camera,
                            bgColor: .accent
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                TabView(selection: $infoPage) {
                    Group {
                        VStack {
                            BatteryPageView(percent: batteryPercent, date: lastUploaded)
                            Spacer()
                        }
                        .tag(1)
                        
                        VStack {
                            GoalPageView()
                            Spacer()
                        }
                        .tag(2)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 300)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onTapGesture {
                    withAnimation {
                        infoPage = infoPage == 1 ? 2 : 1
                    }
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func BatteryPageView(percent: Double, date lastUploaded: Date) -> some View {
        ZStack {
            VStack {
                HStack {
                    IconLabel(Icon: Icon.heartBolt, label: "배터리")
                        .foregroundStyle(.accent)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("\(Int(percent))%")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.txtPrimaryDark)
                        .padding(.bottom, 8)
                        .offset(x: 2) // 시각적 보정으로 좌측으로 2px 이동
                    
                    Text("남았어요")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.txtVibrantTertiary)
                        .padding(.bottom, 16)
                    
                    Text("마지막으로 보낸지 \(lastUploaded.timeIntervalKRString()) 됐어요")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.txtVibrantSecondary)
                        .padding(.bottom, 21)
                }
            }
            .padding(11)
            .frame(height: 267)
            .background(Color.bgSecondaryElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            BatteryGaugeBarView(percent: percent)
        }
    }
    
    @ViewBuilder
    func GoalPageView() -> some View {
        VStack(spacing: 11) {
            InfoView(
                Icon: Icon.goal,
                label: "목표",
                content: "\(uploadCycle)일에 1장 보내기",
                tintColor: .grpTeal
            )
            .frame(height: 112)
            
            HStack(spacing: 11) {
                InfoView(
                    Icon: Icon.heart,
                    label: "누적 좋아요 수",
                    content: "\(totalLikeCount)개",
                    tintColor: .grpRed
                )
                InfoView(
                    Icon: Icon.upload,
                    label: "누적 업로드 수",
                    content: "\(totalUploadCount)장",
                    tintColor: .grpOrange
                )
            }
            .frame(height: 128)
        }
        .padding(8)
        .frame(height: 267)
        .background(Color.bgPrimaryElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    func BatteryGaugeBarView(percent: Double) -> some View {
        ZStack {
            // 뒤쪽 배경 게이지
            Circle()
                .trim(from: CGCircleGaugeFloat.bottom.rawValue, to: CGCircleGaugeFloat.top.rawValue)
                .stroke(
                    Color.bgGray6.shadow(
                        .inner(
                            color: Color.bgPrimary,
                            radius: 2,
                            x: 0,
                            y: 2
                        )
                    ),
                    style: StrokeStyle(
                        lineWidth: 24,
                        lineCap: .round
                    )
                )
                .frame(width: 210, height: 210)
                .offset(y: 52)
            
            // 실제 배터리 게이지
            Circle()
                .trim(
                    from: CGCircleGaugeFloat.bottom.rawValue,
                    to: isGaugeAnimating
                        ? CGCircleGaugeFloat.bottom.add(for: percent)
                        : CGCircleGaugeFloat.bottom.rawValue
                )
                .stroke(
                    Color.battery(percent: percent).shadow(
                        .inner(
                            color: Color.white.opacity(0.25),
                            radius: 4,
                            x: 0,
                            y: 4
                        )
                    ),
                    style: StrokeStyle(
                        lineWidth: 24,
                        lineCap: .round
                    )
                )
                .shadow(
                    color: Color.wgBattery(percent: percent),
                    radius: CGFloat(8),
                    x: CGFloat(0),
                    y: CGFloat(4)
                )
                .frame(width: 210, height: 210)
                .offset(y: 52)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.isGaugeAnimating = true
                    }
                }
                .onDisappear {
                    self.isGaugeAnimating = false
                }
        }
    }
    
    @ViewBuilder
    func InfoView(
        Icon: Image, 
        label: String, 
        content: String,
        tintColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            IconLabel(Icon: Icon, label: label)
                .foregroundStyle(tintColor)
            
            HStack {
                Text(content)
                    .font(.title.weight(.bold))
                Spacer()
            }
            
            Spacer()
        }
        .foregroundStyle(.txtPrimaryDark)
        .padding(11)
        .background(Color.bgSecondaryElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    func IconLabel(Icon: Image, label: String) -> some View {
        HStack(spacing: 4) {
            Icon
            Text(label)
                .font(.subheadline.weight(.bold))
        }
        .font(.subheadline.weight(.bold))
    }
    
    @ViewBuilder
    func NavigationButtonLabel(
        for text: String,
        Icon: Image,
        bgColor: Color
    ) -> some View {
        VStack(alignment: .leading) {
            Icon
                .font(.title.weight(.bold))
            Spacer()
            HStack {
                Spacer()
                Text(text)
                    .font(.headline.weight(.bold))
            }
        }
        .foregroundStyle(.txtPrimaryDark)
        .padding(11)
        .frame(height: 100)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ChildMainView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
