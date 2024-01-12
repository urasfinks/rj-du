function SelectSheetDataRouter(){
    this.constructor = function(){
        bridge.call("SetStateData", {
            "map": {
                "defaultListItem": bridge.args["listItem"],
                "listItem": bridge.args["listItem"]
            }
        });
    }

    this.find = function(){
        var findText = bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].toLowerCase();
        var newListItem = [];
        var defaultListItem = bridge.state["main"]["defaultListItem"];
        for(var i=0;i<defaultListItem.length;i++){
            if(
                defaultListItem[i]["label"] != undefined
                && defaultListItem[i]["label"].toLowerCase().includes(findText)
            ){
                newListItem.push(defaultListItem[i]);
            }
        }
        bridge.call("SetStateData", {
            "map": {
                "listItem": newListItem
            }
        });
    }

    this.onSubmit = function(){
        bridge.call("Hide", {"case": "keyboard"});
    }

    this.onSelect = function(){
        var defaultListItem = bridge.state["main"]["defaultListItem"];
        bridge.log(bridge.args["selectedIndex"]);
        this.pop(defaultListItem[bridge.args["selectedIndex"]*1]);
    }

    this.onCreateNew = function(){
        this.pop({
            isNew: true,
            label: bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].toLowerCase()
        });
    }

    this.pop = function(selectedObj){
        bridge.call("Hide", {"case": "keyboard"});
        bridge.call("NavigatorPop", {
            "selectedObj": selectedObj
        });
    }
}
var selectSheetDataRouter = new SelectSheetDataRouter();
bridge.runRouter(selectSheetDataRouter);
