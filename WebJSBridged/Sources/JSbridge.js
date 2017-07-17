





/*************************************************** Frist the use of way Scenario ***************************************************/
var wbjs;
!(function(){

    var responseCallbacks = {};
    var uniqueId = 1;
  
    wbjs = {
        sendMessage : function (params, responseCallback) {
            var callbackId = wbjs.generate_callbackId()
            responseCallbacks[callbackId] = responseCallback
            params["callbackId"] = callbackId
            var jsonStr = JSON.stringify(params)
            WebJSBridgedContext.dispatchMessage(jsonStr)
        },
  
        respondMessage : function (params) {
            var callbackFunc = responseCallbacks[params.callbackId]
            callbackFunc()
            delete responseCallbacks[params.callbackId]
        },
  
        generate_callbackId : function () {
            return ('cb_' + (uniqueId++) + '_' + new Date().getTime())
        },
    };

})();





/*************************************************** Second the use of way Scenario ***************************************************/
var WebJSCallbackHandlers;
$(document).ready(function() {
            
                
WebJSCallbackHandlers = {
    chooseImageRespond : function (params) {
          $("#images").attr("src", params)
    },
                  
    getWiFiInfoRespond : function (params) {
          var str = "SSID: " + params.ssid + " \r\n BSSID: " + params.bssid + "\r\n SSIDDATA: " + params.ssiddata
          alert(str)
    },
                  
    takePhotoRespond : function (params) {
          $("#images").attr("src", params)
    }
};
   
                  
                   
$("#authenticate_check").bind("click", function(){
                                var appKey = $("#app_key_login").val()
                                var appSecret = $("#secret_login").val()
                                window.wbjs.sendMessage({ "api_name" : "login", "appKey": appKey, "appSecret": appSecret }, function(res){
                                                            alert("Hello I am a method of JavaScript CallBack")
                                                        })
                              });
                   
$("#modify_title").bind("click", function(){
                             var modify_title_input = $("#modify_title_input").val()
                             WebJSBridgedContext.webJSModifyTitle(modify_title_input);
                             
                             });

$("#chooseImage").bind("click", function(){
                       WebJSBridgedContext.webJSChooseImage();
                      });
                 
$("#previewImage").bind("click", function(){
                        var h = $(document).height()-$(window).height();
                        $(document).scrollTop(h);
                     });
                  

$("#takePhoto").bind("click", function(){
                      WebJSBridgedContextInstance.webJSTakePhoto();
                      });

$("#GetWiFiInfo").bind("click", function(){
                      WebJSBridgedContextInstance.webJSGetWiFiInfo();
                      });
                  
});





