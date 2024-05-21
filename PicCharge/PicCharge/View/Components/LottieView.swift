//
//  TestLottie.swift
//  PicCharge
//
//  Created by 김병훈 on 5/21/24.
//

//패키지에 로티 임포트 했습니다.
import Lottie
import SwiftUI

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
