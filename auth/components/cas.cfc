/*
 * ColdFusion 9.0+ CAS Client
 *
 * Created by Nic Raboy
 *
 */
component displayname="CAS" author="Nic Raboy" output="false" {

    property string cas_url; // URL for the CAS connection
    property string service_url; // URL for the service requesting authentication with CAS
    property string default_landing_url; // Where to land if a redirection is not specified
    property boolean direct_forwarding; // Allow for redirections, otherwise direct to default landing page
    property string requested_url;
    property string username;

    /*
     * Initialize all important variables of the CAS component.  This init() is the same as a construct()
     *
     * @param    string cas_url
     * @param    string service_url
     * @param    string default_landing_url
     * @param    boolean direct_forwarding
     * @return   cas
     */
    public cas function init(required string cas_url, required string service_url, string default_landing_url="/", boolean direct_forwarding="false") output="false" {
        variables.cas_url = arguments.cas_url;
        variables.service_url = arguments.service_url;
        variables.default_landing_url = arguments.default_landing_url;
        variables.direct_forwarding = arguments.direct_forwarding;
        variables.username = "";
        variables.requested_url = variables.default_landing_url;
        variables.service_ticket = "";
        return this;
    }

    /*
     * Validate the user with CAS.  If the user has not yet signed into the site via CAS, the username will be 
     * blank.  If the username is blank and there is no service ticket in the URL then redirect to CAS sign in.  At 
     * the end of CAS sign in redirect to the service URL which should call validate again, but this time a service 
     * ticket will be in the URL variable.  Validate the service ticket via the CAS serviceValidate URL and if 
     * successful, return the username and redirect to the originally requested page
     * 
     * @param    string requested_url
     * @return
     */
    public void function validate(string requested_url) output="false" {

        service_ticket = "";

        if(structKeyExists(url, "ticket")) {
            service_ticket = url.ticket;
        }

        if(variables.username == "") {
            if(service_ticket == "") {
                variables.requested_url = iif(variables.direct_forwarding, de(arguments.requested_url), de(variables.default_landing_url));
                login();
            } else {
                validateTicket(service_ticket);
                if(variables.username == "") {
                    login();
                }
                location(variables.requested_url, false);
            }
        }
    }

    /*
     * Send the service ticket and service url in exchange for a success response that includes the 
     * username of the authorized user
     *
     * @param    string service_ticket
     * @return
     */
    private void function validateTicket(required string service_ticket) output="false" {
        httpRequest = new http();
        httpRequest.setUrl(variables.cas_url & "serviceValidate");
        httpRequest.setMethod("GET");
        httpRequest.addParam(type="formfield", name="ticket", value="#arguments.service_ticket#");
        httpRequest.addParam(type="formfield", name="service", value="#variables.service_url#");
        httpResult = httpRequest.send().getPrefix();

        if(isXml(httpResult.fileContent)) {
            cas_user_node = XmlSearch(XmlParse(httpResult.fileContent), "cas:serviceResponse/cas:authenticationSuccess/cas:user");
            if(ArrayLen(cas_user_node)) {
                variables.username = cas_user_node[1].XmlText;
            }
        }
    }

    /*
     * Redirect to CAS login for service validation
     *
     * @param
     * @return
     */
    private void function login() output="false" {
        location(variables.cas_url & "login?service=" & variables.service_url, false);   
    }

    /*
     * Sign out of CAS, wipe the username, and redirect to the specified page
     *
     * @param
     * @return
     */
    public void function logout() output="false" {
        variables.username = "";
        location(variables.cas_url & "logout" & iif(len(variables.default_landing_url), de("?service=" & variables.service_url), de("")), false);
    }  

    /*
     * Get the username returned from CAS
     *
     * @param
     * @return    string
     */
    public string function getUsername() output="false" {
        return variables.username;
    }

}
