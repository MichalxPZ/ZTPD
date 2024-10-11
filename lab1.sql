DROP TABLE samochody;
DROP TABLE wlasciciele;
DROP TYPE samochod;

-- Zdefiniuj typ obiektowy reprezentujący SAMOCHODY. Każdy samochód powinien
-- mieć markę, model, liczbę kilometrów oraz datę produkcji i cenę. Stwórz tablicę
-- obiektową i wprowadź kilka przykładowych obiektów, obejrzyj zawartość tablicy

create or replace type samochod as object (
  marka VARCHAR(20),
  model varchar(20),
  kilometry NUMBER(15),
  data_produkcji DATE,
  cena NUMBER(10,2)
);
create table samochody of samochod;

insert into samochody values (new samochod('Ford', 'Mondeo', 100000, TO_DATE('01-01-2017', 'dd-mm-yyyy'), 10000));
insert into samochody values (new samochod('Opel', 'Astra', 200000, TO_DATE('01-01-2016', 'dd-mm-yyyy'), 8000));
insert into samochody values (new samochod('Audi', 'A4', 300000, TO_DATE('01-01-2015', 'dd-mm-yyyy'), 15000));
insert into samochody values (new samochod('BMW', 'X5', 400000, TO_DATE('01-01-2014', 'dd-mm-yyyy'), 20000));
insert into samochody values (new samochod('Mercedes', 'E', 500000, TO_DATE('01-01-2013', 'dd-mm-yyyy'), 25000));

select * from samochody;

-- Stwórz tablicę WLASCICIELE zawierającą imiona i nazwiska właścicieli oraz atrybut
-- obiektowy SAMOCHOD. Wprowadź do tabeli przykładowe dane i wyświetl jej
-- zawartość.
create table wlasciciele (
    imie varchar(20),
    nazwisko varchar(20),
    samochod samochod
);

insert into wlasciciele values ('Jan', 'Kowalski', new samochod('Ford', 'Mondeo', 100000, TO_DATE('01-01-2017', 'dd-mm-yyyy'), 10000));
insert into wlasciciele values ('Adam', 'Nowak', new samochod('Opel', 'Astra', 200000, TO_DATE('01-01-2016', 'dd-mm-yyyy'), 8000));
insert into wlasciciele values ('Piotr', 'Kowalczyk', new samochod('Audi', 'A4', 300000, TO_DATE('01-01-2015', 'dd-mm-yyyy'), 15000));

select * from wlasciciele;

-- Wartość samochodu maleje o 10% z każdym rokiem. Dodaj do typu obiektowego
-- SAMOCHOD metodę wyliczającą aktualną wartość samochodu na podstawie wieku.

Alter type samochod add member function wartosc return number CASCADE;
create or replace type body samochod as
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * (1 - (months_between(sysdate, data_produkcji) / 12) * 0.1);
    END;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

-- Dodaj do typu SAMOCHOD metodę odwzorowującą, która pozwoli na porównywanie
-- samochodów na podstawie ich wieku i zużycia. Przyjmij, że 10000 km odpowiada
-- jednemu rokowi wieku samochodu.

Alter type samochod add map MEMBER FUNCTION porownaj RETURN NUMBER CASCADE INCLUDING TABLE DATA;
create or replace type body samochod as
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * (1 - (months_between(sysdate, data_produkcji) / 12) * 0.1);
    END;
    map MEMBER FUNCTION porownaj RETURN NUMBER IS
    BEGIN
        RETURN (months_between(sysdate, data_produkcji) / 12) + (kilometry / 10000);
    END;
END;

SELECT s.MODEL, s.MARKA, s.CENA, s.DATA_PRODUKCJI, s.KILOMETRY FROM SAMOCHODY s ORDER BY value(s) desc;

-- Stwórz typ WLASCICIEL zawierający imię i nazwisko właściciela samochodu, dodaj
-- do typu SAMOCHOD referencje do właściciela. Wypełnij tabelę przykładowymi
-- danymi.

create or replace type wlasciciel as object (
    imie varchar(20),
    nazwisko varchar(20)
);
drop table wlasciciele;
create table wlasciciele of wlasciciel;
insert into wlasciciele values (new wlasciciel('Jan', 'Kowalski'));
insert into wlasciciele values (new wlasciciel('Adam', 'Nowak'));
insert into wlasciciele values (new wlasciciel('Piotr', 'Kowalczyk'));


alter type samochod add attribute wlasciciel_auta REF wlasciciel CASCADE;

delete from samochody;
alter table samochody add scope for (wlasciciel_auta) IS WLASCICIELE;
insert into samochody
values
    (new samochod(
        'Ford', 'Mondeo', 100000, TO_DATE('01-01-2017', 'dd-mm-yyyy'),
        10000,
         (select ref(w) from wlasciciele w where w.imie = 'Jan' and w.nazwisko = 'Kowalski')
     )
);
select * from samochody;


-- Zbuduj kolekcję (tablicę o zmiennym rozmiarze) zawierającą informacje
-- o przedmiotach (łańcuchy znaków). Wstaw do kolekcji przykładowe przedmioty,
-- rozszerz kolekcję, wyświetl zawartość kolekcji, usuń elementy z końca kolekcji

DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
            moje_przedmioty(i) := 'PRZEDMIOT_' || i;
        END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

