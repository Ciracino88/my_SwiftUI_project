import SwiftUI

struct TodoListWeekdaySelector: View {
    @State var selectedWeekdays: Set<Int> = []
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { index in
                Button {
                    if selectedWeekdays.contains(index) {
                        selectedWeekdays.remove(index)
                    } else {
                        selectedWeekdays.insert(index)
                    }
                } label: {
                    ZStack  {
                        Circle().foregroundStyle(selectedWeekdays.contains(index) ? Color.gray.opacity(0.5) : .white)
                        Text(weekdays[index - 1])
                    }
                }
            }
        }
    }
}
