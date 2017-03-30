var tessel = require( "tessel" )
    , request = require( "request" )
    , Keypad = require( "tessel-async-matrix-keypad" )
    , keypadPins = tessel.port.A.pin;
 
    var keypad = new Keypad({
        keys: [
            ["1", "2", "3", "A"],
            ["4", "5", "6", "B"],
            ["7", "8", "9", "C"],
            ["*", "0", "#", "D"]
        ]
        , rows: [keypadPins[0], keypadPins[1], keypadPins[2], keypadPins[3]]
        , cols: [keypadPins[4], keypadPins[5], keypadPins[6], keypadPins[7]]
        , scan: "row"
        , poll: 200 
    });
 
var empId = "";

keypad.on( "keyup", function( key ){
    console.log( "Key Pressed..." );

    empId = empId + key;

    if( key === "*" || key === "#" ){ 
        request(
            "https://shruti-jdf17-developer-edition.ap5.force.com/services/apexrest/employee/authenticate?keys=" + empId,
            function( error, response, body ) {
                var response = JSON.parse( body );
                if( response.status ) {
                    tessel.led[2].on();

                    setTimeout(
                        function() {
                            tessel.led[2].off();
                        }, 
                        3000 
                    );
                    
                    console.log( response.message );
                }
            }
        );
        empId = "";
    }
});