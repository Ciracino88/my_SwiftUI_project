import SwiftUI
import Supabase

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var portfolios: [PortfolioResponse] = []
    @Published var topPortfolios: [PortfolioResponse] = []
    
    @Published var createdTitle = ""
    @Published var createdContent = ""
    @Published var createdParentId: UUID? = nil
    
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://ciszaukmnglepvqpulya.supabase.co")!,
                                  supabaseKey: "sb_publishable_s_BMgLmH4w_8boe7SWq59Q_p9fLDEU-")
    
    func fetchPortfolios() async {
        do {
            let result: [PortfolioResponse] = try await supabase
                .from("portfolio")
                .select()
                .execute()
                .value
            
            portfolios = result
            topPortfolios = portfolios.filter { $0.parentId == nil }
        } catch {
            print("포트폴리오 로드 실패: \(error.localizedDescription)")
        }
    }
    
    func addPortfolio() async {
        do {
            let newPortfolio = createNewPortfolioData()
            try await supabase
                .from("portfolio")
                .insert(newPortfolio)
                .execute()
            
            await fetchPortfolios() // 데이터 추가 후 상태 반영
            
            clearField()
        }  catch {
            print("데이터 추가에 실패하였습니다.")
        }
    }
    
    private func createNewPortfolioData() -> PortfolioInsert {
        let newPortfolio = PortfolioInsert(title: createdTitle, content: createdContent, parentId: createdParentId)
        return newPortfolio
    }
    
    private func clearField() {
        createdTitle = ""
        createdContent = ""
        createdParentId = nil
    }
    
    func loadChildren(portfolio: PortfolioResponse) async -> [PortfolioResponse] {
        do {
            let response: [PortfolioResponse] = try await supabase
                .from("portfolio")
                .select()
                .eq("parent_id", value: portfolio.id.uuidString)
                .eq("user_id", value: portfolio.userId)
                .execute()
                .value
            
            return response
        } catch {
            print("하위 포트폴리오 로드 실패")
            return []
        }
    }
}
