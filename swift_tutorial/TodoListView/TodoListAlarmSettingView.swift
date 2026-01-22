import SwiftUI

struct TodoListAlarmSettingView: View {
    @ObservedObject var viewModel: TodoListViewModel
    
    var body: some View {
        VStack {
            // 정기적 알림 설정
            if viewModel.selectedOption == .daily {
                VStack(spacing: 20) {
                    TodoListWeekdaySelector()
                    DatePicker("알림 시간", selection: $viewModel.selectedDate, displayedComponents: [.hourAndMinute])
                        .padding(.horizontal, 14)
                }
            
                // 1회성 알림 설정
            } else {
                DatePicker("알림 시간", selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
            }
        }
        .padding()
    }
}
