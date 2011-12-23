# x.y.z - in progress

- Support collections (fetch multiple records)
- JST templating support

# 1.0.1 - 23 December 2011

- Fix: ensure the validations are executed initially


# 1.0.0 - 22 December 2011

- Breaking change: `@configure` should be `@persistAt`
- Custom model events and callbacks
- Declarative client side validation

# 0.0.4-5 - 20 December 2011

- Fix to inplace edit to be able to switch back to view mode when no value has changed

# 0.0.3 - in progress

- Support collections (fetch multiple records)
- Client side validation
- JST templating support

# 0.0.2-3 - 26 November 2011

- do not require bindings automatically
- includes bindings: autosave, inplace, onoff, color, animate

# 0.0.1 - 17 November 2011
Initial release. Bare bones moved over from other project. Includes:

- persist view models RESTfully
- compliant with Rails inherited_resources response
- built in, bindable server side validation support (errors accessible vie `model.errors.attribute_name()`)

