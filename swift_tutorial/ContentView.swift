import SwiftUI
import Supabase
import GoogleSignInSwift
import GoogleSignIn

struct ContentView: View {
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://ciszaukmnglepvqpulya.supabase.co")!,
                                  supabaseKey: "sb_publishable_s_BMgLmH4w_8boe7SWq59Q_p9fLDEU-")
    
    @State var selectedTab = 0
    
    var body: some View {
        if let user = supabase.auth.currentSession?.user {
            TabView {
                Tab("홈", systemImage: "house.fill") {
                    TodoListView()
                }
                Tab("어몽어스", systemImage: "person.fill") {
                    AmongUsWalkingView()
                }
                Tab("포트폴리오", systemImage: "list.clipboard.fill") {
                    PortfolioView()
                }
                Tab("채팅", systemImage: "message.fill") {
                    ChatView()
                }
            }
        } else {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(), action: {
                Task {
                    await googleSignIn()
                }
            })
        }
        
    }
    
    
    func googleSignIn() async {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController())
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Google", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token 없음"])
            }
            
            // Supabase에 idToken 전달
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken
                )
            )
            
            print("로그인 성공: \(session.user.id)")
        } catch {
            
        }
    }
    
    // presenting VC 가저오기
    func getRootViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            fatalError("Root View Controller 를 찾을 수 없음")
        }
        return rootVC
    }
}
