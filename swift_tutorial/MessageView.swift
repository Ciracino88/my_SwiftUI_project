import SwiftUI
import SocketIO

class ChatSocketManager: ObservableObject {
    static let shared = ChatSocketManager()
    
    @Published var messages: [String] = []
    @Published var isConnected = false
    @Published var statusMessage = "연결 중..."
    
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    private init() {
        // 서버 URL (배포 시 wss://domain.com 형식으로 변경.
        // 로컬은 localhost:3000
        let url = URL(string: "https://my-swiftui-project-backand.onrender.com/")!
        
        manager = SocketManager(socketURL: url, config: [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectAttempts(0)
        ])
        
        self.socket = manager.defaultSocket
        
        // 이벤트 핸들러 등록
        socket.on(clientEvent: .connect) { _, _ in
            DispatchQueue.main.async {
                self.isConnected = true
                self.statusMessage = "연결됨"
            }
        }
        
        socket.on("chat") { [weak self] data, _ in
            if let msg = data.first as? String {
                DispatchQueue.main.async {
                    self?.messages.append(msg)
                }
            }
        }
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func send(_ message: String) {
        socket.emit("chat", message)
    }
}

struct ChatView: View {
    @StateObject var socketManager = ChatSocketManager.shared
    @State var inputText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(socketManager.statusMessage)
                .font(.headline)
                .foregroundStyle(socketManager.isConnected ? .green : .red)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(socketManager.messages, id: \.self) { msg in
                        Text(msg)
                            .padding(10)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            
            HStack {
                CustomTextField(text: $inputText)
                
                Button {
                    if !inputText.isEmpty {
                        socketManager.send(inputText)
                        inputText = ""
                    }
                } label: {
                    Text("전송")
                }
                .disabled(!socketManager.isConnected)
            }
            .padding()
        }
        .navigationTitle("Socket.IO Chat")
        .onAppear {
            socketManager.connect()
        }
        .onDisappear {
            socketManager.disconnect()
        }
    }
}
