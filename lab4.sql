-- 1. A. Utwórz tabelę o nazwie FIGURY z dwoma kolumnami:
--  ID - number(1) - klucz podstawowy
--  KSZTALT - MDSYS.SDO_GEOMETRY.

CREATE TABLE FIGURY
(
    ID NUMBER(1) PRIMARY KEY,
    KSZTALT MDSYS.SDO_GEOMETRY
);

INSERT INTO FIGURY VALUES(
     1,
     MDSYS.SDO_GEOMETRY(
             2003,
             NULL,
             NULL,
             MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
             MDSYS.SDO_ORDINATE_ARRAY(5,7, 3,5, 5,3) )
 );

INSERT INTO FIGURY VALUES(
 2,
 MDSYS.SDO_GEOMETRY(
         2003,
         NULL,
         NULL,
         MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
         MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)
 ) );

INSERT INTO figury VALUES(
 3,
 MDSYS.SDO_GEOMETRY(
         2002,
         NULL,
         NULL,
         SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
         SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1) ) );
commit;
--
-- Wstaw do tabeli FIGURY własny kształt o nieprawidłowej definicji (przykłady: otwarty wielokąt,
-- wielokąt zdefiniowany w oparciu o punkty podane w nieprawidłowej kolejności, koło
-- zdefiniowane przez punkty leżące na prostej, kształt, którego definicja elementów określona w
-- SDO_ELEM_I|NFO jest niezgodna z typem geometrii SDO_GEOM itp.)

INSERT INTO figury VALUES(
 4,
MDSYS.SDO_GEOMETRY(
     2003,
     NULL,
     NULL,
     MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
     MDSYS.SDO_ORDINATE_ARRAY(6,6, 6,6) ) );
commit;
SELECT id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt,0.01) FROM figury;
DELETE FROM figury WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt,0.01) <> 'TRUE'
COMMIT;