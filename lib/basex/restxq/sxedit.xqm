(:~
 : RESTXQ interface for sxedit
 : @author Gerrit Imsieke
 :)
module namespace sxedit = 'http://www.le-tex.de/namespace/sxedit';
declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $sxedit:header as element(rest:response) :=
  <rest:response>
    <http:response status="200">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Access-Control-Allow-Origin" value="*"/>
      <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     </http:response>
  </rest:response>;

declare
  %rest:path("/content/dbs")
  %rest:query-param("doc-condition", "{$doc-condition}")
  %rest:GET 
  function sxedit:list-dbs(
    $doc-condition as xs:string?
  )
    as item()*
{
 $sxedit:header,
  <response> 
    { for $db in db:list()
      where 
        if (exists($doc-condition))
        then xquery:eval( "exists(db:open($db)/*" || $doc-condition || ")", map { "db" := $db } )
        else true()
      return <db name="{$db}"/> }
  </response>
};

declare
  %rest:path("/content/db/{$db}")
  %rest:query-param("doc-condition", "{$doc-condition}")
  %rest:GET 
  function sxedit:list-dbs(
    $db as xs:string,
    $doc-condition as xs:string?
  )
    as item()*
{
  $sxedit:header,
  <response> 
    { for $doc in db:list($db)
      where 
        if (exists($doc-condition))
        then xquery:eval( "exists(db:open($db, $doc)/*" || $doc-condition || ")", map { "db" := $db, "doc" := $doc })
        else true()
      return <doc name="{$doc}"/> }
  </response>
};

(:~
 : This function returns an XML response message with pointers
 : to all fragments in a document.
 : Make sure that the necessary URL escaping will be performed to
 : the query arguments when calling the RESTXQ path. 
 : @param $db Database name
 : @param $doc Document name. If it contains forward slashes, they need
 : to be passed as '∕' (U+2215, this feels phishy, doesn’t it?) because 
 : ordinary slashes don’t work with REST paths, for obvious reasons. 
 : Escaping them as '%2F' could not be used with BaseX for unknown reasons.
 : @param $frag-expression XPath expression to select the fragments
 : in a document. Example: '//*:div[not(ancestor::*:div)][not(*:divGen)]'
 : @param $title-expression XPath expression to select the title of 
 : a fragment. Example: '*:head'. Please note that there is already a 
 : slash before this expression, as in $node/*:head. This is different
 : from $frag-expression.
 : @return response element
 :)
declare
  %rest:path("/content/doc/{$db}/{$doc}")
  %rest:query-param("frag-expression", "{$frag-expression}")
  %rest:query-param("title-expression", "{$title-expression}")
  %rest:query-param("max-title-length", "{$max-title-length}")
  %rest:GET 
  function sxedit:list-frags(
    $db as xs:string,
    $doc as xs:string,
    $frag-expression as xs:string?,
    $title-expression as xs:string?,
    $max-title-length as xs:string?
  )
    as item()*
{
  $sxedit:header,
  <response> 
    { for $query as xs:string in 
       'for $docroot in db:open($db, $doc)
        let $nodes := ($docroot/* | $docroot' || ($frag-expression, "/*")[1] || ')
        return
          for $node as element(*) at $pos in $nodes
          let 
            $prelim-title as xs:string := string($node/(' || $title-expression || ', (concat("[",name(),"]")))[1]),
            $max-length as xs:integer := xs:integer(($max-title-length, "30")[1]),
            $title as xs:string := 
              if (string-length($prelim-title) gt $max-length)
              then concat(substring($prelim-title, 1, $max-length - 1), "…")
              else $prelim-title
          return <frag name="{$node/name()}" xpath="{path($node)}" title="{$title}" seqno="{$pos}"/>'
      return (
        attribute {'query'} {$query},
        xquery:eval(
          $query, 
          map { 
            "db" := $db,
            "doc" := replace($doc, '∕', '/'),
            "title-expression" := $title-expression, 
            "frag-expression" := $frag-expression,
            "max-title-length" := $max-title-length
          }
        )
      )
    }
  </response>
};

declare
  %rest:path("/content/frag/{$db}/{$doc}")
  %rest:query-param("xpath", "{$xpath}")
  %rest:query-param("title-expression", "{$title-expression}")
  %rest:query-param("frag-expression", "{$frag-expression}")
  %rest:GET 
  function sxedit:get-frags(
    $db as xs:string,
    $doc as xs:string,
    $xpath as xs:string?,
    $title-expression as xs:string?,
    $frag-expression as xs:string?
  )
    as item()*
{
  $sxedit:header,
  for $query as xs:string in 
   'declare function local:copy(
      $element as element(),
      $fragment-ids as xs:integer* 
    ) {
      element {node-name($element)} {
        $element/@*, 
        for $child in $element/node()
        return 
          if (db:node-id($child) = $fragment-ids)
          then element {node-name($child)} {
            $child/@*, 
            attribute {"sxedit-xpath"} {path($child)} '
            || (if ($title-expression) then concat(', $child/', $title-expression) else '') || '
          }
          else
            if ($child instance of element())
            then local:copy($child, $fragment-ids)
            else $child
      }
    };
    for $docroot in db:open($db, $doc)
    let $frag as element(*) := $docroot' || ($xpath, "/*")[1] || '
    return
      local:copy($frag, for $f in ($docroot/* | $docroot' || ($frag-expression, "/*")[1] || ') return db:node-id($f))'
  return (
    xquery:eval(
      $query, 
      map { 
        "db" := $db,
        "doc" := replace($doc, '∕', '/'),
        "xpath" := $xpath,
        "frag-expression" := $frag-expression
      }
    )
  )
};

declare function sxedit:copy(
  $element as element(),
  $fragment-ids as xs:integer* 
) {
  element {node-name($element)}
    {$element/@*, attribute {'bla'} {$fragment-ids}, attribute {'nid'} {db:node-id($element)},
     for $child in $element/node()
        return 
          if (db:node-id($child) = $fragment-ids)
          then element {(node-name($child), 'foo')[1]}
            {$child/@*, attribute {'sxedit-terminus'} {path($child)}}
          else
            if ($child instance of element())
            then sxedit:copy($child, $fragment-ids)
            else $child
    }
};

(:~
 : This function accepts an XML document whose top-level element
 : must be an *:frag element with attributes db, doc, and xpath.
 : These attributes specify where to store the payload which must 
 : be the only child of the top-level *:frag element.
 : Make sure that the necessary URL escaping will be performed to
 : the query arguments when calling the RESTXQ path. 
 : @param $wrapper The POSTed message
 :)
declare
  %rest:path("/content/save-frag")
  %rest:POST("{$wrapper}")
  %updating 
  function sxedit:save-frag(
    $wrapper as  (: document-node(element(sxedit:frag)) :) xs:string  
  )
  {
  db:output(
  <rest:response>
    <http:response status="200">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Access-Control-Allow-Origin" value="*"/>
      <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     </http:response>
  </rest:response>
  ),
    let $doc := parse-xml($wrapper)
    return
    replace node db:open($doc/*:frag/@db, $doc/*:frag/@doc)//*[path() eq $doc/*:frag/@xpath]
    with $doc/*:frag/*
}
;

