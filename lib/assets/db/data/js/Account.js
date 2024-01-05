if (bridge.args["switch"] == "onActive") {
    constructor();
}

if (bridge.args["switch"] == "constructor") {
    constructor();
}

function constructor() {
    if (bridge.getStorage("isAuth", "false") === "true") {
        bridge.call("DbQuery", {
            "multiple": [
                {
                    "sql": "SELECT count(*) as count FROM data" +
                        " UNION ALL SELECT count(*) as count FROM data where type_data IN (?, ?)" +
                        " UNION ALL SELECT count(*) as count FROM data where type_data IN(?, ?) and revision_data = 0",
                    "args": ["userDataRSync", "blobRSync", "userDataRSync", "blobRSync"]
                },
                {
                    "sql": "SELECT * FROM data where type_data = ? and uuid_data = ?",
                    "args": ["userDataRSync", "account"]
                }
            ],
            "onFetch": {
                "jsInvoke": "Account.js",
                "args": {
                    "includeAll": true,
                    "switch": "onFetchAccountData"
                }
            }
        });
    } else {
        // Если попали на профиль, но авторизации нет - уводим на signIn
        bridge.call("SetStateData", {
            "map": {
                "SwitchKey": "signIn"
            }
        });
    }
}

if (bridge.args["switch"] == "onFetchAccountData") {
    var accountStatistic = bridge.args["fetchDb"][0];
    var account = bridge.args["fetchDb"][1];

    if (account.length == 0) {
        bridge.state["main"]["account"] = {name: ""};
    } else {
        bridge.state["main"]["account"] = account[0]["value_data"];
    }
    bridge.call("SetStorage", {
        "map": {
            "accountName": bridge.state["main"]["account"]["name"]
        }
    });
    var newState = {
        "map": {
            "SwitchKey": bridge.getStorage("isAuth", "false") === "true" ? "profile" : "signIn",
            "account": bridge.state["main"]["account"],
            "countAllData": accountStatistic[0]["count"],
            "countPersonData": accountStatistic[1]["count"],
            "countNotSyncData": accountStatistic[2]["count"]
        }
    };
    bridge.call("SetStateData", newState);
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

if (bridge.args["switch"] == "setNewName") {
    if (bridge.state["main"]["account"] == null || bridge.state["main"]["account"] == undefined) {
        bridge.state["main"]["account"] = {"name": ""};
    }
    bridge.state["main"]["account"]["name"] = bridge.state["inputSpaceState"]["name"];
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
        "notify": false,
        "onPersist": {
            "jsInvoke": "Account.js",
            "args": {
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