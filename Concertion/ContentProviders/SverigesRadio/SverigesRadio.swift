import Foundation

typealias NSDictType = Dictionary<String, AnyObject>

class SverigesRadio {
    let ChannelsURL = NSURL(string: "http://api.sr.se/api/v2/channels")!
    let ProgramsURL = NSURL(string: "http://api.sr.se/api/v2/programs")!
    let ProgramsIndexForChannel = { (channelId: Int) -> (NSURL) in
        return NSURL(string: String(format: "http://api.sr.se/api/v2/programs/index?channelid=%d", channelId))!
    }
    let EpisodeIndexURL = NSURL(string: "http://api.sr.se/api/v2/episodes/index")!
    
    struct Channel {
        let id: Int
        let name: String
        let imageURL: NSURL
        let siteURL: NSURL
        let liveAudioFileURL: NSURL
        
        static func fromXMLDictionaryElement(info :NSDictType) -> (Channel) {
            let liveAudioInfo = info["liveaudio"] as NSDictionary as NSDictType
            
            return Channel(
                id: (info["_id"] as NSString).integerValue,
                name: info["_name"] as NSString as String,
                imageURL: NSURL(string: info["image"] as NSString as String)!,
                siteURL: NSURL(string: info["siteurl"] as NSString as String)!,
                liveAudioFileURL: NSURL(string: liveAudioInfo["url"] as NSString as String)!
            )
        }
        
        func fetchPrograms() -> Fetch<ProgramList> {
            return SverigesRadio().programs(self.id)
        }
    }
    
    typealias ChannelList = Array<Channel>
    
    func channels() -> Fetch<ChannelList> {
        return XMLFetch(ChannelsURL) { (data: NSDictType) -> (ChannelList) in
            let channelsDict = data["channels"] as NSDictionary
            
            let channelsInfos = (channelsDict["channel"] as NSArray) as Array<NSDictType>
            
            return channelsInfos.map { (info: NSDictType) -> Channel in
                return Channel.fromXMLDictionaryElement(info)
            }
        }
    }
    
    struct ChannelLink {
        let id: Int
        let name: String
        
        /** Fetch the complete channel data */
        func fetch() -> Fetch<Channel> {
            let URL = NSURL(string: String(format: "http://api.sr.se/api/v2/channels/%d", self.id))!
            return XMLFetch(URL) { (data: NSDictType) -> (SverigesRadio.Channel) in
                let channelInfo = data["channel"] as NSDictionary as NSDictType
                return SverigesRadio.Channel.fromXMLDictionaryElement(channelInfo)
            }
        }
    }
    
    struct Program {
        let id: Int
        let name: String
        let channel: ChannelLink
        let hasOnDemand: Bool
        let hasPod: Bool
        let imageURL: NSURL
        let description: String?
        
        static func fromXMLDictionaryElement(info: NSDictType) -> (Program) {
            let channelInfo = info["channel"] as NSDictionary as NSDictType
            
            return Program(
                id: (info["_id"] as NSString).integerValue,
                name: info["_name"] as NSString as String,
                channel: ChannelLink(
                    id: (channelInfo["_id"] as NSString as String).toInt()!,
                    name: channelInfo["_name"] as NSString as String
                ),
                hasOnDemand: (info["hasondemand"] as NSString).boolValue,
                hasPod: (info["haspod"] as NSString).boolValue,
                imageURL: NSURL(string: info["programimage"] as NSString as String)!,
                description: info["description"] as NSString? as String?
            )
        }
        
        func fetchEpisodes() -> Fetch<EpisodeList> {
            return SverigesRadio().episodes(self.id)
        }
    }
    
    typealias ProgramList = Array<Program>
    
    func programs() -> Fetch<ProgramList> {
        return XMLFetch(ProgramsURL) { (data: NSDictType) -> (ProgramList) in
            let programsDict = data["programs"] as NSDictionary
            let programInfos = programsDict["program"] as NSArray as Array<NSDictType>
            
            return programInfos.map { (info: NSDictType) -> Program in
                return Program.fromXMLDictionaryElement(info)
            }
        }
    }
    
    func programs(channelId: Int) -> Fetch<ProgramList> {
        return XMLFetch(ProgramsIndexForChannel(channelId)) { (data: NSDictType) -> (ProgramList) in
            let programsDict = data["programs"] as NSDictionary
            let programInfos = programsDict["program"] as NSArray as Array<NSDictType>
            
            return programInfos.map { (info: NSDictType) -> Program in
                return Program.fromXMLDictionaryElement(info)
            }
        }
    }

    
    
    struct Episode {
        let id: Int
        let name: String
        let description: String?
        let imageURL: NSURL
        let broadcastURL: NSURL?
        
        
        static func _broadcastURL(info: NSDictType) -> NSURL? {
            if let a = info["broadcast"] as? NSDictionary {
                if let b = a["broadcastfiles"] as? NSDictionary {
                    if let c = b["broadcastfile"] as? NSDictionary {
                        if let d = c["url"] as? NSString {
                            return NSURL(string: d as String)
                        }
                    }
                    if let c = b["broadcastfile"] as? NSArray {
                        if let d = c.firstObject as? NSDictionary {
                            if let e = d["url"] as? NSString {
                                return NSURL(string: e as String)
                            }
                        }
                    }
                }
            }
            return nil
        }
        
        static func _podURL(info: NSDictType) -> NSURL? {
            if let a = info["listenpodfile"] as? NSDictionary {
                if let b = a["url"] as? NSString {
                    return NSURL(string: b as String)
                }
            }
            return nil;
        }
        
        static func fromXMLDictionaryElement(info: NSDictType) -> (Episode) {
            print(info)
            var fileURL: NSURL? = self._broadcastURL(info)
            if (fileURL == nil) {
                fileURL = self._podURL(info)
            }
            
            return Episode(
                id: (info["_id"] as NSString).integerValue,
                name: info["title"] as NSString as String,
                description: info["description"] as NSString? as String?,
                imageURL: NSURL(string: info["imageurl"] as NSString as String)!,
                broadcastURL: fileURL
            )
        }
    }
    
    typealias EpisodeList = Array<Episode>
    
    func episodes(programid: Int) -> Fetch<EpisodeList> {
        let URL = NSURL(string:String(format: "%@?programid=%d", EpisodeIndexURL.absoluteString!, programid))!
        return XMLFetch(URL) { (data: NSDictType) -> (EpisodeList) in
            let episodesDict = data["episodes"] as NSDictionary
            let episodeInfos =  episodesDict["episode"] as NSArray as Array<NSDictType>

            return episodeInfos.map { (info: NSDictType) -> Episode in
                Episode.fromXMLDictionaryElement(info)
            }
        }
    }
}



