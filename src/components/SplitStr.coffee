# The SplitStr component receives a string in the in port, splits it by
# string specified in the delimiter port, and send each part as a separate
# packet to the out port

noflo = require "../../lib/NoFlo"

class SplitStr extends noflo.Component
    constructor: ->
        @delimiterString = "\n"
        @strings = []
        @groups = []

        @inPorts =
            in: new noflo.Port()
            delimiter: new noflo.Port()
        @outPorts =
            out: new noflo.Port()
        @inPorts.delimiter.on "data", (data) =>
            if data.substr(0, 1) is '/' and data.substr(data.length - 1, 1) is '/'
                # Handle regular expressions
                data = new RegExp data.substr 1, data.length - 2
            @delimiterString = data
        @inPorts.in.on "begingroup", (group) =>
            @groups.push(group)
        @inPorts.in.on "data", (data) =>
            @strings.push data
        @inPorts.in.on "disconnect", (data) =>
            for group in @groups
                @outPorts.out.beginGroup(group)
            @strings.join(@delimiterString).split(@delimiterString).forEach (line) =>
                @outPorts.out.send line
            for group in @groups
                @outPorts.out.endGroup()
            @outPorts.out.disconnect()
            @strings = []
            @groups = []

exports.getComponent = ->
    new SplitStr()
