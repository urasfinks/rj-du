function SelectSheetDataRouter() {
    this.constructor = function () {
        bridge.call("SetStateData", {
            "map": {
                "defaultListItem": bridge.args["listItem"],
                "listItem": bridge.args["listItem"]
            }
        });
    }

    this.getListByFind = function () {
        var findText = bridge.selector(bridge.state, ["SelectSheetDataState", "SelectSheetDataKey"], "").toLowerCase();
        var newListItem = [];
        var defaultListItem = bridge.state["main"]["defaultListItem"];
        if (findText == undefined || findText.trim() === "") {
            newListItem = defaultListItem;
        } else {
            if (defaultListItem != undefined) {
                for (var i = 0; i < defaultListItem.length; i++) {
                    if (
                        defaultListItem[i]["label"] != undefined
                        && defaultListItem[i]["label"].toLowerCase().includes(findText)
                    ) {
                        newListItem.push(defaultListItem[i]);
                    }
                }
            }
        }
        return newListItem;
    }

    this.find = function () {
        bridge.call("SetStateData", {
            "map": {
                "listItem": this.getListByFind()
            }
        });
    }

    this.onSubmit = function () {
        bridge.call("Hide", {"case": "keyboard"});
    }

    this.onSelect = function () {
        var defaultListItem = this.getListByFind();
        this.pop(defaultListItem[bridge.args["selectedIndex"] * 1]);
    }

    this.onCreateNew = function () {
        if (
            bridge.state["SelectSheetDataState"] == undefined
            || bridge.state["SelectSheetDataState"]["SelectSheetDataKey"] == undefined
            || bridge.state["SelectSheetDataState"]["SelectSheetDataKey"] == ""
            || bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].trim() == ""
        ) {
            bridge.alert("Наименование не может быть пустым");
        } else {
            this.pop({
                isNew: true,
                label: bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].trim()
            });
        }
    }

    this.pop = function (selectedObj) {
        /*
        //select_sheet.dart
        "onPop": {
            "jsRouter": "SelectSheetData.ai.js",
            "args": {"method": "onFinish", "state": state, "stateKey": stateKey}
          }
        */
        if (bridge.pageArgs["onPop"] != undefined) {
            bridge.call("Hide", {"case": "keyboard"});
            if (bridge.pageArgs["onPop"]["args"] == undefined) {
                bridge.pageArgs["onPop"]["args"] = {};
            }
            bridge.pageArgs["onPop"]["args"]["selected"] = selectedObj;
            bridge.call("NavigatorPop", {
                "onPop": bridge.pageArgs["onPop"]
            });
        }
    }

    this.onFinish = function () {
        //{"includeAll":true,"method":"onFinish","state":"main","stateKey":"groupPerson","selected":{"label":"Группа 2"}}
        if (
            bridge.args["selected"]["isNew"] != undefined
            && bridge.args["selected"]["isNew"] === true
            && bridge.args["onNew"] != undefined
            && bridge.args["onNew"] != null
        ) {
            if (bridge.args["onNew"]["args"] == undefined) {
                bridge.args["onNew"]["args"] = {};
            }

            bridge.args["onNew"]["args"]["state"] = bridge.args["state"];
            bridge.args["onNew"]["args"]["stateKey"] = bridge.args["stateKey"];
            bridge.args["onNew"]["args"]["selected"] = bridge.args["selected"];

            bridge.util("dynamicInvoke", {
                "invokeArgs": bridge.args["onNew"]
            });
        } else {
            bridge.call("SetStateData", {
                "state": bridge.args["state"],
                "key": bridge.args["stateKey"],
                "value": bridge.args["selected"]
            });
        }
    }
}

var selectSheetDataRouter = new SelectSheetDataRouter();
bridge.addRouter(selectSheetDataRouter);
