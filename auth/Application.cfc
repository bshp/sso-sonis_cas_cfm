/*
 * ColdFusion CAS Client
 *
 * Created by Nic Raboy
 *
 */
component displayname="Application" author="Nic Raboy" output="false" {

    this.name = "Sonis CAS Authentication";
    this.applicationTimeout = createTimeSpan(0, 0, 1, 0);
    this.sessionTimeout = createTimeSpan(0, 0, 60, 0);
    this.sessionManagement = true;

    variables.hasCAS = true; // True if CAS should be used
    variables.hasSSL = true; // True if SSL should be used
    variables.cas_url = "https://cas.example.edu/cas/";
    variables.cas_service_url = "https://sonis.example.edu";
    variables.cas_direct_forwarding = true;

    /*
     * Runs when ColdFusion receives the first request for a page in the application
     *
     * @param
     * @return   boolean
     */
    public boolean function onApplicationStart() output="false" {
        return true;
    }

    /*
     * Initiate / construct the CAS session if CAS is enabled
     *
     * @param
     * @return
     */
    public void function onSessionStart() output="false" {
        if(variables.hasCAS) {
            session.cfcas = createObject("component", "components/cas").init(variables.cas_url, variables.cas_service_url, "/", variables.cas_direct_forwarding);
        }
    }

    /*
     * Runs when a request starts
     *
     * @param
     * @return   boolean
     */
    public boolean function onRequestStart() output="false" {
        if(cgi.server_port != "443" && variables.hasSSL == true) {
            location("https://" & cgi.http_host & cgi.script_name, false);
        }
        if(variables.hasCAS) {
            if(!structKeyExists(session, "cfcas") || !isInstanceOf(session.cfcas, "components/cas")) {
                onSessionStart();
            }
            session.cfcas.validate(cgi.script_name);
        }
        return true;
    }

    /*
     * Runs when a session ends
     *
     * @param    struct SessionScope
     * @param    struct ApplicationScope
     * @return
     */
    public void function onSessionEnd(required struct SessionScope, struct ApplicationScope=structNew()) output="false" {
        if(structKeyExists(session, "cfcas")) {
            structDelete(session, "cfcas");
        }
    }

    /*
     * Runs when a request specifies a non-existant CFML page
     *
     * @param    string TargetPage
     * @return   boolean
     */
    public boolean function onMissingTemplate(required string TargetPage) output="false" {
        switch(listLast(TargetPage, "/")) {
            case "logout.cfm":
                if(variables.hasCAS) {
                    session.cfcas.logout();
                    onSessionEnd();
                } else {
                    onSessionEnd();
                }
                break;
        }
        return true;
    }

}