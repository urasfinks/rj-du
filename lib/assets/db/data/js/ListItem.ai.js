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
            var listItem = data["list"] || [];
            this.updateItem(listItem);
            bridge.call("SetStateData", {
                "map": {
                    "title": data.label,
                    "theme": data.theme,
                    "listItem": listItem
                }
            });
        }
    };

    this.updateItem = function(list){
        for(var i=0;i<list.length;i++){
            list[i]["onTap"] = {
                "sysInvoke": "NavigatorPush",
                "args": {
                    "type": "bottomSheet",
                    "selected": list[i],
                    "height": 460,
                    "link": {
                        "template": "editListItem/" + bridge.state["main"]["theme"] + ".json",
                    }
                }
            };
        }
    };

    this.save = function () {
        var uuid = bridge.pageArgs.data.uuid;
        var data = bridge.args["fetchDb"][0]["value_data"];
        bridge.call("DataSourceSet", {
            "debugTransaction": true,
            "uuid": uuid,
            "type": bridge.pageArgs.data.type,
            "updateIfExist": true,
            "onUpdateOverlayJsonValue": true,
            "value": {
                "list": bridge.state["main"]["listItem"]
            }
        });
    };

    this.add = function () {
        var listItem = bridge.state["main"]["listItem"] || [];
        var curNewIndex = 0;
        for (var i = 0; i < listItem.length; i++) {
            if (listItem[i].label.startsWith("Новый ")) {
                var c = parseInt(listItem[i].label.split("Новый ")[1], 10);
                if (!isNaN(c) && curNewIndex < c * 1) {
                    curNewIndex = c * 1;
                }
            }
        }
        var newItem = {
            "label": "Новый " + (curNewIndex + 1)
        };
        listItem.unshift(newItem);
        this.updateItem(listItem);
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
        this.save();
        bridge.call("NavigatorPush", {
            "type": "bottomSheet",
            "selected": newItem,
            "height": 460,
            "link": {
                "template": "editListItem/" + bridge.state["main"]["theme"] + ".json",
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
        this.save();
    };
}

bridge.addRouter(new ListItemRouter());