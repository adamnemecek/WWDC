//
//  ScheduleResponseAdapter.swift
//  WWDC
//
//  Created by Guilherme Rambo on 21/02/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

private enum ScheduleKeys: String, JSONSubscriptType {
    case response, rooms, tracks, sessions
    
    var jsonKey: JSONKey {
        return JSONKey.key(rawValue)
    }
}

final class ScheduleResponseAdapter: Adapter {
    
    typealias InputType = JSON
    typealias OutputType = ScheduleResponse
    
    func adapt(_ input: JSON) -> Result<ScheduleResponse, AdapterError> {
        guard let roomsJson = input[ScheduleKeys.response][ScheduleKeys.rooms].array else {
            return .error(.missingKey(ScheduleKeys.rooms))
        }
        
        guard let tracksJson = input[ScheduleKeys.response][ScheduleKeys.tracks].array else {
            return .error(.missingKey(ScheduleKeys.rooms))
        }
        
        guard let instancesJson = input[ScheduleKeys.response][ScheduleKeys.sessions].array else {
            return .error(.missingKey(ScheduleKeys.rooms))
        }
        
        guard case .success(let rooms) = RoomsJSONAdapter().adapt(roomsJson) else {
            return .error(.invalidData)
        }
        
        guard case .success(let tracks) = TracksJSONAdapter().adapt(tracksJson) else {
            return .error(.invalidData)
        }
        
        guard case .success(let instances) = SessionInstancesJSONAdapter().adapt(instancesJson) else {
            return .error(.invalidData)
        }
        
        rooms.forEach { room in
            let instances = instances.filter({ $0.roomName == room.name })
            room.instances.append(objectsIn: instances)
        }
        
        let response = ScheduleResponse(rooms: rooms,
                                        tracks: tracks,
                                        instances: instances)
        
        return .success(response)
    }
    
}