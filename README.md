## add_data_file
### This procedure automatically adds tablespace to database in case of low storage.
#### instructions:
اتوماتیک سازی اضافه کردن datafile به tablespace ها

در محیط بانک ها از آنجایی که همیشه دسترسی به سرور نداریم و ممکن است در ادامه ی تحویل سامانه به مشتری چک کردن مداوم دیتافایل ها و فضای سرور دیتابیس یک چالش باشد. به همین جهت این فرایند می تواند کمک کند تا در صورت کمبود فضا در tablespace ها بتوانیم به طور اتوماتیک دیتافایل اضافه کنیم تا به مشکلاتی نظیر failed شدن جاب به علت پر شدن tablespace ها برنخوریم.
به این منظور ابتدا باید فضای os را چک کنیم برای این کار از داخل یک پراسیجر plsql ابتدا نیاز به یک external table داریم که با یک preprocessor که در اینجا یک script است که حجم خالی os را خروجی میدهد نتیجه را خوانده و به ما نمایش می دهد. برای این کار نیاز است یک directory بسازیم (اگر از قبل یک دایرکتوری ساخته ایم نیازی به این کار نیست) و سپس فایل df.sh و فایل df.dat را در داریرکتوری مورد نظر قرار میدهیم و با دستور 

Chmod 777 ‘/directory path/df.sh’
دسترسی اجرا شدن این فایل را میدهیم.
سپس با دستور زیر یک external table می سازیم :

CREATE TABLE df
  (
     available_bytes VARCHAR2(100)
  )
organization external ( TYPE oracle_loader DEFAULT directory directory ACCESS
                      parameters ( records
                      delimited BY newline nobadfile nologfile preprocessor
                      directory :'df.sh' ) location('df.dat') ); 

 


که directory که در بالا به رنگ قرمز میباشد نام دایکتوری ای است که ساخته ایم و df.sh در آن قرار دارد.
بعد از ساخت جدول فوق به سادگی با دستور 
Select * from df
میتوانیم مقدار فضای خالی os را ببینیم.

سپس prc_add_datafile را کامپایل می کنیم. این پراسیجر با چک کردن حجم os و سپس چک کردن حجم tablespace ها در صورتی که کمتر از دو گیگ فضای خالی در یک tablespace داشته باشیم دو datafile به آن tablespace اضافه می شود.
در کد برای انتهای نام دیتافایل ها از یک sequence استفاده شده است که می توانید در صورت لزوم sequence مورد نظر خود را بسازید تا شماره های دلخواه شما را تولید کند.

توضیحات تکمیلی:

محتویات فایل df.sh به صورت زیر می باشد:

#! /bin/bash
/bin/df -m /usr | /bin/awk 'NR==2 {print $4}'

البته کد بالا فضای خالی root را نشان می دهد در صورتی که دیتافایل هایتان در دایرکتوری دیگری به جز root قرار دارد به جای /usr که در خط بالا قرمز شده است مسیر اصلی دیتافایل ها را قرار می دهیم.
فایل df.dat هم به صورت زیر است:
/usr

که باز هم در صورتی که مسیر متفاوت است مسیر خودمان را قرار می دهیم.

