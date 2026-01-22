import SwiftUI

struct PortfolioDetailView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    @State var showEditView = false
    @State var showAddView = false
    @State var children: [PortfolioResponse] = []

    let portfolio: PortfolioResponse
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("\(portfolio.title)")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.primary)

                Text("\(portfolio.content)")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 20)
                Section {
                    ForEach(children) { child in
                        NavigationLink(destination: PortfolioDetailView(viewModel: viewModel, portfolio: child)) {
                            Text("\(child.title)")
                        }
                    }
                } header: {
                    Text("\(children.count)개의 하위노드")
                        .foregroundStyle(.secondary)
                }
                .task {
                    await self.children = viewModel.loadChildren(portfolio: portfolio)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showEditView) {
            
        }
        .sheet(isPresented: $showAddView) {
            PortfolioAddView(viewModel: viewModel, showAddView: $showAddView, parent: portfolio)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showEditView.toggle()
                    } label: {
                        Image(systemName: "pencil")
                    }
                    Button {
                        showAddView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        
    }
}
