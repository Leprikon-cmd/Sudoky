import SwiftUI

struct PaperSectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("ButtonPrimary").opacity(0.055))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("Line").opacity(0.9), lineWidth: 1)
                }
                .shadow(color: Color("ButtonPrimary").opacity(0.08), radius: 3, y: 1)
        }
    }
}
