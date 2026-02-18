import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedContent()
    }

    private func handleSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                        if let url = data as? URL {
                            self?.saveAndOpenApp(urlString: url.absoluteString)
                        }
                    }
                    return
                } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                        if let text = data as? String, let url = URL(string: text), url.scheme != nil {
                            self?.saveAndOpenApp(urlString: text)
                        } else {
                            self?.completeRequest()
                        }
                    }
                    return
                }
            }
        }

        completeRequest()
    }

    private func saveAndOpenApp(urlString: String) {
        // Save to App Group shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.momrise.app")
        sharedDefaults?.set(urlString, forKey: "SharedRecipeURL")
        sharedDefaults?.synchronize()

        // Open the main app via URL scheme
        let appURL = URL(string: "momecoach://share?url=\(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString)")!
        openURL(appURL)

        completeRequest()
    }

    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = responder?.next
        }
        // Fallback for iOS 16+ extension context
        extensionContext?.open(url, completionHandler: nil)
    }

    private func completeRequest() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}
