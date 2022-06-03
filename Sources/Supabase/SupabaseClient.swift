import Foundation
import GoTrue
import PostgREST
import Realtime
import SupabaseStorage

public struct SupabaseClientOptions {
  /// The Postgres schema which your tables belong to. Must be on the list of exposed schemas in Supabase. Defaults to `public`.
  public let schema: String

  // Optional headers for initializing the client.
  public let headers: [String: String]

  public init(schema: String = "public", headers: [String: String] = [:]) {
    self.schema = schema
    self.headers = headers
  }
}

/// Supabase Client.
public class SupabaseClient {
  internal var supabaseURL: URL
  internal var supabaseKey: String
  internal var schema: String
  internal var restURL: URL
  internal var realtimeURL: URL
  internal var authURL: URL
  internal var storageURL: URL
  internal var headers: [String: String]
  internal var authHeaders: [String: String] {
    var headers = Constants.defaultHeaders
    headers["Authorization"] = "Bearer \(auth.session?.accessToken ?? supabaseKey)"
    return headers
  }

  /// Supabase Auth allows you to create and manage user sessions for access to data that is secured by access policies.
  public let auth: GoTrueClient

  /// Supabase Storage allows you to manage user-generated content, such as photos or videos.
  public var storage: SupabaseStorageClient {
    SupabaseStorageClient(url: storageURL.absoluteString, headers: authHeaders)
  }

  /// Perform a table operation.
  /// - Parameter table: The table name to operate on.
  public func from(_ table: String) -> PostgrestQueryBuilder {
    PostgrestClient(
      url: restURL.absoluteString, headers: authHeaders, fetch: nil, schema: schema
    ).from(table)
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count: Count algorithm to use to count rows in a table.
  public func rpc<U: Encodable>(
    fn: String,
    params: U,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    PostgrestClient(
      url: restURL.absoluteString, headers: authHeaders, fetch: nil, schema: schema
    ).rpc(fn: fn, params: params, count: count)
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - count: Count algorithm to use to count rows in a table.
  public func rpc(fn: String, count: CountOption? = nil) -> PostgrestTransformBuilder {
    PostgrestClient(
      url: restURL.absoluteString, headers: authHeaders, fetch: nil, schema: schema
    ).rpc(fn: fn, count: count)
  }

  /// Realtime client for Supabase
  public var realtime: RealtimeClient

  /// Create a new client.
  /// - Parameters:
  ///   - supabaseURL: The unique Supabase URL which is supplied when you create a new project in your project dashboard.
  ///   - supabaseKey: The unique Supabase Key which is supplied when you create a new project in your project dashboard.
  ///   - options: Additional options to pass to the internal clients.
  public init(
    supabaseURL: URL,
    supabaseKey: String,
    options: SupabaseClientOptions = SupabaseClientOptions()
  ) {
    precondition(supabaseKey.isEmpty == false, "supabaseKey is required.")

    self.supabaseURL = supabaseURL
    self.supabaseKey = supabaseKey
    self.schema = options.schema
    restURL = supabaseURL.appendingPathComponent("/rest/v1")
    realtimeURL = supabaseURL.appendingPathComponent("/realtime/v1")
    authURL = supabaseURL.appendingPathComponent("/auth/v1")
    storageURL = supabaseURL.appendingPathComponent("/storage/v1")

    headers = options.headers.merging(Constants.defaultHeaders) { _, new in new }
    headers["apikey"] = supabaseKey

    auth = GoTrueClient(
      url: authURL,
      headers: headers
    )

    realtime = RealtimeClient(
      endPoint: realtimeURL.absoluteString,
      params: headers
    )
  }
}
