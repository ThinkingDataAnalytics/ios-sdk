# HMCThreadSafeMutableCollection
[![Version](https://img.shields.io/cocoapods/v/HMCThreadSafeMutableCollection.svg?style=flat)](http://cocoapods.org/pods/HMCThreadSafeMutableCollection)
[![License](https://img.shields.io/cocoapods/l/HMCThreadSafeMutableCollection.svg?style=flat)](http://cocoapods.org/pods/HMCThreadSafeMutableCollection)
[![Platform](https://img.shields.io/cocoapods/p/HMCThreadSafeMutableCollection.svg?style=flat)](http://cocoapods.org/pods/HMCThreadSafeMutableCollection)

NSMutableArray, NSMutableDictionary is threadunsafe (race condition would appear when a NSMutableArray, NSMutableDictionary accessed from multiple threads). This project is a threadsafe wrapper, which provides base methods for creating, adding, removing and accessing object in an array without race condition.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate HMCThreadSafeMutableCollection into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'HMCThreadSafeMutableCollection'
end
```

Then, run the following command:

```bash
$ pod install
```
## Usage

### HMCThreadSafeMutableArray

#### 1. Create an empty instance

```Objective-C
HMCThreadSafeMutableArray *array = [[HMCThreadSafeMutableArray alloc] init];
```

#### 2. Create from a NSArray

```Objective-C
NSArray *array = @[@1,@2,@3];
HMCThreadSafeMutableArray *tsarray = [[HMCThreadSafeMutableArray alloc] initWithArray:array];
```

#### 3. Add one object to the end of array

```Objective-C
- (void)addObject:(NSObject *)object;
```

#### 4. Add multiple objects from NSArray

```Objective-C
- (void)addObjectsFromArray:(NSArray *)array;
```

#### 5. Insert an object with index to array

```Objective-C
- (void)insertObject:(NSObject *)object
             atIndex:(NSUInteger)index;
```

#### 6. Remove an object from array

```Objective-C
- (void)removeObject:(NSObject *)object;
```

#### 7. Remove object at index from array

```Objective-C
- (void)removeObjectAtIndex:(NSUInteger)index;
```

#### 8. Remove all objects

```Objective-C
- (void)removeAllObjects;
```

#### 9. Get object at index in array

```Objective-C
- (id)objectAtIndex:(NSUInteger)index;
```

#### 10. Get number of elements in array

```Objective-C
- (NSUInteger)count;
```

#### 11. Filter array using prdicate

```Objective-C
- (NSArray *)filteredArrayUsingPredicate: (NSPredicate *) predicate;
```

#### 12. Get index of object

```Objective-C
- (NSInteger)indexOfObject: (NSObject *)object;
```

#### 13. Check whether array contains object

```Objective-C
- (BOOL)containsObject: (id)object;
```

#### 14. Convert to NSArray contains all elements
```Objective-C
- (NSArray *)toNSArray;
```

### HMCThreadSafeMutableDictionary

#### 1. Create an empty instance

```Objective-C
HMCThreadSafeMutableDictionary *dict = [[HMCThreadSafeMutableDictionary alloc] init];
```

#### 2. Get, add or change object using subscript

```Objective-C
dict[@"a"] = @1;
id object = dict[@"a"];
```

#### 3. Remove all objects

```Objective-C
- (void)removeAllObjects;
```

#### 4. Remove object for key

```Objective-C
- (void)removeObjectForkey:(NSString *)key;
```

#### 5. Convert to NSDictionray

```Objective-C
- (NSDictionary *)toNSDictionary;
```

## Author

chuonghuynh, minhchuong.itus@gmail.com

## License

HMCThreadSafeMutableCollection is available under the MIT license. See the LICENSE file for more info.
