//
//  swift_tutorialApp.swift
//  swift_tutorial
//
//  Created by 이승호 on 12/31/25.
//

import SwiftUI
import Supabase
import SwiftData
import GoogleSignIn

@main
struct swift_tutorialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let modelContainer: ModelContainer = {
        let schema = Schema([Bookmark.self]) // SwiftData 모델 추가
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // isStoredInMemoryOnly: 모델 데이터 휘발성 여부
        
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("모델 컨테이너 생성 실패")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(modelContainer)
    }
}

// 1. 커스텀 EnvironmentKey 정의
private struct SupabaseClientKey: EnvironmentKey {
    static let defaultValue: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://ciszaukmnglepvqpulya.supabase.co")!,
        supabaseKey: "sb_publishable_s_BMgLmH4w_8boe7SWq59Q_p9fLDEU-"
    )
}

// 2. EnvironmentValues에 extension으로 키 추가
extension EnvironmentValues {
    var supabaseClient: SupabaseClient {
        get { self[SupabaseClientKey.self] }
        set { self[SupabaseClientKey.self] = newValue }
    }
}
