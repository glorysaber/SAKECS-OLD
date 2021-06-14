//
//  MutableValueRef+ComponentBranch.swift
//  SAKECS
//
//  Created by Stephen Kac on 5/28/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase

extension MutableValueReference: ComponentBranch where Element: ComponentBranch {

	public var componentArchetype: ComponentArchetype {
		wrappedValue.componentArchetype
	}

	public var entityCount: Int {
		wrappedValue.entityCount
	}

	public var componentTypeCount: Int {
		wrappedValue.componentTypeCount
	}

	public var freeIndexCount: Int {
		wrappedValue.freeIndexCount
	}

	public var minimumCapacity: Int {
		wrappedValue.minimumCapacity
	}

	public func reserveCapacity(_ minimumCapcity: Int) {
		wrappedValue.reserveCapacity(minimumCapcity)
	}

	public func contains(entity: Entity) -> Bool {
		wrappedValue.contains(entity: entity)
	}

	public func add(entity: Entity) {
		wrappedValue.add(entity: entity)
	}

	public func remove(entity: Entity) {
		wrappedValue.remove(entity: entity)
	}

	public func contains<Component>(component componentType: Component.Type) -> Bool where Component: EntityComponent {
		wrappedValue.contains(component: componentType)
	}

	public func set<Component>(
		component: Component,
		for entity: Entity
	) where Component: EntityComponent {
		wrappedValue.set(component: component, for: entity)
	}

	public func add<Component>(
		component componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.add(component: componentType)
	}

	public func remove<Component: EntityComponent>(
		component componentType: Component.Type
	) {
		wrappedValue.remove(component: componentType)
	}

	public func get<Component: EntityComponent>(
		component componentType: Component.Type,
		for entity: Entity
	) -> Component? {
		wrappedValue.get(component: componentType, for: entity)
	}

	public func contains(componentWith familyID: ComponentFamilyID) -> Bool {
		wrappedValue.contains(componentWith: familyID)
	}

	public func remove(componentWith familyID: ComponentFamilyID) {
		wrappedValue.remove(componentWith: familyID)
	}
}
