import SwiftUI
import Supabase

@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todoList: [TodoResponse] = []
    
    @Published var createdTitle: String = ""
    @Published var createdContent: String = ""
    @Published var activateAlarm = false
    @Published var selectedOption: PlanType = .daily
    @Published var selectedDate = Date()
    
    let supabase = SupabaseClient(supabaseURL: Config.supabaseURL,
                                  supabaseKey: Config.supabaseKEY)
    
    func fetchTodo() async {
        do {
            let result: [TodoResponse] = try await supabase
                .from("todo")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            todoList = result
        }  catch {
            print("목록을 불러오는데 실패하였습니다.")
        }
    }
    
    func addTodo() async {
        guard let currentUserId = supabase.auth.currentSession?.user.id else {
            print("로그인 상태가 아닙니다.")
            return
        }
        
        do {
            let newTodo = createNewTodoData()
            try await supabase
                .from("todo")
                .insert(newTodo)
                .execute()
            
            pushNotification(todo: newTodo) // notificationCenter 에 알림을 푸시
            
            await fetchTodo() // 데이터 추가 후 상태 반영
        }  catch {
            print("데이터 추가에 실패하였습니다.")
        }
    }
    
    private func createNewTodoData() -> TodoInsert {
        if !activateAlarm {
            let newTodo = TodoInsert(title: createdTitle, content: createdContent, isAlarm: activateAlarm)
            return newTodo
        } else {
            let newTodo = TodoInsert(title: createdTitle, content: createdContent, isAlarm: activateAlarm, alarmTime: selectedDate)
            return newTodo
        }

    }
    
    func pushNotification(todo: TodoInsert) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        guard let alarmTime = todo.alarmTime else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(todo.title)"
        content.body = "\(todo.content)"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
}
