(:~
 : RESTXQ interface for sxedit
 : @author Gerrit Imsieke
 :)
module namespace page = 'http://basex.org/modules/web-page';
declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $page:header as element(rest:response) :=
  <rest:response>
    <http:response status="200">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Access-Control-Allow-Origin" value="*"/>
      <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     </http:response>
  </rest:response>;

declare
  %rest:path("/content/dbs")
  %rest:GET 
  function page:list-dbs()
    as item()*
{
 $page:header,
  <response> 
    { for $db in db:list()
      return <db name="{$db}"/> }
  </response>
};

declare
  %rest:path("/content/db/{$db}")
  %rest:query-param("condition", "{$condition}")
  %rest:GET 
  function page:list-dbs(
    $db as xs:string,
    $condition as xs:string?
  )
    as item()*
{
  $page:header,
  <response> 
    { for $doc in db:list($db)
      where xquery:eval( "$doc" || $condition)
      return <doc name="{$doc}"/> }
  </response>
};


declare
  %rest:path("/content/doc/{$db}/{$doc}")
  %rest:query-param("condition", "{$condition}")
  %rest:GET 
  function page:list-tei-frags(
    $db as xs:string,
    $doc as xs:string,
    $condition as xs:string
  )
    as item()*
{
  $page:header,
  <response> 
    { for $doc in xquery:eval( "db:open($db, $doc)" || ($condition, '')[1], 
                               map { "db" := $db, "doc" := $doc} ) 
      return 
        for $node in ($doc/*, $doc//tei:div[not(ancestor::tei:div)][not(tei:divGen)])
        return <frag xpath="{path($node)}" title="{$node/tei:head}"/>
      }
  </response>
};

declare
  %rest:path("/content/frag/{$db}/{$doc}")
  %rest:query-param("xpath", "{$xpath}")
  %rest:GET 
  function page:get-frags(
    $db as xs:string,
    $doc as xs:string,
    $xpath as xs:string?
  )
    as item()*
{
  $page:header,
  xquery:eval( "db:open($db, $doc)" || $xpath,
               map { "db" := $db, "doc" := $doc } )
};
