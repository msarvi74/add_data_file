CREATE OR REPLACE PROCEDURE add_datafile AS
    v_name    VARCHAR2(1000);
    v_query   VARCHAR2(4000);
    v_space   number;  
BEGIN
select * into v_space  from df;
if v_space > 2048 then
    for i in (with datafile_detailes as (SELECT a.file_name,
       substr(A.tablespace_name,1,14) tablespace_name,
       trunc(decode(A.autoextensible,'YES',A.MAXSIZE-A.bytes+b.free,'NO',b.free)/1024/1024) free_mb,
       trunc(a.bytes/1024/1024) allocated_mb,
       trunc(A.MAXSIZE/1024/1024/1024) capacity_gb,
       a.autoextensible auto_extend,
       nvl(substr((trunc(decode(A.autoextensible,'YES',A.MAXSIZE-A.bytes+b.free,'NO',b.free)/1024/1024)/trunc(A.MAXSIZE/1024/1024))*100,1,6),0) percent_free
FROM (
     SELECT file_id, file_name,
            tablespace_name,
            autoextensible,
            bytes,
            decode(autoextensible,'YES',maxbytes,bytes) maxsize
     FROM   dba_data_files
     GROUP BY file_id, file_name,
              tablespace_name,
              autoextensible,
              bytes,
              decode(autoextensible,'YES',maxbytes,bytes)
     ) a,
     (SELECT file_id,
             tablespace_name,
             sum(bytes) free
      FROM   dba_free_space
      GROUP BY file_id,
               tablespace_name
      ) b
WHERE a.file_id=b.file_id(+)
AND A.tablespace_name=b.tablespace_name(+)
ORDER BY A.tablespace_name ASC)
select sum(free_mb),tablespace_name from datafile_detailes group by tablespace_name having sum(free_mb)<2048)loop
select i.tablespace_name||'_'||datafile_add_seq.nextval into v_name  from dual;
select  'alter tablespace '||i.tablespace_name||' add datafile '||q'[']'||v_name||q'[']'||' size 1024m autoextend on next  1024m'
into v_query from dual;
execute immediate v_query;
select i.tablespace_name||'_'||datafile_add_seq.nextval into v_name  from dual;
select  'alter tablespace '||i.tablespace_name||' add datafile '||q'[']'||v_name||q'[']'||' size 1024m autoextend on next  1024m'
into v_query from dual;
execute immediate v_query;
end loop;
end if;

END;