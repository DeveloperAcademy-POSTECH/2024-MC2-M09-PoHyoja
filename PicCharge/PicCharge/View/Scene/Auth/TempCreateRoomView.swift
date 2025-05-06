import SwiftUI

struct TempCreateRoomView: View {
    @Environment(NavigationManager.self) var navigationManager
    var body: some View {
        VStack(alignment: .leading) {
            Text("방을 만드시겠습니까?")
                .font(.title2)
                .bold()
            Spacer()
            
            Button(action: {
                navigationManager.popToRoot()
            }) {
                Text("생성하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    TempCreateRoomView()
} 
