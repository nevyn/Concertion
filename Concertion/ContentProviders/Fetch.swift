import Foundation

class Fetch<T> {
    typealias TransformFunc = (data: NSData) -> (T)
    typealias CompleteFunc = (value: T) -> ()
    typealias ErrorFunc = (error: NSError) -> ()
    
    let URL: NSURL
    let transformFunc: TransformFunc
    var completeFunc: CompleteFunc?
    var errorFunc: ErrorFunc? = { (error) in
         print(error)
    }
    
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
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let result = self.transformFunc(data: data)
                    self.completedValue = result
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if (self.completeFunc != nil) {
                            self.completeFunc!(value: result)
                        }
                    })
                })
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

extension UIImage {
    class func fetch(URL :NSURL, onComplete: Fetch<UIImage>.CompleteFunc) -> Fetch<UIImage> {
        return Fetch<UIImage>(URL) { (data) in
            return UIImage(data: data)!
        }.onComplete(onComplete)
    }
}

class XMLFetch<T>: Fetch<T> {
    typealias XMLTransformFunc = (data: NSDictType) -> (T)
    
    init(_ URL: NSURL, transform: XMLTransformFunc) {
        super.init(URL, transform: { (data) -> T in
            let parser = XMLDictionaryParser()
            let dict = parser.dictionaryWithData(data) as NSDictType
            return transform(data: dict)
        })
    }
}


