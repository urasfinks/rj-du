function ListItemRouter() {

    this.constructor = function () {
        bridge.call("SetStateData", {
            "notify": false,
            "map": {
                "openEditItem": false
            }
        });
        if (bridge.pageArgs.data.uuid != undefined) {
            bridge.call("DbQuery", {
                "sql": "select * from data where uuid_data = ?",
                "args": [bridge.pageArgs.data.uuid],
                "onFetch": {
                    "jsRouter": "ListItem.ai.js",
                    "args": {
                        "method": route(this, this.onSelect)
                    }
                }
            });
        } else {
            //Если данные для отображения идут в аргументах страницы, они статичны - их не надо переустанавливать
            if (bridge.state["main"]["title"] === undefined) {
                this.setData(bridge.pageArgs.data);
            }
        }
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
            this.setData({
                "title": data.label,
                "theme": data.theme,
                "listItem": listItem
            });
        }
    };

    this.setData = function (obj) {
        if (obj.listItem != undefined) {
            this.updateItem(obj.listItem, obj.theme || bridge.state["main"]["theme"]);
        }
        bridge.call("SetStateData", {
            "map": obj
        });
    };

    this.updateItem = function (list, theme) {
        for (var i = 0; i < list.length; i++) {
            var clone = JSON.parse(JSON.stringify(list[i]));
            delete clone["_virtual"];
            delete clone["onTap"];
            list[i]["onTap"] = {
                "sysInvoke": "NavigatorPush",
                "args": this.getNavigatorPushArgs(JSON.parse(JSON.stringify(list[i])), i, theme, false)
            };
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
        var listItem = JSON.parse(JSON.stringify(listItem));
        for (var i = 0; i < listItem.length; i++) {
            delete listItem[i]["onTap"];
            delete listItem[i]["_virtual"];
        }
        if (bridge.pageArgs.data.uuid != undefined) {
            bridge.call("DataSourceSet", {
                //"debugTransaction": true,
                "uuid": bridge.pageArgs.data.uuid,
                "type": bridge.pageArgs.data.type,
                "updateIfExist": true,
                "onUpdateOverlayJsonValue": true,
                "value": {
                    "list": listItem
                }
            });
        } else if (bridge.pageArgs.onSave != undefined) {
            var onSave = JSON.parse(JSON.stringify(bridge.pageArgs.onSave));
            if (onSave.args == undefined) {
                onSave.args = {};
            }
            onSave.args["list"] = listItem;
            bridge.call("Util", {
                "case": "dynamicInvoke",
                "invokeArgs": onSave
            });
        }
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
        this.setData({
            "listItem": listItem
        });
        this.save(listItem);
        bridge.call("NavigatorPush", this.getNavigatorPushArgs(newItem, 0, bridge.state["main"]["theme"], true));
    };

    this.getNavigatorPushArgs = function (selected, indexItem, theme, clearDataOnFocus) {
        return {
            "type": "bottomSheet",
            "selected": selected,
            "clearDataOnFocus": clearDataOnFocus,
            "parentPageUuid": bridge.pageUuid,
            "indexItem": indexItem,
            "placeholder": bridge.pageArgs.data["placeholder"] || "",
            "heightDynamic": true,
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
                if (i === bridge.args["indexItem"] * 1) {
                    var counter = 0;
                    for (var j = 0; j < any.length; j++) {
                        if (any[j].trim() != "") {
                            var item = JSON.parse(JSON.stringify(listItem[i]));
                            item[bridge.args["fieldKey"]] = any[j].trim();
                            if (j > 0) {
                                item["_virtual"] = true;
                            }
                            newListItem.push(item);
                            counter++;
                        }
                    }
                    if (counter === 0) {
                        newListItem.push(listItem[i]);
                    }
                } else if (listItem[i]["_virtual"] === undefined) {
                    newListItem.push(listItem[i]);
                }
            }
            listItem = newListItem;
        }
        this.setData({
            "listItem": listItem
        });
        this.save(listItem);
    }

    this.remove = function () {
        var listItem = bridge.state["main"]["listItem"];
        bridge.arrayRemove(listItem, bridge.args["removeIndex"] * 1);
        this.setData({
            "listItem": listItem
        });
        this.save(listItem);
    };
}

bridge.addRouter(new ListItemRouter());