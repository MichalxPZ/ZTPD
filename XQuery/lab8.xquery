(:for $last in doc("db/bib/bib.xml")//author/last:)
(:return $last:)

(:for $book in doc("db/bib/bib.xml")//book:)
(:let $title := $book/title:)
(:for $author in $book/author:)
(:return:)
(:  <ksiazka>:)
(:    <author>:)
(:      <first>{$author/first/text()}</first>:)
(:      <last>{$author/last/text()}</last>:)
(:    </author>:)
(:    <title>{$title/text()}</title>:)
(:  </ksiazka>:)

(:<wynik>{:)
(:    for $book in doc("db/bib/bib.xml")//book:)
(:    let $title := $book/title:)
(:    for $author in $book/author:)
(:    return:)
(:      <ksiazka>:)
(:        <autor>{concat($author/last/text(), " ", $author/first/text())}</autor>:)
(:        <tytul>{$title/text()}</tytul>:)
(:      </ksiazka>:)
(: }</wynik>:)

(:for $book in doc("db/bib/bib.xml")//book[title="Data on the Web"]:)
(:for $author in $book/author:)
(:return $author/first:)

(:doc("db/bib/bib.xml")//book[title="Data on the Web"]:)
(:for $book in doc("db/bib/bib.xml")//book:)
(:where $book/title = "Data on the Web":)
(:return $book:)

(: for $book in doc("db/bib/bib.xml")//book[contains(title, "Data")]:)
(:    return:)
(:      <Data>:)
(:        <title>{$book/title/text()}</title>:)
(:        {:)
(:          for $author in $book/author:)
(:          return <nazwisko>{$author/last/text()}</nazwisko>:)
(:        }:)
(:      </Data>:)

(:for $book in doc("db/bib/bib.xml")//book:)
(:let $authorCount := count($book/author):)
(:where $authorCount <= 2:)
(:return <title>{$book/title/text()}</title>:)

(:for $book in doc("db/bib/bib.xml")//book:)
(:let $authorCount := count($book/author):)
(:return:)
(:  <book>:)
(:    <title>{$book/title/text()}</title>:)
(:    <autorow>{$authorCount}</autorow>:)
(:  </book>:)

(: <przedział>:)
(:  {min(doc("db/bib/bib.xml")/bib/book/@year) || ' - ' || max(doc("db/bib/bib.xml")/bib/book/@year)}:)
(:</przedział>:)

(:let $prices := doc("db/bib/bib.xml")//book/price:)
(:let $minPrice := min($prices):)
(:let $maxPrice := max($prices):)
(:let $priceDifference := $maxPrice - $minPrice:)
(:return:)
(:  <priceDifference>{$priceDifference}</priceDifference>:)

(:let $books := doc("db/bib/bib.xml")//book:)
(:let $minPrice := min($books/price):)
(:for $book in $books[price = $minPrice]:)
(:return:)
(:  <book>:)
(:    <title>{$book/title/text()}</title>:)
(:    {:)
(:      for $author in $book/author:)
(:      return:)
(:        <author>:)
(:          <first>{$author/first/text()}</first>:)
(:          <last>{$author/last/text()}</last>:)
(:        </author>:)
(:    }:)
(:  </book>:)
(:  :)

(:let $authors := distinct-values(doc("db/bib/bib.xml")//author/last):)
(:for $last in $authors:)
(:let $books := doc("db/bib/bib.xml")//book[author/last = $last]/title:)
(:return:)
(:  <author>:)
(:    <last>{$last}</last>:)
(:    <books>:)
(:      {:)
(:        for $title in $books:)
(:        return <title>{$title/text()}</title>:)
(:      }:)
(:    </books>:)
(:  </author>:)

(:<wynik>:)
(:{:)
(:  for $play in collection("db/shakespeare")//PLAY/TITLE:)
(:  return <TITLE>{$play/text()}</TITLE>:)
(:}:)
(:</wynik>:)

(:<wynik>:)
(:{:)
(:  for $play in collection("db/shakespeare")//PLAY:)
(:  where some $line in $play//LINE satisfies contains($line, "or not to be"):)
(:  return <TITLE>{$play/TITLE/text()}</TITLE>:)
(:}:)
(:</wynik>:)

<wynik>
{
  for $play in collection("db/shakespeare")//PLAY
  let $title := $play/TITLE/text()
  let $characters := count($play//PERSONA)
  let $acts := count($play//ACT)
  let $scenes := count($play//SCENE)
  return
    <play>
      <title>{$title}</title>
      <characters>{$characters}</characters>
      <acts>{$acts}</acts>
      <scenes>{$scenes}</scenes>
    </play>
}
</wynik>