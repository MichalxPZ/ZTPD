xquery version "3.1";
(:for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/zesp_prac.xml'):)
(:return $k:)
(:return $k//ROW/NAZWISKO:)
(:return $k:)

(:for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/zesp_prac.xml')//ROW[NAZWA='SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW:)
(:return $k:)
(:return $k//ROW/NAZWISKO:)
(:return $k:)

(:for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/zesp_prac.xml')/count(ZESPOLY/ROW[ID_ZESP=10]/PRACOWNICY/ROW):)
(:return $k:)

(:for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW/PRACOWNICY/ROW[ID_SZEFA=100]:)
(:return $k//NAZWISKO:)

for $k in doc('file:////Users/michal/StudioProjects/INF-2ST-2sem-tpd/ZTPD/XPath-XSLT/zesp_prac.xml')/sum(ZESPOLY/ROW/PRACOWNICY[ROW/NAZWISKO="BRZEZINSKI"]/ROW/PLACA_POD)
return $k