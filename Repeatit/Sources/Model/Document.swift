//
//  Document.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct Document: Hashable, Codable {
    let url: URL
    let isDirectory: Bool

    init(url: URL, isDirectory: Bool = false) {
        self.url = url
        self.isDirectory = isDirectory
    }
}

extension Document: Identifiable {
    var id: String {
        return url.absoluteString
    }
}

extension Document {
    var isAudioFile: Bool {
        return URL.supportedAuidoFormats.contains(pathExtension)
    }

    var isVideoFile: Bool {
        return URL.supportedVideoFormats.contains(pathExtension)
    }

    var isYouTubeFile: Bool {
        return pathExtension == "youtube"
    }

    var isSupportedSubtitleFile: Bool {
        return URL.supportedSubtitleFormats.contains(pathExtension)
    }

    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }

    var nameWithExtension: String {
        return url.lastPathComponent
    }

    var pathExtension: String {
        return (nameWithExtension as NSString).pathExtension.lowercased()
    }

    var metadata: MediaMetadata {
        return MediaMetadata(url: url)
    }

    var imageName: String {
        if isDirectory {
            return "folder.fill"
        }
        if isAudioFile {
            return "music.note"
        }
        if isVideoFile {
            return "video.fill"
        }
        if isYouTubeFile {
            return "play.rectangle.fill"
        }
        return "doc.text"
    }

    func toAudioItem() -> AudioItem {
        return AudioItem(url: url)
    }

    func toYouTubeItem() -> YouTubeItem {
        // TODO: When launching, It can be removed.
        let data = (try? Data(contentsOf: url)) ?? Data()
        if let item = try? JSONDecoder().decode(YouTubeItem.self, from: data) {
            return item
        }
        if let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any],
           let id = json["videoId"] as? String {
            return YouTubeItem(id: id)
        }
        return YouTubeItem(id: "")
    }
}

fileprivate extension URL {
    static let supportedFormats = URL.supportedAuidoFormats + URL.supportedVideoFormats
    static let supportedAuidoFormats = ["aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp3", "m4a", "snd", "au", "sd2", "wav"]
    static let supportedVideoFormats = ["mpeg", "avi", "mp4", "mov"]
    static let supportedSubtitleFormats = ["lrc", "srt", "vtt"]
}

extension YouTubeItem {
    static func from(document: Document) -> YouTubeItem? {
        return try? JSONDecoder().decode(YouTubeItem.self, from: Data(contentsOf: document.url))
    }
}
