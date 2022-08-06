//
//  Utilities.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/5/22.
//

import Foundation

class Utilities {
    
    static let shared = Utilities()
    
    func encodeData<T: Encodable, K: CodingKey>( _ data: T, using encoder: Encoder, with key: KeyedEncodingContainer<K>.Key) {
        var values = encoder.container(keyedBy: K.self)
        
        do { try values.encode(data, forKey: key) }
        catch { print( "there was en error encoding the data, keyed by: \( key.stringValue ) using: \( values )" ) }
    }
    
    func decodeData<T: Decodable, K: CodingKey>( in values: KeyedDecodingContainer<K>, with key: KeyedDecodingContainer<K>.Key, defaultValue: T? = nil ) -> T? {
        var value: T? = defaultValue
        do { value = try values.decode(T.self, forKey: key) }
        catch { print( "there was an error decoding the data, keyed by: \( key.stringValue ), using: \(values)" ) }
        return value
    }
}
