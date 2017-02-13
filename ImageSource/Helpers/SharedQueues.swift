struct SharedQueues {
    
    static let imageProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        
        /*
         Это фиксит ситуацию на iPhone 4, когда создавалось слишком много потоков для операций запроса фотки,
         и суммарная используемая ими память порождала крэш из-за нехватки памяти. Данное решение не приводит к
         лагам, работает шустро даже на iPhone 4.
         
         TODO: (ayutkin) В дальнейшем нужно сделать возможность отмены операций, которые создаются в requestImage,
         и отменять их из UI — например, при переключении между фотками в пикере.
         */
        queue.maxConcurrentOperationCount = 3
        
        return queue
    }()
}
