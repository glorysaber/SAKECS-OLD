//
//  ComponentMatrix.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

// MARK: - RowContainerProtocol

// Used to allow for homogeneous storage of reference wrapping containers
private protocol RowContainerProtocol: AnyObject {
	/// Gets the count of the columns of the stored row
	var count: Int { get }

	/// Grows the columns of the stored row
	/// - Parameter toGrowBy: The number of columns to grow by
	func growColumns(by toGrowBy: Int)


	/// The contained element
	var containedElement: ComponentRowProtocol { get }
}

// MARK: - ComponentRowIndex

/// The row for a component array  in the component matrix
public struct ComponentRowIndex: Index {
	public let index: Int

	public init(index: Int) {
		self.index = index
	}
}

// MARK: - ComponentMatrix

/// The storage representation of the components which belong to entities
public struct ComponentMatrix {

	/// A contianer for each row to allow mutability
	private class RowContainer<Component: EntityComponent>: RowContainerProtocol {
		var containedElement: ComponentRowProtocol {
			row
		}

		var count: Int {
			row.count
		}

		func growColumns(by toGrowBy: Int) {
			row.growColumns(by: toGrowBy)
		}

		var row: ComponentRow<Component>

		init(_ row: ComponentRow<Component>) {
			self.row = row
		}
	}

	/// The counts of the different types of Components
	public var containedComponentTypesCount: Int {
		componentFamilyMatrixRowMap.count
	}

	/// Count of colums in the matrix, as all component arrays must be equal
	public var componentColumns: Int {
		matrix.first?.count ?? 0
	}

	/// A map of the index for a component family.
	private(set) var componentFamilyMatrixRowMap = [ComponentFamilyID: ComponentRowIndex]()

	/// The components storage
	private var matrix = [RowContainerProtocol]()

	public init() {}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func get<Component: EntityComponent>(_ type: Component.Type) -> ComponentRow<Component> {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return []
		}

		guard let rowContainer = matrix[componentMatrixRow.index] as? RowContainer<Component> else {
			assert(false, "Internal logic error, the componentFamilyMatrixRowMap does not match the matrix")
			return []
		}

		return rowContainer.row
	}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func get<Component: EntityComponent>(_ type: Component.Type, for column: ComponentColumnIndex) -> Component? {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return nil
		}

		return (matrix[componentMatrixRow.index] as? RowContainer<Component>)?.row[column] ?? nil
	}

	/// Gets the component for the given type and column
	/// - Parameter component: The component to add
	public mutating func set<Component: EntityComponent>(_ component: Component, for column: ComponentColumnIndex) {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return
		}

		guard let rowContainer = matrix[componentMatrixRow.index] as? RowContainer<Component>  else {
			assert(false, "Encountered nexpected type at row: \(componentMatrixRow.index) ")
			return
		}
		rowContainer.row[column] = component
	}

	public mutating func addColumns(_ count: Int) {
		for rowContainer in matrix {
			rowContainer.growColumns(by: count)
		}
	}

	/// Removes a component type from the matrix
	/// O(C) Time complexity wher C is the number of component types
	/// - Parameter type: The component type being removed
	public mutating func remove<Component: EntityComponent>(_ type: Component.Type) {
		guard let componentMatrixRowToRemove = componentFamilyMatrixRowMap[Component.familyID] else {
			// Do nothing as we do not have that componenet type
			return
		}

		for (type, row) in componentFamilyMatrixRowMap where row > componentMatrixRowToRemove {
			componentFamilyMatrixRowMap[type] = row - 1
		}

		matrix.remove(at: componentMatrixRowToRemove.index)
		componentFamilyMatrixRowMap.removeValue(forKey: Component.familyID)
	}

	/// Adds a new component type to the internal storage.  O(1) Time Complexity operation.
	/// - Parameter familyID: The type of component for the array
	/// - Returns: The row for the new matrix row
	@discardableResult
	public mutating func add<Component: EntityComponent>(_ type: Component.Type) -> ComponentRowIndex {
		let componentMatrixRow = ComponentRowIndex(matrix.count)

		// Create a new component array filled with the same number of columns as the other components arrays
		let componentRow = ComponentRow<Component>()
		matrix.append(RowContainer(componentRow))
		componentFamilyMatrixRowMap[Component.familyID] = componentMatrixRow
		return componentMatrixRow
	}
}

// MARK: - Collections

// MARK: RandomAccessCollection

extension ComponentMatrix: RandomAccessCollection {

	public subscript(rowIndex: ComponentRowIndex) -> ComponentRowProtocol {
			matrix[rowIndex.index].containedElement
	}

	public typealias Element = ComponentRowProtocol

	public var startIndex: ComponentRowIndex {
		ComponentRowIndex(matrix.startIndex)
	}

	public var endIndex: ComponentRowIndex {
		ComponentRowIndex(matrix.endIndex)
	}

	public var count: Int {
		containedComponentTypesCount
	}

	public var first: ComponentRowProtocol? {
		matrix.first?.containedElement
	}

	public var last: ComponentRowProtocol? {
		matrix.last?.containedElement
	}

	public func index(after index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(after: index.index))
	}

	public func index(before index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(before: index.index))
	}

	public struct Iterator: IteratorProtocol {
		public typealias Element = ComponentRowProtocol

		private let matrix: [RowContainerProtocol]
		private var position = 0

		public mutating func next() -> ComponentRowProtocol? {
			defer {
				position += 1
			}
			guard position < matrix.count else {
				return nil
			}

			return matrix[position].containedElement
		}

		fileprivate init(matrix: [RowContainerProtocol]) {
			self.matrix = matrix
		}

	}

	public __consuming func makeIterator() -> Iterator {
		Iterator(matrix: matrix)
	}
}

// MARK: Index functions for ComponentColumns

public extension ComponentMatrix {

	var columnIndices: ClosedRange<ComponentColumnIndex> {
		componentColumns == 0 ?
			ComponentColumnIndex(0)...ComponentColumnIndex(0) :
			ComponentColumnIndex(0)...ComponentColumnIndex(componentColumns - 1)
	}

	/// The position of the first element in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnStartIndex: ComponentColumnIndex {
		matrix.first?.containedElement.startIndex ?? ComponentColumnIndex(0)
	}

	/// The position of the last element plus one in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnEndIndex: ComponentColumnIndex {
		matrix.first?.containedElement.endIndex ?? ComponentColumnIndex(0)
	}

	/// Returns the position immediately after the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index after the given index
	func columnIndex(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.containedElement.index(after: index) ?? index + 1
	}

	/// Returns the position immediately before the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index before the given index
	func columnIndex(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.containedElement.index(before: index) ?? index - 1
	}
}

// MARK: - description

extension ComponentMatrix: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		"The matrix consists of \(count) types of components and \(componentColumns) columns"
	}

	public var debugDescription: String {
		"""
		typeCount: \(count)
		componentCount: \(componentColumns)
		matrix: \(matrix)
		"""
	}
}