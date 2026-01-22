import SwiftUI
import PhotosUI
import AVFoundation  // 카메라 권한용

struct PhotoPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []  // 미리보기용
    @State private var showCamera = false
    @State private var cameraImage: Image? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            // 선택된 사진 미리보기
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            selectedImages[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        selectedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red, .white)
                                    }
                                    .padding(4)
                                }
                        }
                    }
                    .padding()
                }
            } else if let camImage = cameraImage {
                camImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Text("사진을 선택하거나 촬영해주세요")
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 40) {
                // 앨범에서 선택 (다중 선택 가능)
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 5,  // 최대 선택 개수
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("앨범에서 선택", systemImage: "photo.on.rectangle.angled")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // 카메라 촬영
                Button {
                    checkCameraPermission()
                } label: {
                    Label("사진 찍기", systemImage: "camera")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                var loadedImages: [Image] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        loadedImages.append(Image(uiImage: uiImage))
                    }
                }
                selectedImages = loadedImages
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            PhotoPicker(sourceType: .camera) { image in
                if let image = image {
                    cameraImage = Image(uiImage: image)
                }
                showCamera = false
            }
        }
    }
    
    // 카메라 권한 체크
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        showCamera = true
                    }
                }
            }
        default:
            // 설정 앱으로 유도 (Alert 등으로 구현 가능)
            print("카메라 권한 필요")
        }
    }
}

