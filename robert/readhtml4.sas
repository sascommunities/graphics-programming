/*
Macro graciously provided by Rick Langston.

This is a later/more-updated version of the macro described in:
http://support.sas.com/resources/papers/proceedings09/052-2009.pdf

For internal SAS folks, the code is also located here:
/u/sasrdl/from_email/readhtml4.sas

And you might use it such as ...

%inc '/u/sasrdl/from_email/readhtml4.sas'; 
%readhtml2(
'https://en.wikipedia.org/wiki/List_of_Justices_of_the_Supreme_Court_of_the_United_States'
); 
data _null_; set table2; put _all_; run;
*/


 /* THis macro will read the contents of a URL, looking for all table definitions (i.e. 
    tagged by <table...> and </table...>. It allows for the tags to be all upcased 
    or all lowercased. Within each table, the total number of row tags (tr) and 
    max column tags (td) within each row is determined. Then, a SAS data set is 
    produced for each table, containing the number of determined rows, and with the 
    determined number of columns. The text of each column is stripped of any 
    tags such as <small> or <a href=....>. If there are tables within tables, this 
    will still work, but each table is treated as a separate entity and there is 
    know apparent association betweenthe tables. Each data set created is named
    table1, table2, ... etc. The varnames are col1, col2, etc. If a column is
    determined to be all blank the variable is dropped. If the column appears to
    contain only dates, the variable is made numeric and is given a date9. format.
    If the column otherwise appears to contain only numeric data, the variable is
    made numeric but no format is associated. */

 /* Several techniques/issues in this code:
    1) The contents of the URL are written to a temporary file byte by byte so
       we know the actual file size. Then all subsequent accesses of the file
       use RECFM=F LRECL=n COLUMN=C MISSOVER so that we treat the file as one
       big record. This is necessary to allow for INPUT @'text' to work, since
       this won't work with RECFM=N. Using MISSOVER allows us to continue
       execution even though we hit EOF. The COLUMN= option will always let us
       know where we are.
    2) INPUT @'...' is used. Also INPUT @(trim(...)) is used.
    3) The useful CAT and CATX functions are used.
    4) Issue involving CALL EXECUTE vs. %INCLUDE of macro invocation. 
    5) Use of ?? with INPUT function.
 */
       
%macro readhtml2(url,row1_is_labels=no); 
%global closetags drops renames dates nobs ntables;

 /* This macro will make a pass through the file, creating a tablen data
    set, between a starting and ending column position, and for a given
    number of rows and columns. */
%macro readtable(tablenum,start,end,nrows,ncols);
data table&tablenum.; 
     infile myfile recfm=f lrecl=&filesize. column=c missover;
     array col{*} $200 col1-col&ncols.; 
     keep col1-col&ncols.; 

     *-----start at the beginning of our table-----*;
     input @&start @; 
     endrow=.; 

     *-----read each row-----*;
     do i=1 to &nrows; 

        *-----row starts with <TR or <tr tag-----*;
        input @"<TR" @; 
        startcol=c; 

        *-----determine where to stop, using </tr, next <tr, or next <table-----*;
        %if &closetags.=Y %then %do;
        input @"</TR" @; 
        endrow=c-4;
        %end;
        %else %do; 
        if i<&nrows then do;
           input @"<TR" @; 
           endrow=c-4; 
           end;
        else do; 
           input @"<TABLE " @;
           endrow=c-7;
           end;
        %end;

        *-----go back to start reading contents of row-----*;
        input @startcol @;  

        *-----read all the column data for the row-----*;
        do j=1 to &ncols; 

           *-----col starts with <TD tag-----*;
           input @"<TD" @; 

           *-----blank out remaining columns if we hit the end-----*;
           if c>=endrow then do; 
              do k=j to &ncols; 
                 col{j}=' '; 
                 end;
              input @endrow @;
              leave; 
              end;

           *----get past end of tag-----*;
           input @'>' @; 
           startcol=c; 

           *-----compute where to end the column data using </TD, <TR, or <TABLE-----*;
           %if &closetags.=Y %then %do; 
           input @"</TD" @; 
           %end; %else %do; 
           if j<&ncols then input @"<TD" @; 
           else if i<&nrows then input @"<TR" @; 
           else input @"</TABLE" @; 
           %end; 

           *-----read everything between----*;
           l=c-5-startcol+1;
           input @startcol text $varying32767. l @;

           kk=0;
           do while(1); 
              ii=index(text,'<'); 
              if ii=0 then leave; 
              jj=index(substr(text,ii),'>'); 
              if jj=0 then leave; 
              substr(text,ii,jj)=' ';
              end;
           text=left(compbl(text));

           *-----change escape sequences to the right characters-----*;
           text=tranwrd(text,'&amp;','&'); 
           text=tranwrd(text,'&lt;','<'); 
           text=tranwrd(text,'&rt;','>'); 
           text=tranwrd(text,'&nbsp;',' '); 

           *-----remove any stray crlf chars and convert tabs to blanks-----*;
           text=compress(text,'0d0a'x); 
           text=translate(text,' ','09'x); 

           *-----save this as our column value-----*;
           col{j}=text; 
           end; 
        output;
        end;
     stop; 
     run;

