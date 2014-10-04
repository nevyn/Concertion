import Foundation

typealias NSDictType = Dictionary<String, AnyObject>

class Fetch<T> {
    typealias TransformFunc = (dict: NSDictType) -> (T)
    typealias CompleteFunc = (value: T) -> ()
    typealias ErrorFunc = (error: NSError) -> ()
    
    let URL: NSURL
    let transformFunc: TransformFunc
    var completeFunc: CompleteFunc?
    var errorFunc: ErrorFunc?
    
    var completedValue: T?
    var completedError: NSError?
    
    init(_ URL: NSURL, transform: TransformFunc) {
        self.URL = URL
        self.transformFunc = transform
        
        self.run()
    }
    
    func run() {
        let request = NSURLRequest(URL: self.URL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if data != nil && self.completeFunc != nil {
                let parser = XMLDictionaryParser()
                let dict = parser.dictionaryWithData(data) as NSDictType
                let result = self.transformFunc(dict: dict)
                self.completedValue = result
                
                if (self.completeFunc != nil) {
                    self.completeFunc!(value: result)
                }
            } else if self.errorFunc != nil {
                print(error.userInfo?.values.array);
                self.completedError = error
                
                if (self.errorFunc != nil) {
                    self.errorFunc!(error: error)
                }
            }
        }
    }
    
    func onComplete(cb:CompleteFunc) -> Fetch {
        self.completeFunc = cb
        if (completedValue != nil) {
            cb(value: completedValue!)
        }
        return self
    }
    
    func onError(cb: ErrorFunc) -> Fetch {
        self.errorFunc = cb
        if (completedError != nil) {
            cb(error: completedError!)
        }
        return self
    }

}

class SverigesRadio {
    let ChannelsURL = NSURL(string: "http://api.sr.se/api/v2/channels")
    let ProgramsURL = NSURL(string: "http://api.sr.se/api/v2/programs")
    let EpisodeIndexURL = NSURL(string: "http://api.sr.se/api/v2/episodes/index")
    
    struct Channel {
        let name: String
        let imageURL: NSURL
        let siteURL: NSURL
        let liveAudioFileURL: NSURL
        
        static func fromXMLDictionaryElement(info :NSDictType) -> (Channel) {
            let liveAudioInfo = info["liveaudio"] as NSDictionary as NSDictType
            
            return Channel(
            name: info["_name"] as NSString as String,
            imageURL: NSURL(string: info["image"] as NSString as String),
            siteURL: NSURL(string: info["siteurl"] as NSString as String),
            liveAudioFileURL: NSURL(string: liveAudioInfo["url"] as NSString as String)
            )
        }
    }
    
    func channels() -> Fetch<Array<Channel>> {
        return Fetch(ChannelsURL) { (data: NSDictType) -> (Array<Channel>) in
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
            let URL = NSURL(string: String(format: "http://api.sr.se/api/v2/channels/%d", self.id))
            return Fetch(URL) { (data: NSDictType) -> (SverigesRadio.Channel) in
                let channelInfo = data["channel"] as NSDictionary as NSDictType
                return SverigesRadio.Channel.fromXMLDictionaryElement(channelInfo)
            }
        }
    }
    
    struct Program {
        let name: String
        let channel: ChannelLink
        let hasOnDemand: Bool
        let hasPod: Bool
        let imageURL: NSURL
        let description: String?
        
        static func fromXMLDictionaryElement(info: NSDictType) -> (Program) {
            let channelInfo = info["channel"] as NSDictionary as NSDictType
            
            return Program(
                name: info["_name"] as NSString as String,
                channel: ChannelLink(
                    id: (channelInfo["_id"] as NSString as String).toInt()!,
                    name: channelInfo["_name"] as NSString as String
                ),
                hasOnDemand: (info["hasondemand"] as NSString).boolValue,
                hasPod: (info["haspod"] as NSString).boolValue,
                imageURL: NSURL(string: info["programimage"] as NSString as String),
                description: info["description"] as NSString? as String?
            )
        }
    }
    
    func programs() -> Fetch<Array<Program>> {
        return Fetch(ProgramsURL) { (data: NSDictType) -> (Array<Program>) in
            let programsDict = data["programs"] as NSDictionary
            let programInfos = programsDict["program"] as NSArray as Array<NSDictType>
            
            return programInfos.map { (info: NSDictType) -> Program in
                return Program.fromXMLDictionaryElement(info)
            }
        }
    }
    
}
