if (bridge.args["switch"] == "onActive") {
    constructor();
}

if (bridge.args["switch"] == "constructor") {
    constructor();
}

function constructor() {
    bridge.call("SubscribeReload", {
        "uuid": "account"
    });
    let isAuth = bridge.getStorage("isAuth", "false");

    bridge.log("Hello constructor: isAuth: " + isAuth);

    bridge.call("SetStateData", {
        "map": {
            "SwitchKey": isAuth == "true" ? "profile" : "signIn"
        }
    });

    bridge.call("DbQuery", {
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
        bridge.call("DbQuery", {
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
    bridge.call("SetStateData", {
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
    bridge.call("Http", {
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

if (bridge.args["switch"] == "GetCodeResponse") {
    bridge.call("Hide", {"case": "customLoader"});
    if (bridge.checkHttpResponse([])) {
        bridge.call("NavigatorPush", {
            "type": "bottomSheet",
            "height": 250,
            "mail": bridge.state["main"]["EmailValue"],
            "link": {
                "template": "AccountCode.json",
            }
        });
    }
}

if (bridge.args["switch"] == "RequestConfirmCode") {
    //bridge.log(bridge.state["main"]);
    bridge.call("Http", {
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
    if (bridge.checkHttpResponse([])) {
        bridge.call("SetStorage", {
            "map": {
                "mail": bridge.pageArgs["mail"],
                "lastMail": bridge.pageArgs["mail"],
                "isAuth": "true",
                "authJustNow": "true"
            }
        });
        bridge.call("Show", {"case": "customLoader"});
        bridge.call("Util", {
            "case": "dataSync",
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
    bridge.call("NavigatorPop", {});
    bridge.call("PageReload", {
        "case": "all"
    });
}

if (bridge.args["switch"] == "RemoveLogout") {
    bridge.log("RemoveLogout");
    bridge.util("logoutWithRemove", {});
    //Так как удаления асинхронная перезагрузку страницы уведём в api logoutWithRemove
}

if (bridge.args["switch"] == "Logout") {
    bridge.log("Logout");
    bridge.util("logout", {});
    // так как мы были авторизованы, скорее всего наши данные синхронизованны
    // Так синхронизация не гарантированна, будем оставлять данные у которых ревизия больше 0
    // 0 получается останется на устройстве и в конечном итоге будет примазано к новой авторизации
    bridge.call("PageReload", {
        "case": "all"
    });
}

if (bridge.args["switch"] == "onFetchAccount") {
    if (bridge.args["fetchDb"].length == 0) {
        bridge.state["main"]["account"] = {name: ""};
    } else {
        bridge.state["main"]["account"] = bridge.args["fetchDb"][0]["value_data"];
    }
    bridge.call("SetStateData", {
        "map": {
            "account": bridge.state["main"]["account"]
        }
    });
    bridge.call("SetStorage", {
        "map": {
            "accountName": bridge.state["main"]["account"]["name"]
        }
    });
}

if (bridge.args["switch"] == "setNewName") {
    if (bridge.state["main"]["account"] == null || bridge.state["main"]["account"] == undefined) {
        bridge.state["main"]["account"] = {"name": ""};
    }
    bridge.state["main"]["account"]["name"] = bridge.state["main"]["name"];
    bridge.call("SetStorage", {
        "map": {
            "accountName": bridge.state["main"]["name"]
        }
    });
    bridge.call("DataSourceSet", {
        "uuid": "account",
        "value": bridge.state["main"]["account"],
        "parent": null,
        "type": "userDataRSync",
        "key": "account",
        "debugTransaction": true,
        "onPersist": {
            "jsInvoke": "Account.js",
            "args": {
                "includeAll": true,
                "switch": "reSync"
            }
        }
    });
}

if (bridge.args["switch"] == "reSync") {
    bridge.util("dataSync", {});
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
    bridge.call("DataSourceSet", {
        "uuid": "avatar",
        "value": bridge.args["ImageData"],
        "parent": null,
        "type": "blobRSync",
        "key": "avatar",
        "debugTransaction": true
    });
}