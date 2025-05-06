import SwiftUI

struct TempJoinRoomView: View {
    @Environment(NavigationManager.self) var navigationManager
    let members = ["모닝", "라뮤", "에이스"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("방에 참가하시겠습니까?")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
            Text("방에 있는 사람")
                .font(.headline)
                .foregroundStyle(.txtPrimaryDark)
                .padding()
            
            ForEach(members, id: \.self) { member in
                Text(member)
                    .padding(.leading, 8)
            }
            Spacer()
                Button(action: {
                    navigationManager.popToRoot()
                }) {
                    Text("아니오")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    navigationManager.popToRoot()
                }) {
                    Text("참가")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    TempJoinRoomView()
} 
