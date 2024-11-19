-- 1. Utwórz w swoim schemacie kopię tabeli CYTATY ze schematu ZTPD.

CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;

-- 2. Znajdź w tabeli CYTATY za pomocą standardowego operatora LIKE cytaty, które
-- zawierają zarówno słowo ‘optymista’ jak i ‘pesymista’ ignorując wielkość liter.
SELECT * FROM CYTATY FETCH FIRST 10 ROWS ONLY;

SELECT * FROM CYTATY WHERE UPPER(TEKST) LIKE '%OPTYMISTA%' AND UPPER(TEKST) LIKE '%PESYMISTA%';

-- 3. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEKST tabeli CYTATY przy
-- domyślnych preferencjach dla tworzonego indeksu.

CREATE INDEX CYTATY_CTX_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

-- 4. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- zarówno słowo ‘optymista’ jak i ‘pesymista’ (ignorując wielkość liter w tym i kolejnych
-- zapytaniach ze względu na charakterystykę indeksu)

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'optymista AND pesymista', 1) > 0;

-- 5. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘pesymista’, a nie zawierają słowa ‘optymista’

select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'PESYMISTA - OPTYMISTA', 1) > 0;

-- 6. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
-- ‘optymista’ i ‘pesymista’ w odległości maksymalnie 3 słów.

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'near((pesymista, optymista),3)') > 0;

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'near((pesymista, optymista),10)') > 0;

-- 8. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘życie’ i jego odmiany. Niestety Oracle nie wspiera stemmingu dla języka polskiego. Dlatego
-- zamiast frazy ‘$życie’ „poratujemy się” szukaniem frazy ‘życi%’.

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

-- 9. Zmodyfikuj poprzednie zapytanie, tak by dla każdego pasującego cytatu wyświetlony
-- został stopień dopasowania (SCORE).

SELECT SCORE(1) AS SCORE, AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

-- 10. Zmodyfikuj poprzednie zapytanie, tak by wyświetlony został tylko najlepiej pasujący
-- cytat (w przypadku „remisu” może zostać wyświetlony dowolny z najlepiej pasujących
-- cytatów).

SELECT SCORE(1) AS SCORE, AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0
ORDER BY SCORE DESC FETCH FIRST 1 ROW ONLY;

-- 11. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘problem’ za pomocą wzorca z „literówką”: ‘probelm’.

SELECT * FROM CYTATY WHERE CONTAINS(TEKST,'FUZZY(PROBELM,,,N)', 1) > 0;

-- 12. Wstaw do tabeli CYTATY cytat Bertranda Russella 'To smutne, że głupcy są tacy pewni
-- siebie, a ludzie rozsądni tacy pełni wątpliwości.'. Zatwierdź transakcję.

INSERT INTO CYTATY VALUES (2001,'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

-- 13. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘głupcy’. Jak wyjaśnisz wynik zapytania?

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

-- nie zaindeksowało to nie ma

-- 14. Odszukaj w swoim schemacie tabelę, która zawiera zawartość indeksu odwróconego na
-- tabeli CYTATY. Wyświetl jej zawartość zwracając uwagę na to, czy słowo ‘głupcy’ znajduje
-- się wśród poindeksowanych słów.

select TOKEN_TEXT
from DR$CYTATY_CTX_IDX$I;

select TOKEN_TEXT
from DR$CYTATY_CTX_IDX$I
where lower(TOKEN_TEXT) = 'głupcy';

-- 15. Indeks CONTEXT utworzony przy domyślnych preferencjach nie jest uaktualniany na
-- bieżąco. Możliwa jest synchronizacja na żądanie (poprzez procedurę) lub zgodnie z zadaną
-- polityką (poprzez preferencję ustawioną przy tworzeniu indeksu: po zatwierdzeniu transakcji,
-- z zadanym interwałem czasowym). Można też przebudować indeks usuwając go i tworząc
-- ponownie. Wadą tej opcji jest czas trwania operacji i czasowa niedostępność indeksu, ale z tej
-- opcji skorzystamy ze względu na jej prostotę.

drop index CYTATY_CTX_IDX;

CREATE INDEX CYTATY_CTX_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

-- 16.
SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

-- 17.
drop index CYTATY_CTX_IDX;

drop table CYTATY;

-- Zaawansowane indeksowanie i wyszukiwanie
-- 1. Utwórz w swoim schemacie kopię tabeli QUOTES ze schematu ZTPD.

CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

-- 2. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEXT tabeli QUOTES przy
-- domyślnych preferencjach.

CREATE INDEX QUOTES_CTX_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

-- 3. Tabela QUOTES zawiera teksty w języku angielskim, dla którego Oracle Text obsługuje
-- stemming. Sprawdź działanie operatora CONTAINS dla wzorców:
-- - ‘work’
-- - ‘$work’
-- - ‘working’
-- - ‘$working’

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'work', 1) > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$work', 1) > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working', 1) > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working', 1) > 0;

