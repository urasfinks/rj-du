function AccountRouter() {
    this.onActive = function () {
        constructor();
    };

    this.constructor = function () {
        constructor();
    };

    this.onFetchAccountData = function () {
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
    };

    this.GetCode = function () {
        bridge.call("Hide", {"case": "keyboard"});
        bridge.call("Show", {"case": "customLoader"});
        bridge.call("Http", {
            "uri": "/GetCode",
            "body": {
                "mail": bridge.state["main"]["EmailValue"]
            },
            "onResponse": {
                "jsRouter": "Account.ai.js",
                "args": {
                    "includeStateData": true,
                    "method": "GetCodeResponse"
                }
            }
        });
    };

    this.GetCodeResponse = function () {
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

    this.RequestConfirmCode = function () {
        //bridge.log(bridge.state["main"]);
        bridge.call("Http", {
            "uri": "/SignIn",
            "body": {
                "code": bridge.state["main"]["CodeValue"] * 1,
                "mail": bridge.pageArgs["mail"]
            },
            "onResponse": {
                "jsRouter": "Account.ai.js",
                "args": {
                    "includePageArgument": true,
                    "method": "onConfirmCodeResponse"
                }
            }
        });
    };

    this.onConfirmCodeResponse = function () {
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
                    "jsRouter": "Account.ai.js",
                    "args": {
                        "includeAll": true,
                        "method": "onDataSync"
                    }
                }
            });
        }
    };

    this.onDataSync = function () {
        bridge.call("Hide", {"case": "customLoader"});
        bridge.call("NavigatorPop", {});
        bridge.call("PageReload", {
            "case": "all"
        });
    };

    this.RemoveLogout = function () {
        bridge.log("RemoveLogout");
        bridge.util("logoutWithRemove", {});
        //Так как удаления асинхронная перезагрузку страницы уведём в api logoutWithRemove
    };

    this.Logout = function () {
        bridge.log("Logout");
        bridge.util("logout", {});
        // так как мы были авторизованы, скорее всего наши данные синхронизованны
        // Так синхронизация не гарантированна, будем оставлять данные у которых ревизия больше 0
        // 0 получается останется на устройстве и в конечном итоге будет примазано к новой авторизации
        bridge.call("PageReload", {
            "case": "all"
        });
    };

    this.setNewName = function () {
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
                "jsRouter": "Account.ai.js",
                "args": {
                    "method": "reSync"
                }
            }
        });
    };

    this.reSync = function () {
        bridge.util("dataSync", {});
    };

    this.showGallery = function () {
        bridge.call("Show", {
            "case": "gallery",
            "onLoadImage": {
                "jsRouter": "Account.ai.js",
                "args": {
                    "includeAll": true,
                    "method": "onLoadImage"
                }
            }
        });
    };

    this.onLoadImage = function () {
        bridge.call("DataSourceSet", {
            "uuid": "avatar",
            "value": bridge.args["ImageData"],
            "parent": null,
            "type": "blobRSync",
            "key": "avatar",
            "debugTransaction": true
        });
    };
}

bridge.addRouter(new AccountRouter());


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
                "jsRouter": "Account.ai.js",
                "args": {
                    "includeAll": true,
                    "method": "onFetchAccountData"
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