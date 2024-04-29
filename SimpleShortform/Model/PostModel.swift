//
//  PostModel.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation



struct PostModel : Codable {
    
    
    let contents : [Contents]?
    let description : String?
    let id : String?
    let influencer : Influencer?
    let like_count : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case contents = "contents"
        case description = "description"
        case id = "id"
        case influencer = "influencer"
        case like_count = "like_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contents = try values.decodeIfPresent([Contents].self, forKey: .contents)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        influencer = try values.decodeIfPresent(Influencer.self, forKey: .influencer)
        like_count = try values.decodeIfPresent(Int.self, forKey: .like_count)
    }
    
    
    
    struct Contents : Codable {
        let content_url : String?
        let type : String?
        
        enum CodingKeys: String, CodingKey {
            
            case content_url = "content_url"
            case type = "type"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            content_url = try values.decodeIfPresent(String.self, forKey: .content_url)
            type = try values.decodeIfPresent(String.self, forKey: .type)
        }
        
    }
    
    struct Influencer : Codable {
        let display_name : String?
        let follow_count : Int?
        let profile_thumbnail_url : String?
        
        enum CodingKeys: String, CodingKey {
            
            case display_name = "display_name"
            case follow_count = "follow_count"
            case profile_thumbnail_url = "profile_thumbnail_url"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            display_name = try values.decodeIfPresent(String.self, forKey: .display_name)
            follow_count = try values.decodeIfPresent(Int.self, forKey: .follow_count)
            profile_thumbnail_url = try values.decodeIfPresent(String.self, forKey: .profile_thumbnail_url)
        }
        
    }
    
    
}
