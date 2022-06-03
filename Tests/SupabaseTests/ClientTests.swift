import XCTest

@testable import Supabase

final class ClientTests: XCTestCase {

  let url = URL(string: "http://localhost:3000")!
  let key = "some.fake.key"

  func testInitWithDefaults() {
    let client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    XCTAssertEqual(client.supabaseURL, url)
    XCTAssertEqual(client.supabaseKey, key)
    XCTAssertEqual(client.restURL, URL(string: "http://localhost:3000/rest/v1"))
    XCTAssertEqual(client.realtimeURL, URL(string: "http://localhost:3000/realtime/v1"))
    XCTAssertEqual(client.authURL, URL(string: "http://localhost:3000/auth/v1"))
    XCTAssertEqual(client.storageURL, URL(string: "http://localhost:3000/storage/v1"))
    XCTAssertEqual(client.schema, "public")
    XCTAssertEqual(client.headers["apikey"], key)
    XCTAssertEqual(client.headers["X-Client-Info"], "supabase-swift/\(Constants.version)")
  }

  func testInitWithCustomOptions() {
    let client = SupabaseClient(
      supabaseURL: url,
      supabaseKey: key,
      options: SupabaseClientOptions(schema: "private", headers: ["X-Test-Header": "value"])
    )

    XCTAssertEqual(client.schema, "private")
    XCTAssertEqual(client.headers["X-Test-Header"], "value")
  }
}
