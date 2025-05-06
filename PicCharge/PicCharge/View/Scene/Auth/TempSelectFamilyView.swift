import SwiftUI

struct TempSelectFamilyView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("가족 방 참여 방법")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
            HStack(spacing: 24) {
                Button(action: {
                    navigationManager.push(to: .tempInvitationCodeInput)
                }) {
                    Text("참가")
                        .frame(width: 120, height: 50)
                        .background(Color.gray.opacity(0.7))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    navigationManager.push(to: .tempCreateRoom)
                }) {
                    Text("생성")
                        .frame(width: 120, height: 50)
                        .background(Color.gray.opacity(0.7))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    TempSelectFamilyView()
} 
