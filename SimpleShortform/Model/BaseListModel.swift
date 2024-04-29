//
//  BaseListModel.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation

struct BaseListModel : Codable {
    let count : Int?
    let page : Int?
    let posts : [PostModel]?

    enum CodingKeys: String, CodingKey {

        case count = "count"
        case page = "page"
        case posts = "posts"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        posts = try values.decodeIfPresent([PostModel].self, forKey: .posts)
    }

}
