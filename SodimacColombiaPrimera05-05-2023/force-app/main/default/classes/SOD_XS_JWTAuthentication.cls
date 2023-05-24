/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/01/2020
Description  : Factory Class for data authentication.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			28/01/2020		    Created Class
********************************************************************************/

public inherited sharing class SOD_XS_JWTAuthentication {	

    public String alg {get;set;}
    public String iss {get;set;}
    public String sub {get;set;}
    public String aud {get;set;}
    public String exp {get;set;}
    public String iat {get;set;}
    public Map<String,String> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
    public String privateKey {get;set;}

    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';
    private static final String PVR_STR_DASH = '-';

    /**
    *  @Description: Constructor to initialize the Authentication JWT
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        28/01/2020
    */
    public SOD_XS_JWTAuthentication(String alg) {
        this.alg = alg;
        this.validFor = Integer.valueOf(Label.SOD_XS_TiempoDuracion_JWT);
    }

    /**
    *  @Description: Issue, issues an access token(JWT) signed using HMAC SHA256 encryption
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        28/01/2020
    */
    public String issue() {

        String jwt = '';

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));

        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));

        if ( this.alg == HS256 ) {
            Blob key = Blob.valueOf(privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);
        } else if ( this.alg == RS256 ) {
            Blob signature = null;

            if (cert != null ) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
            }
            jwt += '.' + base64URLencode(signature);
        } else if ( this.alg == NONE ) {
            jwt += '.';
        }

        return jwt;

    }

    /**
    *  @Description: Base 64 URL encode, Converts a Blob to an unencoded String representing its normal form.
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        28/01/2020
    */
    public String base64URLencode(Blob input){
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    /**
    *  @Description: Get GUID, generates a transaction identifier when invoking a service
    *  @Autor:       Abd�n Tejos, atejoso@deloitte.com
    *  @Date:        28/08/2020
    */
    public static String getGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ PVR_STR_DASH + h.SubString(8,12) + PVR_STR_DASH + h.SubString(12,16) + PVR_STR_DASH + h.SubString(16,20) + PVR_STR_DASH + h.substring(20);
        return guid;
    }

    /**
    *  @Description: Get HostName, the remote host name which is invoking the service
    *  @Autor:       Abd�n Tejos, atejoso@deloitte.com
    *  @Date:        25/08/2020
    */
    public static String getHost() {
        return URL.getSalesforceBaseUrl().getHost();
    }
    
}