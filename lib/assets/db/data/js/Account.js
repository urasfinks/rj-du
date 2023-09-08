if (bridge.args["switch"] == "onActive") {
    bridge.log("onActive");
    constructor();
}

if (bridge.args["switch"] == "constructor") {
    constructor();
}

function constructor() {
    let isAuth = bridge.getStorage("isAuth", "false");

    bridge.log("Hello constructor: isAuth: " + isAuth);

    bridge.call('SetStateData', {
        "map": {
            "SwitchKey": isAuth == "true" ? "profile" : "signIn"
        }
    });

    bridge.call('DbQuery', {
        "sql": "SELECT count(*) as count FROM data" +
            " UNION ALL SELECT count(*) as count FROM data where type_data IN (?, ?)" +
            " UNION ALL SELECT count(*) as count FROM data where type_data IN(?, ?) and revision_data = 0",
        "args": ["userDataRSync", "blobRSync", "userDataRSync", "blobRSync"],
        "onFetch": {
            "jsInvoke": "Account.js",
            "args": {
                "switch": "onFetchCountAllData"
            }
        }
    });

    if (isAuth) {
        bridge.call('DbQuery', {
            "sql": "SELECT * FROM data where type_data = ? and uuid_data = ?",
            "args": ["userDataRSync", "account"],
            "onFetch": {
                "jsInvoke": "Account.js",
                "args": {
                    "includeAll": true,
                    "switch": "onFetchAccount"
                }
            }
        });
    }
}

if (bridge.args["switch"] == "onFetchCountAllData") {
    bridge.call('SetStateData', {
        "map": {
            "countAllData": bridge.args["fetchDb"][0]["count"],
            "countPersonData": bridge.args["fetchDb"][1]["count"],
            "countNotSyncData": bridge.args["fetchDb"][2]["count"]
        }
    });
}

if (bridge.args["switch"] == "GetCode") {
    bridge.call("Hide", {"case": "keyboard"});
    bridge.call("Show", {"case": "customLoader"});
    bridge.call('Http', {
        "uri": "/GetCode",
        "body": {
            "mail": bridge.state["main"]["EmailValue"]
        },
        "onResponse": {
            "jsInvoke": "Account.js",
            "args": {
                "includeStateData": true,
                "switch": "GetCodeResponse"
            }
        }
    });
}

function checkHttpResponse() {
    if (bridge.args["httpResponse"]["status"] == false) {
        bridge.alert(mapError(bridge.args["httpResponse"]["error"]));
        return false;
    }
    return true;
}

function mapError(error) {
    bridge.log(error);
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
            error: "Sending the email to the following server failed",
            display: "Не удалось отправить письмо"
        }
    ];
    for (var i = 0; i < map.length; i++) {
        if (error == map[i]["error"] || error.startsWith(map[i]["error"])) {
            return map[i]["display"]
        }
    }
    return error;
}

if (bridge.args["switch"] == "GetCodeResponse") {
    bridge.call("Hide", {"case": "customLoader"});
    //bridge.log(bridge.args);
    if (checkHttpResponse()) {
        bridge.call("NavigatorPush", {
            "type": "BottomSheet",
            "mail": bridge.state["main"]["EmailValue"],
            "link": {
                "template": "AccountCode.json",
            }
        });
    }
}

if (bridge.args["switch"] == "RequestConfirmCode") {
    //bridge.log(bridge.state["main"]);
    bridge.call('Http', {
        "uri": "/SignIn",
        "body": {
            "code": bridge.state["main"]["CodeValue"] * 1,
            "mail": bridge.pageArgs["mail"]
        },
        "onResponse": {
            "jsInvoke": "Account.js",
            "args": {
                "includePageArgument": true,
                "switch": "onConfirmCodeResponse"
            }
        }
    });
}

if (bridge.args["switch"] == "onConfirmCodeResponse") {
    //bridge.log(bridge.args);
    if (checkHttpResponse()) {
        bridge.call('SetStorage', {
            "map": {
                "mail": bridge.pageArgs["mail"],
                "lastMail": bridge.pageArgs["mail"],
                "isAuth": "true"
            }
        });
        bridge.call("Show", {"case": "customLoader"});
        bridge.call("DataSync", {
            "onSync": {
                "jsInvoke": "Account.js",
                "args": {
                    "includeAll": true,
                    "switch": "onDataSync"
                }
            }
        });
    }
}
if (bridge.args["switch"] == "onDataSync") {
    bridge.call("Hide", {"case": "customLoader"});
    bridge.call("NavigatorPop", {
        "reloadParent": true
    });
}

if (bridge.args["switch"] == "Logout") {
    bridge.log("Logout");
    bridge.call('SetStorage', {
        "map": {
            "mail": "",
            "isAuth": "false"
        }
    });
    bridge.call('PageReload', {
        "case": "current"
    });
}

if (bridge.args["switch"] == "onFetchAccount") {
    bridge.log(bridge.args);
    if (bridge.args["fetchDb"].length == 0) {
        bridge.call('DataSourceSet', {
            "uuid": "account",
            "value": JSON.stringify({}),
            "parent": null,
            "type": "userDataRSync",
            "key": "account"
        });
        bridge.state["main"]["accountValue"] = {
            name: ""
        };
    } else {
        bridge.state["main"]["accountValue"] = bridge.args["fetchDb"][0]["value_data"];
    }
    bridge.log(bridge.args["fetchDb"]);
    bridge.call('SetStateData', {
        "map": {
            "accountValue": bridge.state["main"]["accountValue"]
        }
    });
}

if (bridge.args["switch"] == "setNewName") {
    if (bridge.state["main"]["accountValue"] == null || bridge.state["main"]["accountValue"] == undefined) {
        bridge.state["main"]["accountValue"] = {};
    }
    bridge.state["main"]["accountValue"]["name"] = bridge.state["main"]["name"];
    bridge.log(bridge.state["main"]["accountValue"]);
    bridge.call('DataSourceSet', {
        "uuid": "account",
        "value": bridge.state["main"]["accountValue"],
        "parent": null,
        "type": "userDataRSync",
        "key": "account",
        "debugTransaction": true
    });
}

if (bridge.args["switch"] == "showGallery") {
    bridge.call("Show", {
        "case": "gallery",
        "onLoadImage": {
            "jsInvoke": "Account.js",
            "args": {
                "includeAll": true,
                "switch": "onLoadImage"
            }
        }
    });
}

if (bridge.args["switch"] == "onLoadImage") {
    bridge.call('DataSourceSet', {
        "uuid": "avatar",
        "value": bridge.args["ImageData"],
        "parent": null,
        "type": "blobRSync",
        "key": "avatar",
        "debugTransaction": true
    });
}