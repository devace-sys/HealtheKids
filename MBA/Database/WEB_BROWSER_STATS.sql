USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WEB_BROWSER_STATS]'))
DROP VIEW [dbo].[WEB_BROWSER_STATS]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE VIEW [dbo].[WEB_BROWSER_STATS] AS

select  

 /*============================================================
  * Logged request data
  *============================================================*/ 

 id,                 
 LoggedOn,           /* Login request date and time */
 UserIP,             /* IP address of request */
 UserAgent,          /* User agent string */
 
 /*============================================================
  * OS Common Name
  *============================================================*/  
 
 [OSName] =

   case

     /*-------------------------------    
      * Windows (latest to earliest)
      *------------------------------*/  
     
     when UserAgent like '%windows nt 6.3%'      then 'Windows 8.1'
     when UserAgent like '%windows nt 6.2%'      then 'Windows 8'
     when UserAgent like '%windows nt 6.1%'      then 'Windows 7'
     when UserAgent like '%windows nt 6.0%'      then 'Windows Vista'
     when UserAgent like '%windows nt 5.2%'      then 'Windows 2003'
     when UserAgent like '%windows nt 5.1%'      then 'Windows XP *'
     when UserAgent like '%windows nt 5.0%'      then 'Windows 2000 *'
     when UserAgent like '%windows nt 4.0%'      then 'Windows NT 4.0 *'
     when UserAgent like '%windows 98; win 9x%'  then 'Windows ME *'
     when UserAgent like '%windows 98'           then 'Windows 98 *'
     when UserAgent like '%windows 95'           then 'Windows 95 *'
     when UserAgent like '%windows CE'           then 'Windows CE *'
     when UserAgent like '%windows%'             then 'Windows'
     
     /*-------------------------------    
      * iOS (latest to earliest)
      *------------------------------*/  

     when UserAgent like '%ipad; cpu os 7%'  then 'iOS 7'
     when UserAgent like '%ipad; cpu os 6%'  then 'iOS 6'
     when UserAgent like '%ipad; cpu os 5%'  then 'iOS 5'
     when UserAgent like '%ipad; cpu os 4%'  then 'iOS 4'     
     when UserAgent like '%ipad%'            then 'iOS'
     when UserAgent like '%iphone%'          then 'iOS'     
     when UserAgent like '%crios%'           then 'iOS'     
     
     /*-------------------------------    
      * OS X (latest to earliest)
      *------------------------------*/  
     
     when UserAgent like '%os x 10_9%'       then 'OS X Mavericks'
     when UserAgent like '%os x 10_8%'       then 'OS X Mountain Lion'
     when UserAgent like '%os x 10_7%'       then 'OS X Lion'
     when UserAgent like '%os x 10_6%'       then 'OS X Snow Leopard'
     when UserAgent like '%os x 10_5%'       then 'OS X Leopard *'
     when UserAgent like '%os x 10_4%'       then 'OS X Tiger *'
     when UserAgent like '%os x 10_3%'       then 'OS X Panther *'
     when UserAgent like '%os x 10_2%'       then 'OS X Jaguar *'
     when UserAgent like '%os x 10_1%'       then 'OS X Puma *'
     when UserAgent like '%os x 10_0%'       then 'OS X Cheetah *'    
     when UserAgent like '%os x%'            then 'OS X'
     when UserAgent like '%macintosh%'       then 'Mac OS *'
     
     /*-------------------------------    
      * Android and Chrome OS
      *------------------------------*/  

     when UserAgent like '%android%'         then 'Android'     
     when UserAgent like '%cros%'            then 'Chrome OS'
     
     /*-------------------------------    
      * Linux
      *------------------------------*/  
     
     when UserAgent like '%linux%'           then 'Linux'

     /*-------------------------------    
      * Not detected
      *------------------------------*/  

     else null
   
   end,
 
 /*============================================================
  * Browser Common Name
  *============================================================*/  

 [BrowserName] =
   case
   
     /*-------------------------------    
      * IE 7 to 11
      *------------------------------*/  
     when UserAgent like '%trident/7.0%' then 'IE 11'
     when UserAgent like '%msie 10%'     then 'IE 10'
     when UserAgent like '%msie 9%'      then 'IE 9'
     when UserAgent like '%msie 8%'      then 'IE 8'
     when UserAgent like '%msie 7%'      then 'IE 7'
     when UserAgent like '%msie 6%'      then 'IE 6'
     when UserAgent like '%msie 5.5%'    then 'IE 5.5 *'
     when UserAgent like '%msie 5%'      then 'IE 5 *'
     when UserAgent like '%msie'         then 'IE *'
          
     /*-------------------------------    
      * Firefox 4+
      *------------------------------*/  

     when UserAgent like '%firefox%' then
       REPLACE(SUBSTRING(UserAgent,
         PATINDEX('%Firefox%',UserAgent), 100),'/', ' ')      
     
     /*-------------------------------    
      * Chrome
      *------------------------------*/  

     when UserAgent like '%chrome%' then 
       REPLACE(SUBSTRING(UserAgent,
         PATINDEX('%Chrome%',UserAgent), 
           PATINDEX('%Safari%',UserAgent) -
             PATINDEX('%Chrome%',UserAgent)),'/', ' ')      
          
     when UserAgent like '%crios%' then
       REPLACE(
         REPLACE(SUBSTRING(UserAgent,
           PATINDEX('%crios%',UserAgent), 
            PATINDEX('%safari%',UserAgent) -
              PATINDEX('%mobile%',UserAgent)),'/', ' '),
                'crios','Chrome')
          
     /*-------------------------------    
      * Safari
      *------------------------------*/  
     
     when UserAgent like '%safari%'      then     
       'Safari ' + REPLACE(SUBSTRING(UserAgent,
         PATINDEX('%Version%',UserAgent),
           PATINDEX('%Safari%',UserAgent)-
             PATINDEX('%Version%',UserAgent)),'Version/', '')     

     /*-------------------------------    
      * Undetected
      *------------------------------*/  
     
     else null
   end,  
 
  /*============================================================
   * Logged response data
   *============================================================*/ 

 UserID, /* User ID if the user was able to login successfully */
 Token  /* Security token issues*/

from users.dbo.WEB_BROWSER_LOG

GO