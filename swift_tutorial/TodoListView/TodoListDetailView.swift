import SwiftUI

struct TodoListDetailView: View {
    let todo: TodoResponse
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text(todo.title)
                    .font(.headline)
                if let time = todo.alarmTime {
                    Text("알림 시각: \(time.ISO8601Format())")
                }
                Text(todo.content)
                    .font(.system(size: 18))
                    .fontWeight(.light)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
