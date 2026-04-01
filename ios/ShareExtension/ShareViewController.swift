import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    private let appGroupId = "group.com.momrise.app"
    private let sharedKey = "SharedData"
    private let urlScheme = "SharingMedia-com.momrise.app"

    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()

        // Set light background to avoid dark overlay appearance
        if let presentationController = presentationController {
            presentationController.containerView?.backgroundColor = .clear
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set placeholder text to make the UI look intentional
        placeholder = "Importing recipe to MomRise..."

        // Customize the appearance
        if let textView = textView {
            textView.isEditable = false
            textView.textColor = .secondaryLabel
        }

        // Make the view controller background lighter
        if let navController = navigationController {
            navController.view.backgroundColor = .systemBackground
        }
        view.backgroundColor = .systemBackground

        // Auto-submit after a brief moment to allow UI to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.didSelectPost()
        }
    }

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        NSLog("📱 ShareExtension: didSelectPost called")

        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            NSLog("📱 ShareExtension: No input items, completing")
            completeRequest()
            return
        }

        let group = DispatchGroup()
        var foundContent = false

        for item in items {
            guard let attachments = item.attachments else { continue }
            NSLog("📱 ShareExtension: Processing \(attachments.count) attachments")

            for provider in attachments {
                // Handle URLs
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    foundContent = true
                    group.enter()
                    NSLog("📱 ShareExtension: Loading URL item")
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] data, error in
                        if let error = error {
                            NSLog("❌ ShareExtension: URL load error: \(error.localizedDescription)")
                        }
                        if let url = data as? URL {
                            NSLog("📱 ShareExtension: Got URL: \(url.absoluteString)")
                            self?.saveAndRedirect(value: url.absoluteString, type: "url")
                        }
                        group.leave()
                    }
                }
                // Handle plain text
                else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    foundContent = true
                    group.enter()
                    NSLog("📱 ShareExtension: Loading text item")
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] data, error in
                        if let error = error {
                            NSLog("❌ ShareExtension: Text load error: \(error.localizedDescription)")
                        }
                        if let text = data as? String {
                            NSLog("📱 ShareExtension: Got text: \(text.prefix(100))...")
                            self?.saveAndRedirect(value: text, type: "text")
                        }
                        group.leave()
                    }
                }
            }
        }

        // Add timeout protection
        let timeout = DispatchTime.now() + .seconds(10)
        let timeoutResult = group.wait(timeout: timeout)

        if timeoutResult == .timedOut {
            NSLog("⚠️ ShareExtension: Timed out waiting for content")
        }

        group.notify(queue: .main) { [weak self] in
            NSLog("📱 ShareExtension: All content processed, completing request")
            self?.completeRequest()
        }

        if !foundContent {
            NSLog("⚠️ ShareExtension: No compatible content found")
            // Complete immediately if no content to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.completeRequest()
            }
        }
    }

    override func configurationItems() -> [Any]! {
        return []
    }

    private func saveAndRedirect(value: String, type: String) {
        NSLog("📱 ShareExtension: Saving data - type: \(type), value: \(value.prefix(100))...")

        // Save to App Group shared UserDefaults
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let sharedData: [String: Any] = [
            "value": value,
            "type": type,
            "timestamp": Date().timeIntervalSince1970
        ]
        userDefaults?.set(sharedData, forKey: sharedKey)
        let syncResult = userDefaults?.synchronize()
        NSLog("📱 ShareExtension: UserDefaults sync result: \(syncResult ?? false)")

        // Open the main app via URL scheme
        let urlString = "\(urlScheme)://shared?type=\(type)"
        NSLog("📱 ShareExtension: Opening URL: \(urlString)")
        if let url = URL(string: urlString) {
            openURL(url)
        } else {
            NSLog("❌ ShareExtension: Failed to create URL from: \(urlString)")
        }
    }

    private func completeRequest() {
        NSLog("📱 ShareExtension: Completing request and dismissing")
        extensionContext?.completeRequest(returningItems: [], completionHandler: { expired in
            NSLog("📱 ShareExtension: Request completed, expired: \(expired)")
        })
    }

    // Open URL from extension (uses responder chain)
    @objc private func openURL(_ url: URL) {
        NSLog("📱 ShareExtension: Attempting to open URL: \(url)")

        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                NSLog("📱 ShareExtension: Found UIApplication, opening URL")
                application.open(url, options: [:], completionHandler: { success in
                    NSLog("📱 ShareExtension: URL open result: \(success)")
                })
                return
            }
            responder = responder?.next
        }

        // Fallback for iOS 16+
        NSLog("📱 ShareExtension: Using fallback selector method")
        let selector = sel_registerName("openURL:")
        var response: UIResponder? = self
        while response != nil {
            if response!.responds(to: selector) {
                NSLog("📱 ShareExtension: Found responder with openURL selector")
                response!.perform(selector, with: url)
                return
            }
            response = response?.next
        }

        NSLog("❌ ShareExtension: No way to open URL found")
    }
}
