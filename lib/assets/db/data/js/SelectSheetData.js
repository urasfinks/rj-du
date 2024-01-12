function SelectSheetDataRouter() {
    this.constructor = function () {
        bridge.call("SetStateData", {
            "map": {
                "defaultListItem": bridge.args["listItem"],
                "listItem": bridge.args["listItem"]
            }
        });
    }

    this.find = function () {
        var findText = bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].toLowerCase();
        var newListItem = [];
        var defaultListItem = bridge.state["main"]["defaultListItem"];
        if (findText == undefined || findText.trim() === "") {
            newListItem = defaultListItem;
        } else {
            for (var i = 0; i < defaultListItem.length; i++) {
                if (
                    defaultListItem[i]["label"] != undefined
                    && defaultListItem[i]["label"].toLowerCase().includes(findText)
                ) {
                    newListItem.push(defaultListItem[i]);
                }
            }
        }
        bridge.call("SetStateData", {
            "map": {
                "listItem": newListItem
            }
        });
    }

    this.onSubmit = function () {
        bridge.call("Hide", {"case": "keyboard"});
    }

    this.onSelect = function () {
        var defaultListItem = bridge.state["main"]["defaultListItem"];
        this.pop(defaultListItem[bridge.args["selectedIndex"] * 1]);
    }

    this.onCreateNew = function () {
        this.pop({
            isNew: true,
            label: bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].toLowerCase()
        });
    }

    this.pop = function (selectedObj) {
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
}

var selectSheetDataRouter = new SelectSheetDataRouter();
bridge.runRouter(selectSheetDataRouter);
