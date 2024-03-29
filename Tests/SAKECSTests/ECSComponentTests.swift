//
//  ECSComponentTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 3/17/19.
//  Copyright © 2019 Stephen Kac. All rights reserved.
//

import XCTest
@testable import SAKECS

class ECSComponentTests: XCTestCase {
  
  var ecs: ECSManager?
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ecs = ECSManager()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ecs = nil
  }
  
  func testComponent() {
    guard let ecs = ecs else { XCTAssert(false, "ECS not initialized"); return }
    
    guard let enities = ecs.createEntities(100) else { XCTAssert(false, "ECS failed to created 100 entities"); return }
    
    struct StringComponent: Component { let value: String }
    struct IntComponent: Component { let value: Int }
    struct BoolComponent: Component { let value: Bool }
    
    
  }
  
}
