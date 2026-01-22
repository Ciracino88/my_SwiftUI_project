import SwiftUI

struct PortfolioAddView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @Binding var showAddView: Bool
    
    let parent: PortfolioResponse?
    
    var body: some View {
        VStack {
            ScrollView {
                TextField("제목을 입력하세요", text: $viewModel.createdTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 8)
                    .textFieldStyle(.plain)
                TextEditor(text: $viewModel.createdContent)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 120)
            }
            
            if parent == nil {
                CustomButton(title: "저장", action: addPortfolio)
            } else if parent != nil {
                CustomButton(title: "\(parent!.title)의 하위 노드에 저장", action: addChild)
            }
        }
        .padding()
        .navigationTitle(parent == nil ? "최상단 노드 작성" : "\(parent!.title) 하위 노드 작성")
    }
    
    func addPortfolio() {
        Task {
            await viewModel.addPortfolio()
            showAddView = false
        }
    }
    
    func addChild() {
        Task {
            if let parent = parent {
                viewModel.createdParentId = parent.id
            }
            await viewModel.addPortfolio()
            showAddView = false
        }
    }
}
