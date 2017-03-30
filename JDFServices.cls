@RestResource( urlMapping='/employee/*' )
global class JDFServices {
    global class Response {
        public Boolean status;
        public String message;
        public Integer statusCode;
        
        public Response( Boolean status, String message, Integer statusCode ){
            this.status     = status;
            this.message    = message;
            this.statusCode = statusCode;
        }
    }
    
    @HttpGet
    global static Response authenticate() {
        String keysPressed = RestContext.request.params.get( 'keys' );
        
        if( keysPressed.endsWith( '*' ) ) {
            keysPressed = keysPressed.replace( '*', '' );
            
            Response resp = checkin( keysPressed, DateTime.now() );
            return resp;
        }
        else {
            keysPressed = keysPressed.replace( '#', '' );
            
            Response resp = checkout( keysPressed, DateTime.now() );
            return resp;
        }
    }
    
    private static Response checkin( String empId, DateTime checkinTime ) {
        try {
            List<Employee__c> employee = new List<Employee__c>();
            
            employee = [
                SELECT  Name
                FROM    Employee__c
                WHERE   EmpId__c = :empId
            ];
            
            if( !employee.isEmpty() ) {
                Checkin_History__c newcheckinHist   = new Checkin_History__c();
                
                newcheckinHist.Checkin_Time__c      = checkinTime;
                newcheckinHist.Employee__c          = employee[0].Id;
                
                INSERT newcheckinHist;
                
                return new Response( TRUE, employee[0].Name + ' checked in successfully.', 777 );
            }
            else {
                return new Response( FALSE, 'Invalid Employee Id', 111 );
            }
        }
        catch( Exception ex ) {
            return new Response( FALSE, ex.getMessage(), 555 );
        }
    }
    
    private static Response checkout( String empId, DateTime checkoutTime ) {
        try {
            List<Employee__c> employee = new List<Employee__c>();
            
            employee = [
                SELECT  Name
                FROM    Employee__c
                WHERE   EmpId__c = :empId
            ];
            
            if( !employee.isEmpty() ) {
                Checkin_History__c checkinHist = new Checkin_History__c();
                
                DateTime todaysDateTime = System.today();
                Date todaysDate         = todaysDateTime.date();
                
                checkinHist = [
                    SELECT  Checkout_Time__c
                            ,Checkin_Time__c
                            ,Duration__c
                            ,Employee__c
                    FROM    Checkin_History__c
                    WHERE   Employee__c = :employee[0].Id   AND 
                            Checkout_Time__c = NULL         AND 
                            Checkin_Date__c = :todaysDate
                ];
                
                if( checkinHist != NULL ) {
                    checkinHist.Checkout_Time__c = checkoutTime;
                    
                    UPDATE checkinHist;
                }
                
                return new Response( TRUE, employee[0].Name + ' checked out successfully.', 777 );
            }
            else {
                return new Response( FALSE, 'Invalid Employee Id', 111 );
            }
        }
        catch( Exception ex ) {
            return new Response( FALSE, ex.getMessage(), 555 );
        }
    }
}