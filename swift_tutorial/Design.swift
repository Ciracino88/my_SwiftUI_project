import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    // 플레이스홀더 텍스트 (옵션으로 추가 가능)
    var placeholder: String = ""
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .padding(14)
            .background(Color(.systemBackground))  // 배경 살짝 구분 (필요시 제거)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
    }
    
    // 포커스에 따라 테두리 색상 변경
    private var borderColor: Color {
        isFocused ? .accentColor : Color.secondary.opacity(0.4)
    }
    
    // 포커스 시 테두리 두껍게
    private var borderWidth: CGFloat {
        isFocused ? 2.0 : 1.0
    }
}


struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
        .padding(.horizontal)
    }
}
