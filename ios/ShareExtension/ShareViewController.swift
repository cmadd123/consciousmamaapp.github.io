import receive_sharing_intent

class ShareViewController: RSIShareViewController {

    // Auto-redirect to the main app after sharing
    override func shouldAutoRedirect() -> Bool {
        return true
    }
}
