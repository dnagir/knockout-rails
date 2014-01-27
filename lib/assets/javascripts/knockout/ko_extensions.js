ko.isObservableArray = function(val) {
    return ko.isObservable(val) && val.destroyAll !== void 0;
}

/// Extending observableArray with 'mapped*' functions - Borrowed from KO Mapping plugin, pity it's not exposed as a utility function
/// Knockout Mapping plugin v2.4.1
/// (c) 2013 Steven Sanderson, Roy Jacobs - http://knockoutjs.com/
/// License: MIT (http://www.opensource.org/licenses/mit-license.php)

ko.mappedObservableArray = function (initial) {
    if (initial == undefined) {
        initial = []
    }
    mappedRootObject = ko.observableArray(initial);

    mappedRootObject.mappedRemove = function (valueOrPredicate) {
        var predicate = typeof valueOrPredicate == "function" ? valueOrPredicate : function (value) {
            return value === keyCallback(valueOrPredicate);
        };
        return mappedRootObject.remove(function (item) {
            return predicate(keyCallback(item));
        });
    }

    mappedRootObject.mappedRemoveAll = function (arrayOfValues) {
        var arrayOfKeys = filterArrayByKey(arrayOfValues, keyCallback);
        return mappedRootObject.remove(function (item) {
            return ko.utils.arrayIndexOf(arrayOfKeys, keyCallback(item)) != -1;
        });
    }

    mappedRootObject.mappedDestroy = function (valueOrPredicate) {
        var predicate = typeof valueOrPredicate == "function" ? valueOrPredicate : function (value) {
            return value === keyCallback(valueOrPredicate);
        };
        return mappedRootObject.destroy(function (item) {
            return predicate(keyCallback(item));
        });
    }

    mappedRootObject.mappedDestroyAll = function (arrayOfValues) {
        var arrayOfKeys = filterArrayByKey(arrayOfValues, keyCallback);
        return mappedRootObject.destroy(function (item) {
            return ko.utils.arrayIndexOf(arrayOfKeys, keyCallback(item)) != -1;
        });
    }

    mappedRootObject.mappedIndexOf = function (item) {
        var keys = filterArrayByKey(mappedRootObject(), keyCallback);
        var key = keyCallback(item);
        return ko.utils.arrayIndexOf(keys, key);
    }

    mappedRootObject.mappedGet = function (item) {
        return mappedRootObject()[mappedRootObject.mappedIndexOf(item)];
    }

    mappedRootObject.mappedCreate = function (value) {
        if (mappedRootObject.mappedIndexOf(value) !== -1) {
            throw new Error("There already is an object with the key that you specified.");
        }

        var item = hasCreateCallback() ? createCallback(value) : value;
        if (hasUpdateCallback()) {
            var newValue = updateCallback(item, value);
            if (ko.isWriteableObservable(item)) {
                item(newValue);
            } else {
                item = newValue;
            }
        }
        mappedRootObject.push(item);
        return item;
    }
    return mappedRootObject;
}