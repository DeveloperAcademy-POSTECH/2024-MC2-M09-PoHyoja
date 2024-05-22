//
//  File.swift
//  PicCharge
//
//  Created by 남유성 on 5/22/24.
//

import Lottie
import SwiftUI

// lottie를 jason파일 명으로 불러오기 위해 LottieView생성했습니다.
struct LottieView: UIViewRepresentable {
    var jsonName: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: jsonName)
        
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFill
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        //.frame modifier로 사이즈 수정하기 위한 코드입니다. by GPT
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        animationView.play(completion: { (finished) in
            print("Animation finished playing: \(finished)")
        })
        
        print("LottieView created and animation started.")
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}
