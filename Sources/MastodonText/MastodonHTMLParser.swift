import Foundation

private let logger = makeLogger()

public final class MastodonHTMLParser: NSObject {
    private let html: String
    private let xml: String
    
    public init(html: String) {
        self.html = html
        xml = "<html>\(html)</html>"
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "<br>", with: "<br/>")
    }
    
    private var string: NSMutableString = ""
    private var links: [MastodonText.Link] = []
    private var attributes: [[String: String]] = []
    private var locations: [Int] = []
    
    public func parse() -> MastodonText {
        string = ""
        links = []
        attributes = []
        locations = []
        
        let parser = XMLParser(data: Data(xml.utf8))
        parser.delegate = self
        parser.parse()
        
        return MastodonText(string: string as String, links: links)
    }
}

// MARK: - XMLParserDelegate

extension MastodonHTMLParser: XMLParserDelegate {
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes: [String: String]
    ) {
        self.attributes.append(attributes)
        switch elementName {
        case "a":
            locations.append(string.length)
        case "br":
            string.append("\n")
        case "p" where string.length > 0:
            string.append("\n\n")
        default:
            break
        }
    }
    
    public func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?
    ) {
        let attributes = attributes.removeLast()
        switch elementName {
        case "a":
            let location = locations.removeLast()
            guard let href = attributes["href"], let url = URLComponents(string: href)?.url else { break }
            let link = MastodonText.Link(url: url, range: NSRange(location: location, length: string.length - location))
            links.append(link)
        default:
            break
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters characters: String) {
        switch attributes.last?["class"] {
        case "ellipsis":
            string.append(characters)
            string.append("...")
        case "invisible":
            break
        default:
            string.append(characters)
        }
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred error: Error) {
        logger.error("\(error)")
    }
}
