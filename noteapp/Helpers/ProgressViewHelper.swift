import UIKit


/// Update the progress bar value repeatedly.
/// - Parameters:
///     - progressView: The progress view instance to be updated.
func updateProgressBar(progressView: UIProgressView) {
    Timer.scheduledTimer(withTimeInterval: 1 / 200, repeats: true) { timer in
        DispatchQueue.main.async {
            if progressView.isHidden {
                progressView.setProgress(0, animated: false)
                timer.invalidate()
                return
            }
            
            var newProgress = progressView.progress + 0.01
            
            if newProgress >= 1 {
                newProgress = 0
            }
            progressView.setProgress(newProgress, animated: false)
        }
    }
}