/* If the user specifies row1_is_labels=yes, then the values of col1-coln are
   labels to be associated with the variables. We generate the LABEL statements
   here both for col1-coln and numcol1-numcoln. For row1_is_labels=no, the 
   file generated just has a blank line. */

filename labstmts temp; 
data _null_; file labstmts; put ' '; run;
%let tableobs=1; 

%if &row1_is_labels=yes %then %do; 
%let tableobs=2; 
data _null_; set table&tablenum.(obs=1); 
     array col{*} col1-col&ncols.; 
     file labstmts; 
     length labelstmt $300; 
     do i=1 to &ncols; 
        if col{i}=' ' then continue;
        labelstmt=cats('label    col',i,'=',put(col{i},$quote.),';'); 
        put labelstmt; 
        substr(labelstmt,7,3)='num'; 
        put labelstmt; 
        end;
     run;
%end;


 /* This code examines the table to see if columns are completely blank,
    or if a column consists solely of dates or solely of numerics. */

data table&tablenum.; 
     retain 
     %do i=1 %to &ncols; 
         col&i numcol&i
         %end; 
            ;
     set table&tablenum.(firstobs=&tableobs.) end=eof; 
     array col{*} col1-col&ncols.; 
     array numcol{*} numcol1-numcol&ncols.; 
     keep col1-col&ncols. numcol1-numcol&ncols.; 
     %include labstmts/source2; 
     array status{&ncols.} $1 _temporary_; 
     length text $1024; 
     do i=1 to &ncols; 
        if status{i}='C' then continue; 
        text=left(col{i});
        numcol{i}=.;  
        if text=' ' then continue; 
        if status{i}=' ' then do; 
           link try_numeric; 
           if numcol{i}^=. then do; 
              status{i}='N'; 
              end;
           else if text='-' then do; 
              status{i}='N'; 
              end;
           else do; 
              link try_date; 
              if numcol{i}^=. then do; 
                 status{i}='D'; 
                 end;
              end;
           if status{i}=' ' then status{i}='C'; 
           end;
        else if status{i}='D' then do; 
           link try_date; 
           if numcol{i}=. then do; 
              status{i}='C'; 
              end;
           end;
        else if status{i}='N' then do; 
           link try_numeric; 
           if numcol{i}=. and text ne '-' then do; 
              status{i}='C'; 
              end;
           end;
        end;
     output;
     if eof;

     /* If the column is numeric, we will drop the COLn variable,
        and rename the NUMCOLn variable to COLn.
        If the column is all blank, we will drop the COLn variable.
        If the column is a date, we will have a FORMAT statement
        associating the variable with DATE9. */

     length renames drops dates $32767; 
     do i=1 to &ncols; 
        if status{i}='N' or status{i}='D' then do;
           renames=cat(trim(renames),' numcol',i,'=col',i); 
           drops=cat(trim(drops),' col',i); 
           end;
        else if status{i}=' ' then do; 
           drops=cat(trim(drops),' col',i,' numcol',i); 
           end;
        else if status{i}='C' then do; 
           drops=cat(trim(drops),' numcol',i); 
           end;
        if status{i}='D' then do; 
           dates=cat(trim(dates),' col',i); 
           end;
        end;
     drops='drop='||drops; 
     if renames^=' ' then renames='rename=('||trim(renames)||')'; 
     if dates^=' ' then dates='format '||trim(dates)||' date9.;'; 
     call symput('drops',trim(drops)); 
     call symput('renames',trim(renames)); 
     call symput('dates',trim(dates)); 
     return;

 /* The TRY_NUMERIC link will use BEST32. on the field to see if it converts
    to a number. We use the INPUT function with the ?? operator to indicate 
    that _ERROR_ will not be set and no warning message will appear about 
    invalid data. This link will not be invoked if text is blank, so any 
    other text causing numcol to become missing indicates an invalid numeric
    value (except for ., which we will assume here to mean non-numeric). The
    TRY_DATE link does the same except it uses ANYDTDTE, which allows for many
    different types of date representations, such as 2008/01/02 or 02JAN2008. */
try_numeric:; 
     if text='-' then numcol{i}=.; 
     else numcol{i}=input(text,?? best32.); 
     return;
try_date:;
     numcol{i}=input(text,?? anydtdte32.); 
     return;
     run;
