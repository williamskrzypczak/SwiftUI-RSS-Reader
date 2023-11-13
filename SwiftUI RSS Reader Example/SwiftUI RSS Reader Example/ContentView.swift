//
//  ContentView.swift
//  SwiftUI RSS Reader Example
//
//  Created by Bill Skrzypczak on 11/13/23.
//


import SwiftUI
import WebKit

struct ContentView: View {
    @State private var items: [RSSItem] = []
    
    var body: some View {
        NavigationView {
            List(items, id: \.title) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.description)
                        .font(.subheadline)
                }
            }
            .navigationTitle("RSS Reader")
            .onAppear {
                fetchRSSFeed()
            }
        }
    }
    
    func fetchRSSFeed() {
        if let url = URL(string: "https://www.bestradioyouhaveneverheard.com/podcasts/index.xml") {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    parseRSS(data: data)
                } else if let error = error {
                    print("Error fetching RSS feed: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func parseRSS(data: Data) {
        let parser = XMLParser(data: data)
        let rssParserDelegate = RSSParserDelegate()
        parser.delegate = rssParserDelegate
        
        if parser.parse() {
            items = rssParserDelegate.items
        } else {
            print("Error parsing RSS feed.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    
}

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var currentItem: RSSItem?
    var currentElement: String = ""
    var items: [RSSItem] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentItem = RSSItem(title: "", description: "")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
            case "title":
                currentItem?.title += data
            case "description":
                currentItem?.description += data
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let item = currentItem {
                items.append(item)
            }
            currentItem = nil
        }
    }
}
