RESTful Email Processor
C# WebAPI contains a single POST method that consumes an unstrucured text message containing plain text with XML islands and Markup.

The project can be executed standalone in Microsoft Visual Studio - latest version backward compatible -2

Example text message:
```json
{
	"message":"Hi Tim,Please create an expense claim for the below. Relevant details are marked up as requested. <expense><cost_centre>DEV002</cost_centre><total>1024.01</total><payment_method>personal card</payment_method></expense>From: Sam Temple Sent: Friday, 16 February 2018 10:32 AM To: John Black <john.black@example.com>Subject: Claim Hi John, Please create a reservation at the <vendor>Spur Steakranch</vendor> our <description>development team’s project end celebration dinner</description> on <date>Tuesday 27 April 2017</date>.We expect to arrive around 7.15pm. Approximately 12 people but I’ll confirm exact numbers closer to the day. Regards, Sam"
}
```
Processed XML structure:

```xml
<root>  
  <expense>  
    <cost_centre>DEV002</cost_centre>  
    <total>1024.01</total>  
    <payment_method>personal card</payment_method>  
  </expense>  
  <vendor>Viaduct Steakhouse</vendor>  
  <description>development team’s project end celebration dinner</description>  
  <date>Tuesday 27 April 2017</date>  
</root>  
```
Processes message, extracts the XML and calculates data based on incoming message.

Response:
```json
{  
    "response": {  
        "vendor": "Spur Steakhouse",  
        "description": "development team’s project end celebration dinner",  
        "eventDate": "Tuesday 27 April 2017",  
        "paymentMethod": "personal card",  
        "costCenter": "DEV002",  
        "total": "1024.01",  
        "totalExcludingTax": "880.65",  
        "tax": "143.36"  
    }  
}  
```
Required field: TOTAL  
Calculated fields:  
TotalExcludingTax  
Tax - this is based on 14%







