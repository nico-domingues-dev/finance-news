import Foundation

public struct TrendingNew: Decodable, Identifiable {
  public let id: String
  let title: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case attributes
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    let attributes = try container.decode(TrendingNewsAttribute.self, forKey: .attributes)
    self.title = attributes.title
  }
}

public struct TrendingNewsAttribute: Codable {
  let title: String
}
