import Foundation
import UIKit

/// Service for interfacing with the iOS built-in dictionary
class DictionaryService {
    static let shared = DictionaryService()
    
    private init() {}
    
    /// Check if a word has a definition in the device's dictionary
    /// - Parameter word: The word to check
    /// - Returns: True if the word has a definition
    func hasDefinition(for word: String) -> Bool {
        return UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word)
    }
    
    /// Present the dictionary view for a word
    /// - Parameters:
    ///   - word: The word to look up
    ///   - viewController: The view controller to present from
    func presentDictionary(for word: String, from viewController: UIViewController) {
        guard hasDefinition(for: word) else { return }
        
        let dictionaryViewController = UIReferenceLibraryViewController(term: word)
        viewController.present(dictionaryViewController, animated: true)
    }
    
    /// Get the definition for a word
    /// - Note: This is a mock implementation as there is no official API to get definitions as text
    /// - Parameter word: The word to define
    /// - Returns: A simulated definition string
    func getDefinition(for word: String) -> String {
        // In a real app, you might use a third-party dictionary API here
        // Apple doesn't provide an API to get the definition text directly
        
        return "Sample definition for '\(word)'. In a real implementation, this would be retrieved from an external dictionary API."
    }
}