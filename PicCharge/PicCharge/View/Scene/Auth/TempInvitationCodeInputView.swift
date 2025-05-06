import SwiftUI

struct TempInvitationCodeInputView: View {
    @Environment(NavigationManager.self) var navigationManager
    @State private var code: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("방 초대 코드를 입력해주세요")
                .font(.title2)
                .bold()
            TextField("초대 코드 입력", text: $code)
                .autocapitalization(.none)
                .foregroundStyle(.txtPrimaryDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(.bgPrimaryElevated)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            
            Button(action: {
                if code == "aaaa" {
                    navigationManager.push(to: .tempJoinRoom)
                }
            }) {
                Text("입력")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!code.isEmpty ? Color.green : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
            .disabled(code != "aaaa")
            .padding(.horizontal)
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    TempInvitationCodeInputView()
} 
