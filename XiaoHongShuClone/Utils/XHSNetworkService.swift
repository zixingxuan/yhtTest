import Foundation
import RxSwift
import RxCocoa

// MARK: - Network Models
struct FeedResponse: Codable {
    let items: [FeedItem]
    let hasMore: Bool
    let nextPage: Int?
}

struct FeedItem: Codable {
    let id: String
    let title: String
    let content: String
    let imageUrl: String
    let username: String
    let likes: Int
    let comments: Int
    let isVideo: Bool
}

struct ProductResponse: Codable {
    let items: [ProductItem]
    let hasMore: Bool
    let nextPage: Int?
}

struct ProductItem: Codable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String
    let shopName: String
    let sales: Int
}

// MARK: - Network Service using URLSession (simulating Moya)
class XHSNetworkService {
    static let shared = XHSNetworkService()
    private init() {}
    
    func fetchHomeFeed(page: Int = 1, limit: Int = 10) -> Observable<FeedResponse> {
        return Observable.create { observer in
            // 模拟网络请求延迟
            DispatchQueue.global().async {
                // 模拟网络请求
                let items = self.generateMockFeedItems(page: page, limit: limit)
                let hasMore = page < 5 // 模拟只有5页数据
                let nextPage = hasMore ? page + 1 : nil
                
                let response = FeedResponse(items: items, hasMore: hasMore, nextPage: nextPage)
                
                DispatchQueue.main.async {
                    observer.onNext(response)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMarketProducts(page: Int = 1, limit: Int = 10) -> Observable<ProductResponse> {
        return Observable.create { observer in
            DispatchQueue.global().async {
                let items = self.generateMockProductItems(page: page, limit: limit)
                let hasMore = page < 5
                let nextPage = hasMore ? page + 1 : nil
                
                let response = ProductResponse(items: items, hasMore: hasMore, nextPage: nextPage)
                
                DispatchQueue.main.async {
                    observer.onNext(response)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func generateMockFeedItems(page: Int, limit: Int) -> [FeedItem] {
        var items: [FeedItem] = []
        
        for i in 0..<limit {
            let index = (page - 1) * limit + i
            items.append(FeedItem(
                id: "feed_\(index)",
                title: "内容标题 \(index)",
                content: "这里是内容描述，展示了内容的详细信息和吸引人的描述语句 \(index)",
                imageUrl: "https://example.com/image\(index).jpg",
                username: "用户\(index % 10)",
                likes: Int.random(in: 10...500),
                comments: Int.random(in: 1...100),
                isVideo: Bool.random()
            ))
        }
        
        return items
    }
    
    private func generateMockProductItems(page: Int, limit: Int) -> [ProductItem] {
        var items: [ProductItem] = []
        
        for i in 0..<limit {
            let index = (page - 1) * limit + i
            items.append(ProductItem(
                id: "product_\(index)",
                name: "商品名称 \(index)",
                price: Double(Int.random(in: 50...500)),
                imageUrl: "https://example.com/product\(index).jpg",
                shopName: "店铺\(index % 5)",
                sales: Int.random(in: 10...1000)
            ))
        }
        
        return items
    }
}