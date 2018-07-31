/******

Copyright 2015 Jason A. Everling

MIT License

Copyright (c) 2015 Baptist School of Health Professions

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

For Connecting CAS SSO to SonisWeb

By: Jason A. Everling
Email: jeverling@bshp.edu

******/
CREATE VIEW [dbo].[vw_ssoLogin]
AS
SELECT DISTINCT RTRIM(dbo.name.soc_sec) AS nmid, RTRIM(dbo.name.first_name) AS firstname, 
				RTRIM(dbo.name.last_name) AS lastname, dbo.name.disabled AS nmdisabled, 
				RTRIM(dbo.name.ldap_id) AS nmldap, RTRIM(CONVERT(char, DECRYPTBYKEYAUTOCERT(CERT_ID('SSN'), NULL, dbo.name.pin))) AS nmpin, 
				RTRIM(dbo.nmmodst.mod_stat) AS modstat, RTRIM(dbo.security.user_id) AS secid, 
				RTRIM(dbo.security.ldap_id) AS secldap, RTRIM(CONVERT(char, DECRYPTBYKEYAUTOCERT(CERT_ID('SSN'), NULL, dbo.security.password))) AS secpin, 
				dbo.security.disabled AS secdisabled
FROM dbo.name 
	INNER JOIN dbo.nmmodst ON dbo.name.soc_sec = dbo.nmmodst.soc_sec 
	LEFT OUTER JOIN dbo.security ON dbo.name.soc_sec = dbo.security.soc_sec
GO
