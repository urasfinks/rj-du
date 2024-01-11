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
        this.selectAndClose(defaultListItem[bridge.args["selectedIndex"]]);
    }

    this.onCreateNew = function(){
        this.selectAndClose({
            label: bridge.state["SelectSheetDataState"]["SelectSheetDataKey"].toLowerCase()
        });
    }

    this.selectAndClose = function(selectedObj){
        bridge.call("Hide", {"case": "keyboard"});
        bridge.call("NavigatorPop", {});
    }
}
var selectSheetDataRouter = new SelectSheetDataRouter();
bridge.runRouter(selectSheetDataRouter);