-- 4. Spróbuj znaleźć w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘it’. Czy
-- system zwrócił jakieś wyniki? Dlaczego?

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'it', 1) > 0;

-- 5. Sprawdź jakie stop listy dostępne są w systemie. Odpytaj w tym celu perspektywę
-- słownikową CTX_STOPLISTS. Jak myślisz, którą system wykorzystywał przy
-- dotychczasowych zapytaniach?

SELECT * FROM CTX_STOPLISTS;

-- 6. Sprawdź jakie słowa znajdują się na domyślnej stop liście. Odpytaj w tym celu
-- perspektywę słownikową CTX_STOPWORDS.

SELECT * FROM CTX_STOPWORDS;

-- 7. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz go ponownie wskazując, że przy
-- indeksowaniu ma być użyta dostępna w systemie pusta stop lista.

DROP INDEX QUOTES_CTX_IDX;

CREATE INDEX QUOTES_CTX_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('STOPLIST CTXSYS.EMPTY_STOPLIST');

-- 8. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘it’. Czy tym razem system
-- zwrócił jakieś wyniki?

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'it', 1) > 0;

-- 9. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND humans', 1) > 0;

-- 10. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘computer’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

-- 11. Spróbuj znaleźć w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’ w jednym
-- zdaniu. Zinterpretuj komunikat o błędzie.

SELECT * FROM QUOTES where CONTAINS(TEXT,'(fool AND humans) within SENTENCE',1) > 0;
-- [99999][29902] ORA-29902: błąd podczas wykonywania podprogramu ODCIIndexStart() ORA-20000: Oracle Text error: DRG-10837: sekcja SENTENCE nie istnieje Position: 0

-- 12. Usuń indeks pełnotekstowy na tabeli QUOTES.

DROP INDEX QUOTES_CTX_IDX;

-- 13. Utwórz grupę sekcji bazującą na NULL_SECTION_GROUP, zawierającą dodatkowo
-- obsługę zdań i akapitów jako sekcji.

begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

-- 14. Utwórz ponownie indeks pełnotekstowy na tabeli QUOTES wskazując utworzoną grupę
-- sekcji obsługującą zdania i akapity.

CREATE INDEX QUOTES_CTX_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('SECTION GROUP nullgroup');

-- 15. Sprawdź czy teraz działają wzorce odwołujące się do zdań szukając najpierw cytatów
-- zawierających w tym samym zdaniu słowa ‘fool’ i ‘humans’, a następnie ‘fool’ i ‘computer’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND humans) within SENTENCE', 1) > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND computer) within SENTENCE', 1) > 0;

-- 16. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘humans’. Czy system
-- zwrócił też cytaty zawierające ‘non-humans’? Dlaczego?

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans', 1) > 0;

-- 17. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz preferencję dla leksera (używając
-- BASIC_LEXER), wskazującą, że myślnik ma być traktowany jako część indeksowanych
-- tokenów (składnik słów tak jak litery). Utwórz ponownie indeks pełnotekstowy na tabeli
-- QUOTES wskazując utworzoną preferencję dla leksera.

DROP INDEX QUOTES_CTX_IDX;

begin
    ctx_ddl.create_preference('my_lexer','BASIC_LEXER');
    ctx_ddl.set_attribute('my_lexer', 'printjoins', '_-');
    ctx_ddl.set_attribute ('my_lexer', 'index_text', 'YES');
end;

CREATE INDEX QUOTES_CTX_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('LEXER my_lexer');

-- 18. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘humans’. Czy system tym
-- razem zwrócił też cytaty zawierające ‘non-humans’?

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans', 1) > 0;

-- 19. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają frazę ‘non-humans’.
-- Wskazówka: myślnik we wzorcu należy „escape’ować” („skorzystać z sekwencji ucieczki”).

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'non\-humans', 1) > 0;

-- 20. Usuń swoją kopię tabeli QUOTES i utworzoną preferencję.

DROP INDEX QUOTES_CTX_IDX;

DROP TABLE QUOTES;

begin
    ctx_ddl.drop_preference('my_lexer');
end;