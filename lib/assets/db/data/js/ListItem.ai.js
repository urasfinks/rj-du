function ListItemRouter() {
    this.constructor = function () {
        bridge.call("SetStateData", {
            "notify": false,
            "map": {
                "openEditItem": false
            }
        });
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
                        "method": route(this, this.add)
                    }
                }
            }
        });
    };

    this.onSelect = function () {
        if (bridge.args["fetchDb"].length > 0) {
            var data = bridge.args["fetchDb"][0]["value_data"];
            var listItem = data["list"] || [];
            this.updateItem(listItem, data.theme);
            bridge.call("SetStateData", {
                "map": {
                    "title": data.label,
                    "theme": data.theme,
                    "listItem": listItem
                }
            });
        }
    };

    this.updateItem = function (list, theme) {
        for (var i = 0; i < list.length; i++) {
            if (list[i]["onTap"] == undefined) {
                list[i]["onTap"] = {
                    "sysInvoke": "NavigatorPush",
                    "args": this.getNavigatorPushArgs(JSON.parse(JSON.stringify(list[i])), i, theme)
                };
            }
        }
    };

    this.openEditItem = function () {
        bridge.call("SetStateData", {
            "notify": false,
            "map": {
                "openEditItem": true
            }
        });
    }

    this.save = function (listItem) {
        var uuid = bridge.pageArgs.data.uuid;
        var listItem = JSON.parse(JSON.stringify(listItem));
        for (var i = 0; i < listItem.length; i++) {
            if (listItem[i]["onTap"] != undefined) {
                delete listItem[i]["onTap"];
            }
            if (listItem[i]["_virtual"] != undefined) {
                delete listItem[i]["_virtual"];
            }
        }
        bridge.call("DataSourceSet", {
            //"debugTransaction": true,
            "uuid": uuid,
            "type": bridge.pageArgs.data.type,
            "updateIfExist": true,
            "onUpdateOverlayJsonValue": true,
            "value": {
                "list": listItem
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
        this.updateItem(listItem, bridge.state["main"]["theme"]);
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
        this.save(listItem);
        bridge.call("NavigatorPush", this.getNavigatorPushArgs(newItem, 0, bridge.state["main"]["theme"]));
    };

    this.getNavigatorPushArgs = function (selected, indexItem, theme) {
        return {
            "type": "bottomSheet",
            "selected": selected,
            "parentPageUuid": bridge.pageUuid,
            "indexItem": indexItem,
            "height": bridge.pageArgs.data.bottomSheetHeight,
            "link": {
                "template": "editListItem/" + theme + ".json",
            },
            "constructor": {
                "jsRouter": "ListItem.ai.js",
                "args": {
                    "method": route(this, this.openEditItem),
                    "changeContext": bridge.pageUuid
                }
            }
        };
    }

    this.changeField = function () {
        //bridge.log(bridge.args);
        //{"changeContext":"a9223bec-c319-42d0-9bd0-a0b415b590f4","indexItem":"0","fieldKey":"label","method":"changeField","value":"Новый 1и"}
        var listItem = bridge.state["main"]["listItem"] || [];
        var any = bridge.args["value"].split("\n");
        if (any.length == 1) {
            var item = listItem[bridge.args["indexItem"] * 1];
            item[bridge.args["fieldKey"]] = bridge.args["value"].trim();
        } else if (any.length > 1) {
            var newListItem = [];
            for (var i = 0; i < listItem.length; i++) {
                if (i == bridge.args["indexItem"] * 1) {
                    for (var j = 0; j < any.length; j++) {
                        if (any[j].trim() != "") {
                            var item = JSON.parse(JSON.stringify(listItem[i]));
                            item[bridge.args["fieldKey"]] = any[j].trim();
                            if (j > 0) {
                                item["_virtual"] = true;
                            }
                            newListItem.push(item);
                        }
                    }
                } else if (listItem[i]["_virtual"] == undefined) {
                    newListItem.push(listItem[i]);
                }
            }
            listItem = newListItem;
        }
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
        this.save(listItem);
    }

    this.remove = function () {
        var listItem = bridge.state["main"]["listItem"];
        bridge.arrayRemove(listItem, bridge.args["removeIndex"] * 1);
        bridge.call("SetStateData", {
            "map": {
                "listItem": listItem
            }
        });
        this.save(listItem);
    };
}

bridge.addRouter(new ListItemRouter());