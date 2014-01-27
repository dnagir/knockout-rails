# Similar to js typeof, but returns class names for prototyped objects
kor = @kor ||= {}
kor.utils ||= {}

kor.utils.getType = (obj) ->
  if obj == undefined or obj == null
    return String obj
  className = obj.constructor.name
  if "Boolean Number String Function Array Date RegExp Object".split(" ").indexOf(className) != -1
    return className.toLowerCase()

  return className