filename labstmts clear;

*-----recreate the data set with the changes-----*;
data table&tablenum.; set table&tablenum.(&drops &renames); 
     &dates; 
     run; 

*-----print the resultant table-----*; 
options nocenter;
proc print data=table&tablenum. label; title "table&tablenum."; run;
%mend readtable; 


*-----the URL as given in the example-----*; 
%if "%substr(&url,2,5)"="http:" or "%substr(&url,2,6)"="https:" %then %do; 
filename urltext url &url. &proxyinfo ; 
%end; 
%else %do; 
filename urltext &url. encoding=ascii; 
%end; 

 /* This step makes a local copy of the URL contents into a temporary file. 
    This makes random access of the file simpler, and also gives us an 
    opportunity to find the total size of the file to use that value in a 
    subsequent LRECL= option. Also, we can upcase all the tags (anything between
    < and blank or >) so that we can accept any casing combination. */

filename myfile temp; 
data _null_; infile urltext recfm=f lrecl=1 end=eof; file myfile recfm=f lrecl=1; 
     retain upcase 0;
     input @1 x $char1.; 
     if x='<' then upcase=1; 
     else if upcase and (x=' ' or x='>') then upcase=0; 
     if upcase then x=upcase(x); 
     put @1 x $char1.; 
     if eof; 
     call symput('filesize',trim(left(put(_n_,best12.)))); 
     run;

 /* This code will make several passes through the file, looking for certain
    tags. First it looks for <table, then <TABLE, then </table, then </TABLE. 
    HTML does not have case-sensitive tags, and any of these are possible.
    It is expected that an end tag (e.g. </table) will be found since otherwise
    all tables are nested inside each other. We have to look for both 'TABLE' and
    'table' since the subsequent use of input @'...' requires the proper casing. 
    Note that the subsequent code expects that all the tags of the same type 
    (table, tr, td) using consistent casing throughout. This code will look for 
    <tr and <TR tags, and also <td and <TD tags and output observations for each.
    Note that the output observations always upcase the tags, but the column 
    number is saved as well. CLOSETAGS will be Y if 
    end tags are found for TR and TD. NOBS is the number of observations emitted
    and NTABLES is the number of TABLE tags found. */

data detail(keep=text col); 
     infile myfile recfm=f lrecl=&filesize. column=c missover;
     array which{3}    $8 _temporary_ ('TABLE','TR','TD'); 
     array whichsrc{3} $8 _temporary_; 
     length tag $8; 
     closetags='N'; 
     failure=0;
     do i=1 to 3; 
        tag='<'||which{i};  link readfile; n_upper_open  = obscount; 
        tag='</'||which{i}; link readfile; n_upper_close = obscount; 
        nobs+n_upper_open+n_upper_close;
        if which{i}^='TABLE' and n_upper_close>0 then closetags='Y'; 
        if which{i}='TABLE' then do; 
           ntables=n_upper_open;
           if ntables=0 then do; 
              put 'ERROR: There are no tables defined in the HTML.'; 
              failure=1;
              end;
           else if n_upper_close=0 then do; 
              put 'ERROR: There are no closing tags for tables in the HTML.'; 
              failure=1;
              end;
           end;
        whichsrc{i}=which{i}; 
        if n_upper_open>0 then whichsrc{i}=upcase(whichsrc{i}); 
        end;
     call symput('closetags',closetags); 
     call symput('nobs',     cats(nobs)); 
     call symput('ntables',  cats(ntables));
     if failure then abort; 
     return;

 /* This link routine will run through the entire file looking for the tag. 
    Note that the @(TRIM(TAG)) feature is used here, allowing for an expression
    to be used. This is necessary since tag may have trailing blanks that we 
    don't want to be searching for. Note also that if we hit the end of file 
    (actually end of record since there is one total record in the file), the 
    column value will exceed the record size, indicating to us that we have 
    hit end of record, so we can then leave the loop. */

readfile:; 
     obscount=0;
     text=tag;
     input @1 @; 
     do while(1); 
        input @(trim(tag)) @; 
        if c>&filesize then leave; 
        col=c;
        obscount+1;
        output;
        end;
     return;
     run;

*-----we want the obs in order of appearance in the file-----*; 
proc sort data=detail; by col; run;

 /* This is the code that will determine how many rows and cols there are for each table.
    The %READTABLE macro will be invoked for each table based on that info so that the 
    tablen data set can be created. This is done by first populating the taglist and 
    tagstart arrays with the data from the detail data set. The tagend array elements 
    are set based on the location of the endtags. We can then examine each <tr tag 
    and determine which table it is in. This is done by searching through the 
    tablestart/tableend array to find a column range that contains the <tr tag location.
    Note that multiple tables can contain this <tr tag, (if a table is defined within 
    another table), so we look for the surrounding table that is the smallest. Once
    we know the proper table, we increment the row count. And any <td tags encountered
    will cause an incrementation of column count for the same table. Note that the 
    column count is reset to 0 for each row and re-incremented since some rows may 
    not contain all columns. */

