import SwiftUI
import TOCropViewController

struct CropViewRepresentable: UIViewControllerRepresentable {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropVC = TOCropViewController(image: image)
        cropVC.delegate = context.coordinator
        return cropVC
    }
    
    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: CropViewRepresentable
        
        init(_ parent: CropViewRepresentable) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.onCrop(image)
            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            
        }
    }
}
