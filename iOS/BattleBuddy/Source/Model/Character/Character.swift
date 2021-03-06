//
//  Character.swift
//  BattleBuddy
//
//  Created by Veritas on 10/16/19.
//  Copyright © 2019 Veritas. All rights reserved.
//

import Foundation
import BallisticsEngine

class Character {
    var json: [String: Any]
    var id: String
    var name: String
    var healthMap: [String: NSNumber]

    init?(json: [String : Any]) {
        self.json = json

        guard let rawId = json["_id"] as? String,
            let rawName = json["name"] as? String,
            let health = json["health"] as? [String: NSNumber] else {
                print("ERROR: Character missing required parameters in json: \(json)")
                return nil
        }

        id = rawId
        name = rawName
        healthMap = health
    }

    func convertedHealthMap() -> [BEZoneType: Double] {
        var convertedMap: [BEZoneType : Double]  = [:]
        for zone in BEZoneType.allCases {
            let zoneString = zone.getStringValue()
            if let healthNumber = healthMap[zoneString] {
                convertedMap[zone] = healthNumber.doubleValue
            } else {
                convertedMap[zone] = 0.0
            }
        }
        return convertedMap
    }
}

class SimulationCharacter: Character, CalculableCharacter {
    var aim: AimSetting = .upperBody
    var firearm: SimulationFirearm?
    var ammo: SimulationAmmo?
    var headArmor: SimulationArmor?
    var bodyArmor: SimulationArmor?

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SimulationCharacter(json: json)!
        copy.aim = aim
        if let headArmor = headArmor?.copy() as? SimulationArmor { copy.headArmor = headArmor }
        if let bodyArmor = bodyArmor?.copy() as? SimulationArmor { copy.bodyArmor = bodyArmor }
        if let firearm = firearm { copy.firearm = SimulationFirearm(json: firearm.json) }
        if let ammo = ammo { copy.ammo = SimulationAmmo(json: ammo.json) }
        return copy
    }

    var resolvedHealthMap: [BallisticsEngine.BodyZoneType : Double] {
        get {
            var convertedMap: [BodyZoneType : Double]  = [:]
            for zone in BodyZoneType.allCases {
                let zoneString = zone.getStringValue()
                if let healthNumber = healthMap[zoneString] {
                    convertedMap[zone] = healthNumber.doubleValue
                } else {
                    convertedMap[zone] = 0.0
                }
            }
            return convertedMap
        }
        set(newValue) {
            var newHealthMap: [String: NSNumber] = [:]
            for (key, value) in newValue {
                newHealthMap[key.getStringValue()] = NSNumber(value: value)
            }
            healthMap = newHealthMap
        }

    }
    var resolvedAimSetting: BallisticsEngine.AimSetting {
        get { return aim }
    }
    var resolvedFirearm: CalculableFirearm? {
        get { return firearm }
    }
    var resolvedAmmo: CalculableAmmo? {
        get { return ammo }
    }
    var resolvedBodyArmor: CalculableArmor? {
        get { return bodyArmor }
        set {
            guard let newValue = newValue else { return }
            bodyArmor?.currentDurability = Int(newValue.resolvedCurrentDurability)
        }
    }
    var resolvedHeadArmor: CalculableArmor? {
        get { return headArmor }
        set {
            guard let newValue = newValue else { return }
            headArmor?.currentDurability = Int(newValue.resolvedCurrentDurability)
        }
    }
}
