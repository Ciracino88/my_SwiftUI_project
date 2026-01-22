import SwiftUI
import PhotosUI

struct AmongUsWalkingView: View {
    @StateObject var viewModel = AmongUsBodyViewModel()
    @State var showMaskAddView = false
    
    var body: some View {
        ZStack {
            // 배경색 적용
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.indigo]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            VStack {
                AmongUsTopBar(viewModel: viewModel)
                
                GeometryReader { gm in
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        AmongUsBody(viewModel: viewModel)
                            .position(viewModel.position)
                            .onAppear {
                                viewModel.screenSize = gm.size
                                viewModel.position = CGPoint(x: viewModel.screenSize.width / 2, y: viewModel.screenSize.height / 2)
                            }
                    }
                    .padding(24)
                }
                .frame(maxHeight: .infinity)
                Spacer(minLength: 80)
                
                // 하단 버튼
                HStack(spacing: 16) {
                    Button {
                        showMaskAddView.toggle()
                    } label: {
                        Image(systemName: "face.smiling")
                            .frame(width: 60, height: 60)
                            .font(.system(size: 28, weight: .medium))
                            .background(
                                Circle().fill(viewModel.maskImage != nil ? Color.green.opacity(0.2) : Color.gray.opacity(0.15))
                            )
                            .foregroundStyle(viewModel.maskImage != nil ? .green : .primary)
                            .opacity(viewModel.maskImage != nil ? 1.0 : 0.5)
                    }
                    Spacer()
                }
                .sheet(isPresented: $showMaskAddView) {
                    AmongUsMaskAddView(viewModel: viewModel)
                }
            }
        }
    }
    
    func toggleIsWalking() {
        viewModel.isWalking.toggle()
        viewModel.walking()
    }
    
    func toggleIsFlip() {
        viewModel.isFlip.toggle()
    }
}

struct AmongUsTopBar: View {
    @ObservedObject var viewModel: AmongUsBodyViewModel
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                if let mask = viewModel.maskImage {
                    Image(uiImage: mask)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.black, lineWidth: 2))
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.gray)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("ciracino88")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Text("LV. 1")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        
                        ProgressView()
                            .progressViewStyle(.linear)
                            .frame(width: 80, height: 6)
                            .tint(.yellow)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(.white.opacity(0.08))
            )
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 10)
    }
}

struct AmongUsBody: View {
    @ObservedObject var viewModel: AmongUsBodyViewModel
    
    var body: some View {
        VStack {
            Text("ciracino88")
                .foregroundStyle(.white)
                .fontWeight(.medium)
            ZStack {
                Image("AmongUsWalk\(viewModel.currentFrame)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .onAppear {
                        viewModel.walking()
                    }
                    .onDisappear {
                        viewModel.stopWalking()
                    }
                    .scaleEffect(x: viewModel.velocity.dx >= 0 ? 1 : -1)
                if let mask = viewModel.maskImage {
                    Image(uiImage: mask)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                        .scaleEffect(x: viewModel.velocity.dx >= 0 ? 1 : -1)
                }
            }
        }
    }
}

struct AmongUsMaskAddView: View {
    @ObservedObject var viewModel: AmongUsBodyViewModel
    @State var selectedItem: [PhotosPickerItem] = []
    @State var showCropView = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = viewModel.maskImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(Circle())
                    .padding(.top, 20)
            }
            Spacer()
            PhotosPicker(selection: $selectedItem, maxSelectionCount: 1, matching: .images, photoLibrary: .shared()) {
                Label("앨범에서 선택", systemImage: "photo")
                    .font(.headline)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                do {
                    // 1. photosPickerItem -> data
                    if let data = try await newItem[0].loadTransferable(type: Data.self) {
                        // 2. data -> UIImage
                        viewModel.maskImage = UIImage(data: data)
                        // 3. cropView 로 이동
                        showCropView.toggle()
                    }
                } catch {
                    print("로드 실패")
                }
            }
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let image = viewModel.maskImage {
                CropViewRepresentable(image: image, onCrop: { croppedImage in
                    viewModel.maskImage = croppedImage
                    showCropView = false
                })
            }
        }
    }
}

class AmongUsBodyViewModel: ObservableObject {
    let moveDuration = 1.0
    let frameDuration = 0.21
    let frameCount = 5
    let speed = 18.0 // 이동 속도
    
    private var walkingTimer: Timer?
    private var frameTimer: Timer?
    private var positionTimer: Timer?
    
    @Published var isWalking = false
    @Published var isFlip = false
    @Published var currentFrame = 0
    
    @Published var maskImage: UIImage?
    @Published var position: CGPoint = .zero // 캐릭터 위치
    @Published var velocity: CGVector = .init(dx: 1, dy: 1) // 이동 방향
    @Published var screenSize: CGSize = .zero
    
    func walking() {
        stopWalking()
        randomDirection()
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            self.randomDirection()
            self.isWalking = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.isWalking = false
            }
        }
        
        // 1. 애니메이션 업데이트
        frameTimer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { timer in
            if !self.isWalking {
                self.currentFrame = 0
                return
            }
            
            self.currentFrame = (self.currentFrame + 1) % self.frameCount
        }
        
        // 2. 위치 업데이트
        positionTimer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            // 정지 상태라면 이동 로직 스킵
            if !self.isWalking {
                return
            }
            
            withAnimation(.linear(duration: self.frameDuration)) {
                self.position.x += self.velocity.dx
                self.position.y += self.velocity.dy
            }
            
            // 3. 화면 경계 체크
            let marginLeft: CGFloat = -30
            let marginRight: CGFloat = -70 // 수정 필요
            let marginTop: CGFloat = -30
            let marginBottom: CGFloat = -250 // 수정 필요
            
            // 왼쪽 경계
            if self.position.x < -marginLeft {
                self.position.x = -marginLeft
                self.velocity.dx = abs(self.velocity.dx)
            }
            
            // 오른쪽 경계
            else if self.position.x > self.screenSize.width + marginRight {
                self.position.x = self.screenSize.width + marginRight
                self.velocity.dx = -abs(self.velocity.dx)
            }
            
            // 윗경계
            if self.position.y < -marginTop {
                self.position.y = -marginTop
                self.velocity.dy = abs(self.velocity.dy)
            }
            
            // 아랫경계
            else if self.position.y > self.screenSize.height + marginBottom {
                self.position.y = self.screenSize.height + marginBottom
                self.velocity.dy = -abs(self.velocity.dy)
            }
        }
    }
    
    func stopWalking() {
        walkingTimer?.invalidate()
        frameTimer?.invalidate()
        positionTimer?.invalidate()
        walkingTimer = nil
        frameTimer = nil
        positionTimer = nil
        isWalking = false
        currentFrame = 0
    }
    
    func randomDirection() {
        // 이동 방향 랜덤 설정
        let randomTheta = CGFloat.random(in: 0...(CGFloat.pi * 2))
        let dx = cos(randomTheta)
        let dy = sin(randomTheta)
        
        self.velocity = CGVector(dx: dx * self.speed, dy: dy * self.speed)
    }
}
