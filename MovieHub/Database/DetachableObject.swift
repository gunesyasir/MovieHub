//
//  DetachableObject.swift
//  MovieHub
//
//  Created by Yasir Gunes on 9.04.2025.
//

import Foundation
import RealmSwift

protocol DetachableObject: AnyObject {
  func detached() -> Self
}

extension Object: DetachableObject {
  func detached() -> Self {
    let detached = type(of: self).init()
    for property in objectSchema.properties {
      guard let value = value(forKey: property.name) else {
        continue
      }
      if let detachable = value as? DetachableObject {
        detached.setValue(detachable.detached(), forKey: property.name)
      } else { // Then it is a primitive
        detached.setValue(value, forKey: property.name)
      }
    }
    return detached
  }
}

extension List: DetachableObject {
  func detached() -> List<Element> {
    let result = List<Element>()
    forEach {
      if let detachableObject = $0 as? DetachableObject,
        let element = detachableObject.detached() as? Element {
        result.append(element)
      } else { // Then it is a primitive
        result.append($0)
      }
    }
    return result
  }
}
