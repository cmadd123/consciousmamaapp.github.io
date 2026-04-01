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
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }

        let group = DispatchGroup()

        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                // Handle URLs
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] data, _ in
                        if let url = data as? URL {
                            self?.saveAndRedirect(value: url.absoluteString, type: "url")
                        }
                        group.leave()
                    }
                }
                // Handle plain text
                else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] data, _ in
                        if let text = data as? String {
                            self?.saveAndRedirect(value: text, type: "text")
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.completeRequest()
        }
    }

    override func configurationItems() -> [Any]! {
        return []
    }

    private func saveAndRedirect(value: String, type: String) {
        // Save to App Group shared UserDefaults
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let sharedData: [String: Any] = [
            "value": value,
            "type": type,
            "timestamp": Date().timeIntervalSince1970
        ]
        userDefaults?.set(sharedData, forKey: sharedKey)
        userDefaults?.synchronize()

        // Open the main app via URL scheme
        let urlString = "\(urlScheme)://shared?type=\(type)&value=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    // Open URL from extension (uses responder chain)
    @objc private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = responder?.next
        }
        // Fallback for iOS 16+
        let selector = sel_registerName("openURL:")
        var response: UIResponder? = self
        while response != nil {
            if response!.responds(to: selector) {
                response!.perform(selector, with: url)
                return
            }
            response = response?.next
        }
    }
}
