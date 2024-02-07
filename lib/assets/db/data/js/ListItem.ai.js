function ListItemRouter() {
    this.constructor = function () {
        var uuid = bridge.pageArgs.data.uuid;
        bridge.call("DbQuery", {
            "sql": "select * from data where uuid_data = ?",
            "args": [uuid],
            "onFetch": {
                "jsRouter": "ListItem.ai.js",
                "args": {
                    "method": route(this, this.onSelect)
                }
            }
        });
        bridge.call("Show", {
            "case": "actionButton",
            "template": {
                "flutterType": "FloatingActionButton",
                "child": {
                    "flutterType": "Icon",
                    "src": "add"
                },
                "onPressed": {
                    "jsRouter": "ListItem.ai.js",
                    "args": {
                        "method": "add"
                    }
                }
            }
        });
    };

    this.onSelect = function () {
        if (bridge.args["fetchDb"].length > 0) {
            var data = bridge.args["fetchDb"][0]["value_data"];
            var listItem = bridge.state["main"]["listItem"] || [];
            this.updateTemplate(listItem);
            bridge.call("SetStateData", {
                "map": {
                    "title": data.label,
                    "listItem": listItem
                }
            });
        }
    };

    this.updateTemplate = function (listItem) {
        for (var i = 0; i < listItem.length; i++) {
            listItem[i]["template"] = {
                "flutterType": "Text",
                "label": "Hello"
            };
        }
    }

    this.add = function () {
        var listItem = bridge.state["main"]["listItem"] || [];
        listItem.unshift({
            "label": ""
        });
        this.updateTemplate(listItem);
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
    };

    this.remove = function () {
        var listItem = bridge.state["main"]["listItem"];
        bridge.arrayRemove(listItem, bridge.args["removeIndex"] * 1);
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
    };
}

bridge.addRouter(new ListItemRouter());