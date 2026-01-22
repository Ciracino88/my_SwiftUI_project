import SwiftUI
import Supabase

struct PortfolioView: View {
    @StateObject var viewModel = PortfolioViewModel()
    @State var showAddView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.portfolios.isEmpty {
                    Text("내용을 작성해주세요!")
                } else {
                    List(viewModel.topPortfolios) { portfolio in
                        NavigationLink(destination: PortfolioDetailView(viewModel: viewModel, portfolio: portfolio)) {
                            Text("\(portfolio.title)")
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchPortfolios()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("My Portfolio")
                        .font(.system(size: 18, weight: .medium))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddView) {
                PortfolioAddView(viewModel: viewModel, showAddView: $showAddView, parent: nil)
            }
        }
    }
}

struct PortfolioInsert : Codable {
    var title: String
    var content: String
    var parentId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case parentId = "parent_id"
    }
}

struct PortfolioResponse: Codable, Identifiable {
    var id: UUID
    var title: String
    var content: String
    var parentId: UUID?
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case parentId = "parent_id"
        case userId = "user_id"
    }
}