-- Zdefiniuj kolekcję (w oparciu o tablicę o zmiennym rozmiarze) zawierającą listę
-- tytułów książek. Wykonaj na kolekcji kilka czynności (rozszerz, usuń jakiś element,
-- wstaw nową książkę).
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    ksiazki.EXTEND(5);
    ksiazki(
        ksiazki.FIRST()
    ) := 'Ksiazka1';
    ksiazki(
        ksiazki.FIRST() + 1
    ) := 'Ksiazka2';
    ksiazki(
        ksiazki.FIRST() + 2
    ) := 'Ksiazka3';
    ksiazki(
        ksiazki.FIRST() + 3
    ) := 'Ksiazka4';
    ksiazki(
        ksiazki.FIRST() + 4
    ) := 'Ksiazka5';
    ksiazki.DELETE();
    ksiazki.EXTEND();
    ksiazki(ksiazki.LAST()) := 'Ksiazka6';
    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;
end;
--
-- Zbuduj kolekcję (tablicę zagnieżdżoną) zawierającą informacje o wykładowcach.
-- Przetestuj działanie kolekcji podobnie jak w przykładzie 6.
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
            moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
        END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- Zbuduj kolekcję (w oparciu o tablicę zagnieżdżoną) zawierającą listę miesięcy. Wstaw
-- do kolekcji właściwe dane, usuń parę miesięcy, wyświetl zawartość kolekcji./
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.EXTEND(12);
    miesiace(1) := 'STYCZEN';
    miesiace(2) := 'LUTY';
    miesiace(3) := 'MARZEC';
    miesiace(4) := 'KWIECIEN';
    miesiace(5) := 'MAJ';
    miesiace(6) := 'CZERWIEC';
    miesiace(7) := 'LIPIEC';
    miesiace(8) := 'SIERPIEN';
    miesiace(9) := 'WRZESIEN';
    miesiace(10) := 'PAZDZIERNIK';
    miesiace(11) := 'LISTOPAD';
    miesiace(12) := 'GRUDZIEN';

    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;

    miesiace.TRIM(2);

    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;

    miesiace.DELETE(5,7);

    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());


    FOR I IN miesiace.FIRST()..miesiace.LAST() LOOP
        IF miesiace.EXISTS(I) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(I));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
end;


-- 10. Sprawdź działanie obu rodzajów kolekcji w przypadku atrybutów bazodanowych.
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
                                     nazwa VARCHAR2(50),
                                     kraj VARCHAR2(30),
                                     jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
    ('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
    ('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
                                  numer NUMBER,
                                  egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
    NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
    (semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
    (semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

-- Zbuduj tabelę ZAKUPY zawierającą atrybut zbiorowy KOSZYK_PRODUKTOW
-- w postaci tabeli zagnieżdżonej. Wstaw do tabeli przykładowe dane. Wyświetl
-- zawartość tabeli, usuń wszystkie transakcje zawierające wybrany produkt.

CREATE TYPE produkt AS OBJECT (
    nazwa VARCHAR(20),
    cena NUMBER(10,2)
);
CREATE TYPE koszyk_produktow AS TABLE OF produkt;
CREATE TYPE zakup AS OBJECT (
    data DATE,
    koszyk koszyk_produktow
);
CREATE TABLE zakupy OF zakup
    NESTED TABLE koszyk STORE AS produkty;

INSERT INTO zakupy VALUES (
    TO_DATE('01-01-2017', 'dd-mm-yyyy'),
    koszyk_produktow(
        new produkt('Mleko', 2.5),
        new produkt('Chleb', 2.0),
        new produkt('Masło', 3.0)
    )
);

INSERT INTO zakupy VALUES (
    TO_DATE('16-01-2017', 'dd-mm-yyyy'),
    koszyk_produktow(
        new produkt('Ogrórki kiszone', 2.5),
        new produkt('COCA-COLA', 2.0),
        new produkt('Chipsy', 3.0)
    )
);

SELECT s.*, e.* FROM zakupy s, TABLE ( s.KOSZYK ) e;

DELETE FROM zakupy WHERE EXISTS (
    SELECT * FROM TABLE ( KOSZYK ) e WHERE e.nazwa = 'Mleko'
);


-- 12. Zbuduj hierarchię reprezentującą instrumenty muzyczne.
CREATE TYPE instrument AS OBJECT (
                                     nazwa VARCHAR2(20),
                                     dzwiek VARCHAR2(20),
                                     MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN dzwiek;
    END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
                                                 material VARCHAR2(20),
                                                 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
                                                 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dmucham: '||dzwiek;
    END;
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN glosnosc||':'||dzwiek;
    END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
                                                       producent VARCHAR2(20),
                                                       OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'stukam w klawisze: '||dzwiek;
    END;
END;
/
DECLARE
    tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;

-- 13. Zbuduj hierarchię zwierząt i przetestuj klasy abstrakcyjne.
CREATE TYPE istota AS OBJECT (
                                 nazwa VARCHAR2(20),
                                 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
    NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
                                 liczba_nog NUMBER,
                                 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: '||ofiara;
    END;
END;
DECLARE
    KrolLew lew := lew('LEW',4);
    InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
    DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
-- 14. Zbadaj własność polimorfizmu na przykładzie hierarchii instrumentów.
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;
-- 15. Zbuduj tabelę zawierającą różne instrumenty. Zbadaj działanie funkcji wirtualnych.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
                               );
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;
