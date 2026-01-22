import SwiftUI

struct TodoListView: View {
    @StateObject var viewModel = TodoListViewModel()
    @State private var isLoading = false
    @State private var showAddTodoSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                } else {
                    if viewModel.todoList.count == 0 {
                        Text("나의 할 일을 추가해봅시다!")
                    } else {
                        ForEach(viewModel.todoList) { todo in
                            NavigationLink(destination: TodoListDetailView(todo: todo)) {
                                TodoListCard(todo: todo)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .task {
                isLoading = true
                await viewModel.fetchTodo()
                isLoading = false
            }
            .sheet(isPresented: $showAddTodoSheet) {
                VStack {
                    ScrollView {
                        CustomTextField(text: $viewModel.createdTitle, placeholder: "제목을 입력해주세요")
                        CustomTextField(text: $viewModel.createdContent, placeholder: "내용을 입력해주세요")
                        Toggle("알림을 설정합니다.", isOn: $viewModel.activateAlarm)
                            .padding(12)
                            .padding(.vertical, 24)
                        if viewModel.activateAlarm {
                            Picker("어떤 유형의 일정인가요?", selection: $viewModel.selectedOption) {
                                ForEach(PlanType.allCases) { plan in
                                    Text(plan.rawValue).tag(plan)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            if viewModel.selectedOption == .daily {
                                TodoListAlarmSettingView(viewModel: viewModel)
                            } else {
                                TodoListAlarmSettingView(viewModel: viewModel)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    Spacer()
                    CustomButton(title: "저장", action: addTodo)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MY LOG")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTodoSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func addTodo() {
        Task {
            await viewModel.addTodo()
            showAddTodoSheet = false
        }
    }
}

enum PlanType: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case event = "Event"
    
    var id: String { rawValue }
}

struct TodoInsert: Codable {
    // id 를 서버에서 생성
    var title: String
    var content: String
    // completed = false
    // createdAt = now()
    var isAlarm: Bool
    var alarmTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case isAlarm = "is_alarm"
        case alarmTime = "alarm_time"
    }
}

struct TodoResponse: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var isAlarm: Bool
    var alarmTime: Date?
    var completed: Bool
    var createdAt: Date?
    var userID: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case isAlarm = "is_alarm"
        case alarmTime = "alarm_time"
        case completed
        case createdAt = "created_at"
        case userID = "user_id"
    }
}

struct CodableParent: Codable {
    var name: String
    var age: Int
    var birthTime: Date
    var child: CodableChild
    
    enum CodingKeys: String, CodingKey {
        case name // 이렇게 쓰면 자동으로 JSON의 "name"에 대응됨.
        case age // 이렇게 하면 JSON 상에서 사용되는 이름을 지정할 수 있음
        case birthTime = "birth_time"
        case child
    }
}

struct CodableChild: Codable {
    var name: String
    var age: Int
    var birthTime: Date
    
    enum CodingKeys: String, CodingKey {
        case name // 이렇게 쓰면 자동으로 JSON의 "name"에 대응됨.
        case age = "parent_age" // 이렇게 하면 JSON 상에서 사용되는 이름을 지정할 수 있음
        case birthTime = "birth_time"
    }
}
