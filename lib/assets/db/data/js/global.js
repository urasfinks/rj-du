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
    debug;
    global = {};
    routerMap = {};

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

    setContext(objContext) {
        for (var key in objContext) {
            this[key] = objContext[key];
        }
    }

    addRouter(router) {
        this.routerMap[this.scriptUuid] = router;
    }

    runRouter(name) {
        if (this.routerMap[name][this.args["method"]] != undefined) {
            this.routerMap[name][this.args["method"]].apply(this.routerMap[name]);
        } else {
            this.log("Undefined router handler: " + JSON.stringify(this.args));
        }
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
            this.log("Exception Bridge.call(" + invoke + ", " + JSON.stringify(args) + "): " + e.toString() + " => " + result);
        }
        return result;
    }

    alert(data) {
        this.call("Alert", {
            "duration": 3000,
            "label": data
        });
    }

    util(caseString, args) {
        return this.call("Util", this.overlay({
            "case": caseString
        }, args || {}))[caseString];
    }

    arrayUnique(ar) {
        return ar.filter(function (value, index, array) {
            return array.indexOf(value) === index;
        });
    }

    log(data) {
        if (this.debug) {
            console.log("JS>> [" + new Date().toISOString() + "] scriptUuid: " + this.scriptUuid + "; method: " + this.args["method"] + "; data: " + JSON.stringify(data));
        }
    }

    overlay(refObject, newValue) {
        for (var key in newValue) {
            refObject[key] = newValue[key];
        }
        return refObject;
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
        this.call("Http", args);
    }

    getStorage(key, def) {
        var resultFetStorage = this.call("GetStorage", {
            "key": key,
            "default": def
        });
        if (resultFetStorage[key] == undefined) {
            this.log("getStorage() => " + JSON.stringify(resultFetStorage));
        }
        return resultFetStorage[key];
    }

    selector(obj, ar, def) {
        var curObj = obj;
        for (var i = 0; i < ar.length; i++) {
            if (curObj[ar[i]] != undefined) {
                curObj = curObj[ar[i]];
            } else {
                return def;
            }
        }
        return curObj;
    }

    random(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min) + min);
    }

    checkHttpResponse(extraErrorMap) {
        if (this.args["httpResponse"] == undefined) {
            this.alert("Нет ответа от сервера");
            return false;
        }
        if (this.args["httpResponse"]["status"] == false) {
            this.alert(this.mapError(this.args["httpResponse"]["error"], extraErrorMap || []));
            return false;
        }
        return true;
    }

    mapError(error, extraErrorMap) {
        var map = [
            {
                error: "$.mail: is missing but it is required",
                display: "E-mail не может быть пустым"
            },
            {
                error: "$.mail: does not match",
                display: "E-mail введён не корректно"
            },
            {
                error: "RangeError (end): Invalid value:",
                display: "Неизвестная ошибка от сервера"
            },
            {
                error: "Request timeout",
                display: "Сервер не ответил за отведённое время"
            },
            {
                error: "Connection failed",
                display: "Не удалось соединится с сервером"
            },
            {
                error: "Sending the email to the following server failed",
                display: "Не удалось отправить письмо"
            }
        ].concat(extraErrorMap);

        for (var i = 0; i < map.length; i++) {
            if (error == map[i]["error"] || error.startsWith(map[i]["error"])) {
                return map[i]["display"];
            }
        }
        return error;
    }

    shuffle(array) {
        let currentIndex = array.length, randomIndex;
        while (currentIndex != 0) {
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;
            [array[currentIndex], array[randomIndex]] = [
                array[randomIndex], array[currentIndex]];
        }
        return array;
    }

    asyncImport(uuid, args) {
        this.call("Util", {
            "case": "dynamicInvoke",
            "invokeArgs": {
                "jsInvoke": uuid,
                "args": args
            }
        });
    }

    asyncImportList(uuidList) {
        for (var i = 0; i < uuidList.length; i++) {
            this.asyncImport(uuidList[i], {});
        }
    }

    socketExtend(action, socketUuid) {
        this.call("Http", {
            "uri": "/SocketExtend",
            "method": "POST",
            "body": {
                "uuid_data": socketUuid,
                "actions": [
                    action
                ]
            }
        });
    }

    arrayRemoveByValue(arr, value) {
        const index = arr.indexOf(value);
        if (index > -1) {
            arr.splice(index, 1);
        }
    }

    arrayRemove(arr, index) {
        arr.splice(index, 1);
    }
}

function route(obj, fn) {
    for (var key in obj) {
        if (obj[key] == fn) {
            return key;
        }
    }
    return undefined;
}

var bridge = new Bridge();