filename sascode temp;      
data _null_; 
     array taglist{&nobs} $8 _temporary_;      * tag text; 
     array tagstart{&nobs} _temporary_;        * start loc for the tag; 
     array tagend{&nobs} _temporary_;          * end loc for the tag; 
     array tablestart{&ntables} _temporary_;   * start loc for each table; 
     array tableend  {&ntables} _temporary_;   * end loc for each table; 
     array tablenrows{&ntables} _temporary_;   * no. of rows in the table; 
     array tablencols{&ntables} _temporary_;   * no. of cols in the table;
    
     *-----populate the arrays from the detail data set-----*; 
     do i=1 to &nobs; 
        set detail point=i; 
        taglist{i}=text; 
        tagstart{i}=col; 
        end;

     *-----determine the end location for each tag if endtags given-----*; 
     do i=1 to &nobs; 
        if taglist{i}=:'</' then do j=i-1 to 1 by -1; 
           if substr(taglist{j},2)=substr(taglist{i},3) then do; 
              tagend{j}=tagstart{i}-length(taglist{i}); 
              leave; 
              end;
           end;
        end;

     *-----set the table start/end arrays-----*; 
     j=0;
     do i=1 to &nobs; 
        if taglist{i}='<TABLE' then do; 
           j+1; 
           tablestart{j}=tagstart{i}; 
           tableend{j}=tagend{i}; 
           end;
        end; 

     jj=0;
     do i=1 to &nobs; 

        *-----find smallest table containing each <tr tag-----*; 
        if taglist{i}='<TR' then do; 
           minsize=1e10; 
           do j=1 to &ntables; 
              if tablestart{j}<=tagstart{i}<=tableend{j} then do; 
                 size=tableend{j}-tablestart{j}+1; 
                 if size<minsize then do; 
                    jj=j; 
                    minsize=size; 
                    end;
                 end;
              end;
           if jj>0 then do;
              tablenrows{jj}+1; 
              end;
           ncols=0; 
           end;

        *-----increment column count for the <td tags-----*; 
        else if jj>0 and taglist{i}='<TD' then do; 
           ncols+1; 
           tablencols{jj}=max(tablencols{jj},ncols); 
           end;
        end;

     *-----determine if there is overlap (which would be a problem)-----*; 
     overlap=0;
     do i=1 to &ntables; 
        if i>1 and tableend{i-1}>tablestart{i} then overlap=1;
        else if i<&ntables and tablestart{i+1} < tableend{i} then overlap=1; 
        end;        

     /* Note that we can't use call execute here since the macro variables created via
        SYMPUT in %readtable would not then be known to the macro. If instead we invoke
        the macro directly in %INCLUDED code, we don't have the problem. */
        
     *-----invoke the readtable macro for each table having rows and columns-----*; 
     file sascode; 
     do i=1 to &ntables; 
        if tablestart{i}>0 and tableend{i}>0 and tablenrows{i}>0 and tablencols{i}>0 then do;
           args=catx(',',i,tablestart{i},tableend{i},tablenrows{i},tablencols{i}); 
           put '%readtable(' args ');';
           end;
        end;        
      
     stop; 
     run;

*-----done with detail now, so it can be deleted-----*; 
proc delete data=detail; run;

*-----invoke the generated code that calls the readtable macro-----*; 
%include sascode/source2; run;
filename sascode clear; 

%mend readhtml2; 

/* Note that 

%let proxyinfo=; 

must be used, or set it if a proxy is needed. 
*/

/*

*-----sample invocations of the macro-----*; 
%readhtml2('http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html',row1_is_labels=yes); 
%readhtml2('http://biz.yahoo.com/research/earncal/20080529.html');

*-----in-house links that will not work externally-----*;

%readhtml2('http://sww.sas.com/cgi-bin/broker?ID=LANGSTON%2C+R.&REL=d2indb12&sortvar=npriority&sortdir=&_service=defects&_program=src.run_report.sas&run_as=query&SOURCE=%2Fu%2Fdsid2%2F.defects%2Freports%2Fdefdatas_supportid.sas&submit=Submit+Query'); 
%readhtml2('http://sww.sas.com/uvr/unx_srcmgt/build_cts_machines.html'); 

%readhtml2('http://www.creggercompany.com/locations.html'); 
*/

%let proxyinfo=;

/*
%readhtml2('https://developers.arcgis.com/javascript/3/jshelp/gcs.htm',row1_is_labels=yes); 

proc print label data=_last_(obs=3); run;
*/
