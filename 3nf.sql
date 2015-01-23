drop table if exists keyval;
create table keyval (key text, val text);
.separator =
.import faims.properties keyval

update keyval set key = '{'||key||'}';

--select astext(geospatialcolumn), * from latestnondeletedaentvalue join latestnondeletedarchent using (uuid);

--select aenttypename, attributeid, attributename from idealaent join aenttype using (aenttypeid) join attributekey using (attributeid);
drop view if exists identifierAsSpreadsheet;
create view identifierAsSpreadsheet as select uuid, group_concat(coalesce(measure || ' ' || coalesce(val, vocabname) || '(' ||freetext||')',  measure || ' (' || freetext ||')',  coalesce(val, vocabname) || ' (' || freetext ||')',  measure || ' ' || coalesce(val, vocabname) ,  coalesce(val, vocabname) || ' (' || freetext || ')',  measure || ' (' || freetext || ')',  measure, coalesce(val, vocabname),  freetext,  measure, coalesce(val, vocabname),  freetext), ' ') || coalesce(case certainty when certainty < 1 and certainty is not null then '?' else '' end, '') as response from (select * from latestNonDeletedArchentIdentifiers left outer join keyval on (vocabname = key) order by attributename)  group by uuid;

drop view if exists valueAsSpreadsheet;
create view valueAsSpreadsheet as select uuid, coalesce(measure || ' ' || coalesce(val, vocabname) || '(' ||freetext||')',  measure || ' (' || freetext ||')',  coalesce(val, vocabname) || ' (' || freetext ||')',  measure || ' ' || coalesce(val, vocabname) ,  coalesce(val, vocabname) || ' (' || freetext || ')',  measure || ' (' || freetext || ')',  measure, coalesce(val, vocabname),  freetext,  measure, coalesce(val, vocabname),  freetext) || coalesce(case  when  cast(certainty as double) < 1.0  then '?' else '' end, '')as response, attributeid, attributename, valuetimestamp from (select * from latestNonDeletedAentValue join attributekey using (attributeid) 
left outer join vocabulary using (vocabid, attributeid) left outer join keyval on (vocabname = key) order by uuid, attributename);


drop view if exists createdAtBy;
create view createdAtBy as select uuid, aenttimestamp as createdAt, fname || ' ' || lname as createdBy
	from archentity join user using (userid)
	where uuid in (select uuid from latestnondeletedarchent)
	group by uuid
	having min(aenttimestamp);

.mode list
.header off
-- select 'select DiscardGeometryColumn ('''|| f_table_name||''','''|| f_geometry_column||''');' from geometry_columns where f_Geometry_column = 'geometry';
select 'drop table if exists '|| replace(replace(aenttypename,' ', ''),'/','') ||'; 
create table '|| replace(replace(aenttypename,' ', ''),'/','') ||' ( uuid text primary key, aenttypename text, modifiedAt text , modifiedBy text, createdAt text, createdBy text, identifier text, '|| group_concat(replace(replace(replace(replace(replace(attributename, ' ', '_'),'(',''),')',''),'-','_'),'?','_') || ' text',', ') || ');' from idealaent join aenttype using (aenttypeid) join attributekey using (attributeid) 
	group by aenttypename
	;

-- select 'select addgeometrycolumn('''||aenttypename||''', ''geometry'', 4326, '''||case geometrytype(geometryn(geospatialcolumn,1)) when 'POINT' then 'MULTIPOINT' else geometrytype(geometryn(geospatialcolumn,1)) end || ''', ''XY'');' from latestnondeletedarchent join aenttype using (aenttypeid) group by aenttypeid having geometrytype(geometryn(geospatialcolumn,1)) is not null;

-- select 'alter table '|| f_table_name|| ' add column WKT text; ' from geometry_columns where f_Geometry_column = 'geometry';

--select 'update ' || f_table_name || 'set geometry = geomfromtext(), wkt ='

select 'insert into ' || replace(replace(aenttypename,' ', ''),'/','') || ' (uuid, aenttypename, modifiedAt, modifiedBy, createdAt, createdBy, identifier)
select uuid, aenttypename, aenttimestamp, fname || '' '' || lname, createdAt, createdBy, response
from aenttype join latestnondeletedarchent using (aenttypeid) join createdAtBy using (uuid) join user using (userid) join identifierAsSpreadsheet using (uuid)
where aenttypeid = '|| aenttypeid || ';'
from aenttype
;

/*
select 'update '||replace(replace(aenttypename,' ', ''),'/','') || ' set '||replace(replace(replace(replace(attributename, ' ', '_'),'(',''),')',''),'-','_') || ' = (select response, uuid from valueAsSpreadsheet join latestnondeletedarchent using (uuid) where aenttypeid = ' || aenttypeid || ' and attributeid = ' || attributeid || ');'
from idealaent join aenttype using (aenttypeid) join attributekey using (attributeid);
*/



.separator | 
select 'update '|| replace(replace(aenttypename,' ', ''),'/','') || ' set ' || replace(replace(replace(replace(replace(attributename, ' ', '_'),'(',''),')',''),'-','_'),'?','_') || ' = ''' || group_concat(replace(response,'''', ''''''),', ') || ''' where uuid = '||  uuid || ';' from valueAsSpreadsheet join latestnondeletedarchent using (uuid) join aenttype using (aenttypeid) where response is not null group by uuid, attributeid;



select '.mode csv
.header on';

select '
.output Table'|| replace(replace(aenttypename,' ', ''),'/','') || '.csv 
select * from '||replace(replace(aenttypename,' ', ''),'/','')||';'
from aenttype;
/*
select '
select * from '||replace(replace(aenttypename,' ', ''),'/','')||';'
from aenttype;
*/

select 'drop table if exists exportRelns; create table exportRelns as
select parent.aenttypename || '': ''||parent.response || '' '' || coalesce(parent.participatesverb,relntypename) || '' '' || child.aenttypename ||'': '' || child.response,  parent.uuid, child.uuid, fname || '' '' || lname as createdBy, parent.aentrelntimestamp as modifiedAt
from (latestNonDeletedAentReln join identifierAsSpreadsheet using (uuid) join latestnondeletedarchent using (uuid) join aenttype using (aenttypeid)) parent  
join (latestNonDeletedAentReln join identifierAsSpreadsheet using (uuid) join latestnondeletedarchent using (uuid) join aenttype using (aenttypeid)) child on (parent.relationshipid = child.relationshipid and parent.uuid != child.uuid) 
join latestNonDeletedRelationship using (relationshipid) join relntype using (relntypeid) join user using (userid)
order by parent.aenttypename, parent.response, child.aenttypename, child.response;
.output Relationships.csv
select * from exportRelns;
';