import SwiftUI

struct TempSignUpNameView: View {
    @Environment(NavigationManager.self) var navigationManager
    @State private var name: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("이름을 입력해주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
            TextField("이름을 입력해주세요", text: $name)
                .autocapitalization(.none)
                .foregroundStyle(.txtPrimaryDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(.bgPrimaryElevated)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            
            // TODO: - FilledBtn 으로 대체하기
            Button(action: {
                navigationManager.push(to: .tempSelectFamily)
            }) {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
            .disabled(name.isEmpty)
            .padding(.horizontal)
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    TempSignUpNameView()
} 
