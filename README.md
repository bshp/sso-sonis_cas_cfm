# CAS Auth for SonisWeb
Use CAS SSO for Faculty/Staff and Students in SonisWeb

This project was created to support SSO functionality in SonisWeb without modification to any directory or database. This is meant to be a starting point so that you can get an idea of how easily you could connect an SSO system to Sonis.

### Requirements
LDAP_ID in Sonis for Faculty/Staff/Students, can be any other unique id if not ldap_id.

##### Note
Index.cfm and/or db view will need to be modified if not using ldap_id

### Install
Set CAS login URL and Sonis service url in application.cfc
Edit 'datasourceName' in Index.cfm to your Sonis datasource name that is set in CF admin

#### 3rd Party CFC Cas Client
application.cfc and cas.cfc by Nic Raboy, great find for this use case.