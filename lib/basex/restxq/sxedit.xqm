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
 : @param $doc Document name
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
            "doc" := $doc,
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
  %rest:path("/content/_doc/{$db}/{$doc}")
  %rest:query-param("frag-expression", "{$frag-expression}")
  %rest:query-param("title-expression", "{$title-expression}")
  %rest:GET 
  function sxedit:_list-frags(
    $db as xs:string,
    $doc as xs:string,
    $frag-expression as xs:string?,
    $title-expression as xs:string?
  )
    as item()*
{
  $sxedit:header,
  <response> 
    { for $nodes at $pos in db:open($db, $doc)//*:div[not(ancestor::*:div)][not(*:divGen)]  
      return 
        for $node  in $nodes
        return <frag name="{$node/name()}" xpath="{path($node)}" title="{sxedit:frag-title($node, $title-expression, 28)}" seqno="{$pos}"/>
    }
  </response>
};


declare function sxedit:frag-title(
  $node as element(*),
  $title-expression as xs:string?,
  $max-length as xs:integer
) as xs:string
{
  for $n in $node
  let 
    $prelim-title as xs:string? :=
      if (exists($title-expression))
      then string(xquery:eval( "$n" || '/' || $title-expression, map { "n" := $n } ))
      else $n/local-name(),
    $title as xs:string :=
      if (normalize-space($prelim-title))
      then $prelim-title
      else $n/local-name()
  return 
    if (string-length($title) gt $max-length)
    then concat(substring($title, 1, $max-length - 1), '…')
    else $title
};

declare
  %rest:path("/content/frag/{$db}/{$doc}")
  %rest:query-param("xpath", "{$xpath}")
  %rest:GET 
  function sxedit:get-frags(
    $db as xs:string,
    $doc as xs:string,
    $xpath as xs:string?
  )
    as item()*
{
  $sxedit:header,
  for $frag as element(*) in db:open($db, $doc)/* (: xquery:eval( "db:open($db, $doc)" || ($xpath, '/*')[1], map { "db" := $db, "doc" := $doc } ) :)
  return
    if (db:node-id($frag) = db:node-id(db:open($db, $doc)/*))
    then sxedit:copy($frag, for $f in db:open($db, $doc)/(*, //*:div[not(ancestor::*:div)][not(*:divGen)]) return db:node-id($f))
    else $frag
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