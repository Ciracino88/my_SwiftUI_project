import SwiftUI

struct TodoListCard: View {
    let todo: TodoResponse
    
    var body: some View {
        ZStack(alignment: .leading) {
            TodoListCardBackground()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(todo.title)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if let created = todo.createdAt {
                        Text("\(getCreateAtString(time: created))")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                Spacer()
                TodoListCardStateMarks()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private func getCreateAtString(time: Date) -> String {
        let calender = Calendar.current
        let now = Date()
        let components = calender.dateComponents([.year, .month, .day, .hour, .minute], from: time, to: now)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let min = components.minute ?? 0
        
        switch (year, month, day, hour, min) {
        case (let year, _, _, _, _) where year > 0:
            return "\(year)년 전"
        case (_, let month, _, _, _) where month > 0:
            return "\(month)개월 전"
        case (_, _, let day, _, _) where day > 0:
            return "\(day)일 전"
        case (_, _, _, let hour, _) where hour > 0:
            return "\(hour)시간 전"
        case (_, _, _, _, let min) where min > 5:
            return "\(min)분 전"
        case (_, _, _, _, let min) where min <= 5:
            return "방금 전"
        default:
            let result = now.ISO8601Format(.iso8601Date(timeZone: .current))
            return "\(result)"
        }
    }
}

struct TodoListCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(colors: [.gray.opacity(0.15), .gray.opacity(0.05)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct TodoListCardStateMarks: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 20, weight: .medium))
            Image(systemName: "bell.fill")
                .foregroundStyle(.green)
                .font(.system(size: 20, weight: .medium))
        }
        .padding(12)
        .frame(alignment: .topTrailing)
    }
}
