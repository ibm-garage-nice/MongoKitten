//
// This source file is part of the MongoKitten open source project
//
// Copyright (c) 2016 - 2017 OpenKitten and the MongoKitten project authors
// Licensed under MIT
//
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/LICENSE.md for license information
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/CONTRIBUTORS.md for the list of MongoKitten project authors
//

import Async

extension MongoCollection {
    @discardableResult
    public func touch(data: Bool, index: Bool) -> Future<Void> {
        let command = Commands.Touch(collection: self, data: data, index: index)
        
        return self.connectionPool.retain().flatten(command.execute)
    }
    
    @discardableResult
    public func convert(toCap cap: Int) -> Future<Void> {
        let command = Commands.ConvertToCapped(collection: self, toCap: cap)
        
        return self.connectionPool.retain().flatten(command.execute)
    }
    
    @discardableResult
    public func rebuildIndexes() -> Future<Void> {
        let command = Commands.RebuildIndexes(collection: self)
        
        return self.connectionPool.retain().flatten(command.execute)
    }
    
    @discardableResult
    public func compact(forced force: Bool? = nil) -> Future<Void> {
        var command = Commands.Compact(collection: self)
        
        command.force = force
        
        return self.connectionPool.retain().flatten(command.execute)
    }
    
    @discardableResult
    public func clone(renameTo otherCollection: String, cappingAt cap: Int) -> Future<Void> {
        let command = Commands.CloneCollectionAsCapped(collection: self, newName: otherCollection, cap: cap)
        
        return self.connectionPool.retain().flatten(command.execute)
    }
    
    @discardableResult
    public func drop() -> Future<Void> {
        let command = Commands.Drop(collection: self)
        
        return self.connectionPool.retain().flatten(command.execute)
    }
}

extension Commands {
    struct Touch: Command {
        var touch: String
        var data: Bool
        var index: Bool
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection, data: Bool, index: Bool) {
            self.touch = collection.name
            self.data = data
            self.index = index
            self.targetCollection = collection
        }
    }
    
    struct ConvertToCapped: Command {
        var convertTocapped: String
        
        // TODO: Int32?
        var size: Int
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection, toCap cap: Int) {
            self.convertTocapped = collection.name
            self.size = cap
            self.targetCollection = collection
        }
    }
    
    struct RebuildIndexes: Command {
        var reIndex: String
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection) {
            self.reIndex = collection.name
            self.targetCollection = collection
        }
    }
    
    struct Compact: Command {
        var compact: String
        var force: Bool?
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection) {
            self.compact = collection.name
            self.targetCollection = collection
        }
    }
    
    struct CloneCollectionAsCapped: Command {
        var cloneCollectionAsCapped: String
        var toCollection: String
        var size: Int
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection, newName: String, cap: Int) {
            self.targetCollection = collection
            self.cloneCollectionAsCapped = collection.name
            self.toCollection = newName
            self.size = cap
        }
    }
    
    struct Drop: Command {
        var drop: String
        
        let targetCollection: MongoCollection
        
        static var writing = true
        static var emitsCursor = false
        
        init(collection: Collection) {
            self.drop = collection.name
            self.targetCollection = collection
        }
    }
}
