import Foundation
import UIKit

func scope(execute function: () -> ()) {
    function()
}

func identity<T>(_ value: T) -> T {
    return value
}

extension Sequence {
    
    var array: [Self.Element] {
        return self.map(identity)
    }
}

extension Sequence where Self.Element: Hashable {
    
    var set: Set<Self.Element> {
        return Set(self)
    }
    
    var uniqueArray: [Self.Element] {
        return self.set.array
    }
}

extension Sequence where Self.SubSequence: Sequence {
    
    func neighbourElements() -> [(current: Self.SubSequence.Element, previous: Self.Element)] {
        return zip(self.dropFirst(), self).array
    }
}

extension String.Index: Hashable {
    
    public var hashValue: Int {
        return self.encodedOffset
    }
}

extension String {
    
    func split(by comparator: Character.Comparator) -> [String] {
        let characterIndices = self.filter(comparator).flatMap(self.index)
        let indices = [self.startIndex, self.endIndex] + characterIndices
        
        return indices
            .uniqueArray
            .sorted()
            .neighbourElements()
            .map { String(self[$0.previous..<$0.current]) }
    }
}

extension Character {
    
    typealias Comparator = (Character) -> Bool
    
    func isUppercase() -> Bool {
        let string = String(self)
        
        return string == string.uppercased()
    }
}

"mamaPapaDedaBaba".split { $0.isUppercase() }

func compact<Type, Result>(_ function: @escaping (Type) -> () -> Result) -> (Type) -> Result {
    return { function($0)() }
}

precedencegroup ApplicationPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator §: ApplicationPrecedence

func § <Value, Result>(function: (Value) -> Result, value: Value) -> Result {
    return function(value)
}

scope {
    func compact<Type, Result>(_ function: @escaping (Type) -> () -> Result) -> (Type) -> Result {
        return { function § $0 § () }
    }
}

"MamaPapaDedaBaba".split(by: compact(Character.isUppercase))

print("MamaPapaDedaBaba".split(by: compact(Character.isUppercase)))
print("mamaPapaDedaBaba".split { $0.isUppercase() })

prefix operator ∑->
prefix func ∑-> <Type, Result>(_ function: @escaping (Type) -> () -> Result) -> (Type) -> Result {
    return { function § $0 § () }
}

["mama", "papa"].map(∑->String.uppercased)

print(["mama", "papa"].map(∑->String.uppercased))

precedencegroup CompositionPrecedence {
    higherThan: ApplicationPrecedence
    associativity: left
}

infix operator • : CompositionPrecedence
func • <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
    return { rhs(lhs § $0) }
}

["mama", "papa"].map(∑->String.uppercased • ∑->String.dropFirst • String.init)

precedencegroup CompactPrecedence {
    higherThan: CompositionPrecedence
    associativity: left
}

infix operator §-> : CompactPrecedence
func §-> <Type, Arguments, Result>(
    _ function: @escaping (Type) -> (Arguments) -> Result,
    arguments: Arguments
)
    -> (Type) -> Result
{
    return { function § $0 § arguments }
}

["mama", "papa"].map(String.capitalized §-> nil)

["mama", "papa"].map(
    String.capitalized §-> .current • Array.init
)

print(["mama", "papa"].map(String.capitalized §-> nil))

protocol TypeStringConvertible { }
extension TypeStringConvertible {
    
    static var typeString: String {
        return String(describing: self)
    }
    
    var typeString: String {
        return String(describing: type(of: self))
    }
}

extension NSObject: TypeStringConvertible { }

func typeString<T>(_ type: T.Type) -> String {
    return String(describing: type)
}

func typeString<T>(_ value: T) -> String {
    return typeString(type(of: value))
}

extension CGRect {
    
    var x: CGFloat {
        get { return self.origin.x }
        set { self.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return self.origin.y }
        set { self.origin.y = newValue }
    }
    
    var width: CGFloat {
        get { return self.size.width }
        set { self.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return self.size.height }
        set { self.size.height = newValue }
    }
}

extension CGSize {
    
    var min: CGFloat {
        return Swift.min(self.width, self.height)
    }

    func scaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

enum Image { }
extension Image {
    enum Size: String {
        case thumb
        case small
        case medium
        case large
        case full
    }
}

extension Image.Size {
    
    // MARK: -
    // MARK: Static
    
    static var all: [Image.Size] {
        return [.thumb, .small, .medium, .large, .full]
    }
    
    // MARK: -
    // MARK: Properties
    
    var dimension: CGFloat? {
        let screen = UIScreen.main
        let dimension = screen.bounds.size.min * screen.scale
        
        switch self {
        case .thumb: return dimension / 8
        case .small: return dimension / 4
        case .medium: return dimension / 2
        case .large: return dimension
        case .full: return nil
        }
    }
    
    // MARK: -
    // MARK: Public
    
    func multiplier(for size: CGSize) -> CGFloat {
        return self.dimension.map { $0 / size.min } ?? 1
    }
    
    func size(for size: CGSize) -> CGSize {
        return size.scaled § self.multiplier(for: size)
    }
}

extension UIImage {
    
    func resize(_ size: Image.Size) -> UIImage? {
        print("resized to size = \(size)")
        return self
    }
}

protocol ImageRepresentable {
    var opaque: UIImage? { get }
    func sized(_ size: Image.Size) -> UIImage?
}

extension ImageRepresentable where Self: RawRepresentable, Self.RawValue == String  {

    // NOTE: playgrounds require file extensions
    var opaque: UIImage? {
        return UIImage(named: self.name)
    }
    
    func sized(_ size: Image.Size) -> UIImage? {
        return self.opaque.flatMap(UIImage.resize §-> size)
    }
    
    private var name: String {
        return self.shouldOverrideConvention ? self.conventionName : self.rawValue
    }
    
    private var conventionName: String {
        return [typeString § self, self.rawValue]
            .flatMap(String.split §-> ∑->Character.isUppercase)
            .map(∑->String.lowercased)
            .joined(separator: "_")
    }
    
    private var shouldOverrideConvention: Bool {
        return "\(self)" == self.rawValue
    }
}

extension Image {
    enum Login: String, ImageRepresentable {
        case logo = "nope.jpg"
        case image
    }
}

let logo = Image.Login.logo
logo.opaque
logo.sized(.full)

let label = UILabel()
label.text = NSLocalizedString("label_content_identifier", comment: "localized")

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

label.text = "label_content_identifier".localized

protocol RawStringRepresentable: CustomStringConvertible { }
extension RawStringRepresentable where Self: RawRepresentable, Self.RawValue: CustomStringConvertible {
    
    var description: String {
        return self.rawValue.description
    }
}

protocol LocalizedStringConvertible: RawStringRepresentable {
    var localizedDescription: String { get }
    var localizationIdentifier: String { get }
}

extension LocalizedStringConvertible {
    
    var localizedDescription: String {
        return NSLocalizedString(self.localizationIdentifier, comment: "")
    }
    
    var localizationIdentifier: String {
        return "\(typeString § self).\(self)".lowercased()
    }
}

enum Strings: String, LocalizedStringConvertible {
    case ok
    case cancel

    enum Login: String, LocalizedStringConvertible {
        case login = "signin"
    }
}

print(Strings.Login.login.localizationIdentifier)
