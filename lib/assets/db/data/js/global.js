if (typeof Bridge == 'undefined') {
    class Bridge {
        scriptUuid;
        unique;
        pageUuid;
        args;
        contextMap;
        context;
        state;
        pageArgs;
        orientation;
        pageActive;

        constructor() {
            this.clearAll();
        }

        clearAll() {
            this.pageUuid = undefined;
            this.args = undefined;
            this.contextMap = undefined;
            this.context = undefined;
            this.state = undefined;
            this.pageArgs = undefined;
        }

        call(invoke, args) {
            var result = undefined;
            try {
                args["_rjduPageUuid"] = this.pageUuid; //Зарезервированное системное имя, что бы связать контекст исполнения
                result = sendMessage(invoke, JSON.stringify(args));
                if (result == undefined || result == null) {
                    return;
                }
                return JSON.parse(result);
            } catch (e) {
                bridge.log("Exception Bridge.call(" + invoke + ", " + JSON.stringify(args) + "): " + e.toString() + " => " + result);
            }
            return result;
        }

        alert(data) {
            this.call("Alert", {
                "duration": 2000,
                "label": data
            });
        }

        log(data) {
            console.log("scriptUuid: " + bridge.scriptUuid + " ; switch: " + bridge.args["switch"] + "; data: " + JSON.stringify(data));
        }

        overlay(refObject, newValue) {
            for (var key in newValue) {
                refObject[key] = newValue[key];
            }
        }

        socketInsert(uuid, method, args, onResponse) {
            var args = {
                "uri": "/SocketInsert",
                "method": "POST",
                "body": {
                    "uuid_data": uuid,
                    "actions": [{
                        "action": method,
                        "arguments": args
                    }]
                }
            };
            if (onResponse != undefined) {
                args["onResponse"] = onResponse;
            }
            bridge.call('Http', args);
        }

        getStorage(key, def){
            return bridge.call('GetStorage', {
                "key": key,
                "default": def
            })[key];
        }
    }

    var bridge = new Bridge();
}