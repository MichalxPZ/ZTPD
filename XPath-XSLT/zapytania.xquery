for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/swiat.xml')//KRAJ[substring(NAZWA, 1, 1) = substring(STOLICA, 1, 1)]
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>