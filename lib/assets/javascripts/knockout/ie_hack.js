// constructor.name hack
if (Function.prototype.name === undefined && Object.defineProperty !== undefined) {
    Object.defineProperty(Function.prototype, 'name', {
        get: function () {
            var funcNameRegex = /function\s([^(]{1,})\(/;
            var results = (funcNameRegex).exec((this).toString());
            return (results && results.length > 1) ? results[1].trim() : "";
        },
        set: function (value) {
        }
    });
}

// console.log hack
if (!window['console']) {
    window.console = {};
}
var console_methods = ["log", "warn", "info", "debug"];
var method;
for (var i = 0; i < console_methods.length; ++i) {
    method = console_methods[i]
    if (!window['console'][method]) {
        window.console[method] = function () {
        };
    }
}