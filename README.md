[![Platform](https://img.shields.io/cocoapods/p/CVGenericDataSource.svg?style=flat)](http://cocoadocs.org/docsets/CVGenericDataSource)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/mittenimraum/CVGenericDataSource.svg?branch=master)](https://travis-ci.org/mittenimraum/CVGenericDataSource)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CVGenericDataSource.svg)](cocoadocs.org/docsets/CVGenericDataSource)
[![Language: Swift-3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)](https://swift.org)

# CVGenericDataSource

CVGenericDataSource is a generic data source for `UICollectionView`. It simplifies the use by offering a type-safe configuration structure and removes boilerplate as there is no need to implement the `UICollectionViewDataSource`, `UICollectionViewDelegate` or `UICollectionViewDataSourcePrefetching` protocols anymore. The library has builtin features for supporting state based collection views, progressive loading, synchronization or diffing and a more fine grained life cycle of collection view cells.


```swift
dataSource = CVDataSource(
    sections: [
        CVSection([Entity(), Entity(), Entity()], [
            .selection { (entity, index) in
                // do something
            }
        ]),
    ],
    cellFactory:
        CVCellFactory<Entity, Cell>([
            .setup { (cell, entity, indexPath) in
                // do something
            }
        ]),
    options: [
        .cellSpacing(1)
    ])

dataSource.bind(collectionView: collectionView)
```

## Requirements

- iOS 9.0+
- Swift 3.0+
- Xcode 8.1+

## Installation
	
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `CVGenericDataSource` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'CVGenericDataSource'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `CVGenericDataSource` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "mittenimraum/CVGenericDataSource"
```

Run `carthage update` to build the framework and drag the built `CVGenericDataSource.framework` into your Xcode project.

## Usage

You can find more examples in the [demo project](./Example/) part of this repository.

### Basic Example

For simplicity just a small featureset of data source is shown.

```swift
class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.dataSource.bind(collectionView: collectionView)
    }
}

class ViewCell: CVCell {

    @IBOutlet weak var label: UILabel!

    override class var ReuseIdentifier: String {
        return String(describing: BasicCell.self)
    }
}

struct ViewModel {

    struct Content: Equatable {
    
        var title: String?
    }
    
    let dataSource: 
    CVDataSource<CVSection<Content>,
    CVCellFactory<Content, ViewCell>,
    CVSupplementaryViewFactory<UICollectionReusableView>,
    CVStateFactory<UICollectionViewCell, UICollectionViewCell>>
    
    init() {
        dataSource = CVDataSource(
            sections: [
                CVSection([
                    Content(title: "Hello"),
                    Content(title: "World")])],
            cellFactory:
                CVCellFactory<Content, ViewCell>([
                    .size(CGSize(width: 100, height: 100))
                    .setup { (cell, item, indexPath) in
                        cell.label.text = item?.title
                    }
                ]), 
            options: [
                .selection { (section, item, cell, indexPath) in
                    // do something                
                }
            ]
        )
    }
}

func == (a: ViewModel.Content, b: ViewModel.Content) -> Bool {
    return a.title == b.title
}    
```
*From top to bottom:*

- One of the design principles of the data source is to keep our `UIViewController` slim, therefore all we have to do in this example is to bind the collection view to the data source with the `bind(collectionView: UICollectionView)` method.

- The used collection view cell `ViewCell` is subclassed from `CVCell` which offers more fine grained life cycle with methods like `create`, `layout`, `prepare` or `reset`. If we don't want to sublcass `CVCell`, we just have to implement the `CVReusableViewProtocol`. The class variable `ReuseIdentifier` will help us to dequeue the cell automatically from the collection view without registering the cell manually.

- Our model for each collection view cell is called `Content`. It's a struct that conforms to `Equatable` in order to allow synchronization or diffing.

- The data source will be created with three parameters: `sections`, `cellFactory` and `options`:

    - `sections` contains data structure of all sections and cells that will be displayed in the collection view. 
    - `cellFactory` contains the factory that will generate our collection view cells. The types given to the factory define the model that we will use for each cell e.g. `Content` and the `UICollectionViewCell` that will be dequeued automatically e.g. `ViewCell`. By using options in the initializer of the factory we define the size that each collection view cell will have and setup the cell.
    - `options` contains additional options for the data source. In the example we use the `selection` option to create a callback for the user interaction of selecting a cell.

- As our entity `Content` conforms to `Equatable`, at last comes our comparison function.
	
## Overview

- [States](#states)
- [Loading Operations](#loading-operations)
- [Progressive Loading](#progressive-loading)
- [Synchronization / Diffing](#synchronization)
- [Prefetching](#prefetching)
- [Cells and Supplementary Views](#cells-and-supplementary-views)
- [Life Cycle for Cells and Supplementary Views](#life-cycle-for-cells-and-supplementary-views)
- [Layout Options](#layout-options)

### States

A common scenario when using collection views is to show a certain cell if the collection view is empty or starts loading data. For this case the data source offers a state factory that will automatically dequeue and display a cell for an empty or loading state. The data source can have the following states:

```swift
public enum CVDataSourceState {
    case inited, empty, ready, loading
}
```

The `inited` state is present right after the data source has been initialized. Assuming that the data source was initialized without any sections, the default behaviour is to switch to `empty` state as soon as a collection view has been bound to the data source. The data source will dequeue and display the UICollectionViewCell that was given as a type to the state factory:

```swift
CVDataSource(
    sections: [],
    ...
    stateFactory: CVStateFactory<EmptyCell, LoadingCell>([
        .setup { (type: CVStateFactoryType, view) in
            // do something
        },
        .size {
            CGSize
        }
    ]),
    options: [
        .shouldShowState { state in ... }
    ]
)
```
It's possible to control the appearance of the state cells by using the `.shouldShowState { state in ... }` option. The closure will be executed each time the state will change to `empty` or `loading`. By returning `true` or `false` it's up to us if the collection view should display the `empty` or `loading` cell or not.
 
Once a loading operation was started, the state will change to `loading`. If the data source is empty at this point and a collection view has been bound, the collection will display the cell that has been configured for the `loading` state in the state factory within the full collection view bounds except the `.size` option is used in the options of the `CVStateFactory`, otherwise the collection view will stay unchanged.

Once a loading operation has been finished, the state will change to `ready` or if the data source is still empty after the load operation to `empty`.

### Loading Operations

In conjuction with [states](#states) the data source supports loading operations. These are intended to be convenience functions to make the data management more easy. A use case could be pagination for example. Let's assume we want to add data to the data source at a certain point in future. The `load()` method could be used to trigger the corresponding data source option:

```swift
.load { (section: Int, offset: Int, result: @escaping CVLoadResult) in {
    // prepare data and return it asynchronously if necessary
    
    result(data, .insert)
}
```
The `.load` closure will be executed for each existing section in the data source which allows to add more items per section if necessary. How the new data should be integrated into a section can be defined with a case of the `CVDataSourceOperation` enumeration:

```swift
public enum CVDataSourceOperation {
    case insert, synchronize
}
```
- `.insert` will append the new data
- `.synchronize` will remove or add items depending on the difference of the old and new data

The parameter `offset` will contain the number of items that have been already loaded for a particular `section`. Once the `result` closure has been called for a particular section, the data source will automatically render the changes in the corresponding collection view.  The `load` function goes hand in hand with the [progressive loading concept](#progressive-loading).

Further loading operations that will render the collection view automatically are:

```swift
// Will load a particular section
load(section: Int)

// Will remove all existing sections and call load() afterwards
reload()

// Will remove all existing sections, add new sections and call load() afterwards
reload(newSections sections: [S])
```

### Progressive Loading

The data source supports progressive loading for vertical and horizontal collection view layouts which means, that the data source will try to automatically load new data if the scroll position of the collection view is near to it's maximum. This is an often used scenario for paginated collection views. By default the progressive loading is turned off. To enable the feature use the `.shouldLoadMore { true }` option.

As the `.shouldLoadMore` option could return a dynamic value, the progressive loading could be turned off if no more data is available. The following example shows how to use the option  with a paginated collection view:

```swift
var shouldLoadMore = true

CVDataSource(
    ...
    options: [
        .load { (section: Int, offset: Int, result: @escaping CVLoadResult) in {
            let data: [S.Item] = ...
            
            shouldLoadMore = data.count > 0 && data.count >= pageSize
        
            result(data, .insert)
        },
        .shouldLoadMore { 
            shouldLoadMore
        }
    ]
)
```
In case we want to suppress that `load()` is called everytime we reach the maximum of the collection view's scroll position we could use the `.loadMore` option to do custom operations.

```swift
CVDataSource(
    ...
    options: [
        .loadMore { 
            // do something different instead of using load() automatically            
        }
    ]
)
```

### Synchronization

Each section in the data source can be synchronized the following methods:

```swift
func synchronize(sections: [S])
func synchronize(items: [S.Item], inSection section: Int)
```
This will compare the new data with the already existing data of a section and remove all items that are not part of the new data anymore and add all new items that are not part of the existing data. As the generic type `S.Item` implements `Equatable` the comparison can be defined with `func == (a: S.Item, b: S.Item) -> Bool`. The data source will render all changes in the corresponding collection view automatically.

### Prefetching

The data source supports prefetching introduced in iOS 10 by using the corresponding options:

```swift
.prefetch { (section: Int, items: [S.Item]) in

}
.cancelPrefetch { (section: Int, items: [S.Item]) in

}
```

### Cells and Supplementary Views

As collection view cells and supplementary views are registered and dequeued automatically, we need to specify their type, reuseIdentifier and optionally nib name when instantiating the data source. This can be done by using either a `CVCellFactory`, `CVStateFactory` or `CVSupplementaryViewFactory` as well as overriding the following class variables:

```swift
override class var ReuseIdentifier: String {
    return String(describing: ...)
}

override class var NibName: String {
    return String(describing: ...)
}
```

By using factories for the different kind of cells and supplementary views we can specify their types and relationship to certain items in the data source.

```swift
class Cell: CVCell {
    override class var ReuseIdentifier: String {
        return String(describing: Cell.self)
    }
}

class SupplementaryView: CVSupplementaryView {
   override class var ReuseIdentifier: String {
        return String(describing: SupplementaryView.self)
    }
}

class EmptyCell: CVCell {
    override class var ReuseIdentifier: String {
        return String(describing: EmptyCell.self)
    }
}

class LoadingCell: CVSupplementaryView {
   override class var ReuseIdentifier: String {
        return String(describing: LoadingCell.self)
    }
}

CVDataSource(
    sections: [
        CVSection([Entity(), Entity(), Entity()])
    ],
    cellFactory:
        CVCellFactory<Entity, Cell>([
            .setup { (cell, entity, indexPath) in
                // do something
            },
            .size { (entity, indexPath) in
                CGSize
            }
        ]),
    supplementaryViewFactory:
        CVSupplementaryViewFactory<SupplementaryView>([
            .setup { (type: CVSupplementaryViewType, view, section) in
                // do something
            },
            .size {
                CGSize for all views
            },
            .sizeForSection { section in
                CGSize for a specific section
            }
        ]),
    stateFactory: 
        CVStateFactory<EmptyCell, LoadingCell>([
            .setup { (type: CVStateFactoryType, view) in
                // do something
            },
            .size { (type: CVStateFactoryType) in
                CGSize
            }
        ])
)
```

For using different cells or supplementary views within the data source take a look at the [custom views example](./Example/CVGenericDataSourceExample/Classes/Presentation/Screens/Custom).

### Life Cycle for Cells and Supplementary Views

Every `UICollectionViewCell` and `UICollectionReusableView` has new life cycle methods when using `CVGenericDataSource`:

```swift
// Called when awakeFromNib was called
func create() {
}

// Called when willDisplay was called
func prepare() {
}

// Called when didEndDisplaying was called
func cleanup() {
}
```

By subclassing `CVCell` for collection view cells or `CVSupplementaryView` for supplementary views two more life cycle methods are available:

```swift
// Called when the cell has a valid frame
func layout() {
}

// Called when prepareForReuse was called
func reset() {
}
```

### Layout Options

The layout spacing can be configured using the following options:

```swift
CVDataSource(
    sections: [
        CVSection(..., [
            .insets(UIEdgeInsets),
            .lineSpacing(CGFloat),
            .cellSpacing(CGFloat)
        ])
    ],
    ...
    options: [
        .insetsForSection { section in
            UIEdgeInsets
        },
        .insets(UIEdgeInsets),
        .lineSpacing(CGFloat),
        .cellSpacing(CGFloat)
    ]
)

```
As it is possible to use appearance options for a particular section as well as for the data source, the options of a `CVSection` will be always used first. In case there are no appearance options, the options of the data source will be used. The default values for spacings are `0`, for insets `.zero`.

## Appendix
The current implementation of `CVGenericDataSource` was heavily inspired by Jesse Squires [JSQDataSourcesKit](https://github.com/jessesquires/JSQDataSourcesKit). In fact, there are parts used from his implementation, so thanks [Jesse](https://github.com/jessesquires)!

### Discussion
- Although the `CVGenericDataSource` tends to be a complete replacement for the `UICollectionViewDataSource`, `UICollectionViewDelegate` or `UICollectionViewDataSourcePrefetching` protocols, it won't work in some cases as the full featureset of these protocols hasn't been implemented yet. 

- The concept of using one factory for each view type ( cells and supplementary views ) doesn't work out so much if we need to use several different cells and views in our collection view. Although it's possible and shown in the [custom views example](./Example/CVGenericDataSourceExample/Classes/Presentation/Screens/Custom) there is too much boilerplate. I like the approach Matthias is using in his `UITableView` [data source implementation](https://github.com/mbuchetics/DataSource) by using an array of descriptors for each view type. So this might get changed soon.

### Contribution

Contributions are always welcome, please check the [contribution guidelines](./CONTRIBUTION.md).

### Other great data sources

- [JSQDataSourcesKit](https://github.com/jessesquires/JSQDataSourcesKit)
- [DataSource](https://github.com/mbuchetics/DataSource)
- [GenericDataSource](https://github.com/GenericDataSource/GenericDataSource)
- [TaylorSource](https://github.com/danthorpe/TaylorSource)

### License
`CVGenericDataSource` is released under the MIT license. See LICENSE for details.