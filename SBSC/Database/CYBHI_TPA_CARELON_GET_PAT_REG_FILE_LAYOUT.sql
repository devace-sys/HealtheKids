USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT
GO

/*-------------------------------
 * Create UDF
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT] ( 
    @fileClass tinyint = -1 
)
       
returns @layout table (
    fieldNum   int
  , fieldName  varchar(512)
  , size       int
  , startPos   int
  , endPos     int 
  , visible    bit
  , padRight   bit default(1)
)
AS     
BEGIN

/* 
 * 0 = Submission/Base
 * 1 = Return Accept : CARELON-RA 
 * 2 = Return Error : CARELON-RE
 * 3 = Pendable (TODO)
 * 4 = Pended   (TODO)
 */

if (@fileClass not in (0,1,2,3)) return

/* Put base fields in */

insert into @layout(
    fieldNum        
  , fieldName  
  , size       
  , startPos   
  , endPos     
  , visible    
)
values
 (1,'Record Number',7,1,7,1)
,(2,'Carelon PARENT Code',4,8,11,1)
,(3,'Submitter ID',10,12,21,1)
,(4,'Registering Provider ID',15,22,36,1)
,(5,'Enrollment Indicator',1,37,37,1)
,(6,'Enrollment Start Date',8,38,45,1)
,(7,'Enrollment Termination Date',8,46,53,1)
,(8,'Carelon Assigned Member ID',15,54,68,1)
,(9,'Student ID',15,69,83,1)
,(10,'Medicaid ID',15,84,98,0)
,(11,'Medicare ID',15,99,113,0)
,(12,'Social Security Number Indicator',1,114,114,0)
,(13,'Social Security Number',9,115,123,0)
,(14,'Alien Registration ID',9,124,132,0)
,(15,'VISA ID',8,133,140,0)
,(16,'Last Name',60,141,200,1)
,(17,'Birth Surname',60,201,260,0)
,(18,'First Name',35,261,295,1)
,(19,'Middle Initial',1,296,296,1)
,(20,'Name Suffix',3,297,299,0)
,(21,'Preferred First Name',25,300,324,0)
,(22,'Pronouns',4,325,328,0)
,(23,'Pronouns Other',25,329,353,0)
,(24,'Birth Date',8,354,361,1)
,(25,'Unknown Address',1,362,362,1)
,(26,'Member is Homeless',1,363,363,1)
,(27,'Street Address Line 1',55,364,418,1)
,(28,'Street Address Line 2',55,419,473,0)
,(29,'City',30,474,503,1)
,(30,'State',2,504,505,1)
,(31,'Zip Code',5,506,510,1)
,(32,'Zip Code Extension',4,511,514,0)
,(33,'Members County',3,515,517,0)
,(34,'Individual Email Address',100,518,617,0)
,(35,'No Phone',1,618,618,1)
,(36,'Home Phone Area Code',3,619,621,1)
,(37,'Home Phone Exchange Number',3,622,624,1)
,(38,'Home Phone Suffix',4,625,628,1)
,(39,'Cell Phone Area Code',3,629,631,1)
,(40,'Cell Phone Exchange Number',3,632,634,1)
,(41,'Cell Phone Suffix',4,635,638,1)
,(42,'Verbal Preference',1,639,639,0)
,(43,'Interpreter Services Needed',1,640,640,0)
,(44,'Speaking Language',4,641,644,0)
,(45,'Speaking Language Other',25,645,669,0)
,(46,'Written Language',4,670,673,0)
,(47,'Written Language Other',25,674,698,0)
,(48,'Gender At Birth',1,699,699,1)
,(49,'Gender Identity',4,700,703,0)
,(50,'Gender Identity Other',25,704,728,0)
,(51,'Race Code 1',4,729,732,0)
,(52,'Race Code 2',4,733,736,0)
,(53,'Race Code 3',4,737,740,0)
,(54,'Race Code Other',25,741,765,0)
,(55,'Hispanic Or Latino Origin',4,766,769,0)
,(56,'Marital Status',1,770,770,0)
,(57,'Sexual Orientation Status',4,771,774,0)
,(58,'Sexual Orientation Status Other',25,775,799,0)
,(59,'Housing Status',4,800,803,0)
,(60,'Disability Status 1',4,804,807,0)
,(61,'Disability Status 2',4,808,811,0)
,(62,'Disability Status 3',4,812,815,0)
,(63,'Disability Status Other',25,816,840,0)
,(64,'Filler Field 1',1,841,841,0)
,(65,'Filler Field 2',1,842,842,0)
,(66,'Filler Field 3',1,843,843,0)
,(67,'Filler Field 4',1,844,844,0)
,(68,'Insurance Carrier Code 1',3,845,847,1)
,(69,'Filler Field 5',50,848,897,0)
,(70,'Insurance Policy Member ID 1',30,898,927,1)
,(71,'Insurance Subscriber First Name 1',35,928,962,1)
,(72,'Insurance Subscriber Last Name 1',60,963,1022,1)
,(73,'Insurance Primacy Indicator 1',1,1023,1023,1)
,(74,'Insurance Group Number 1',30,1024,1053,1)
,(75,'Insurance Address Line 1 1',55,1054,1108,0)
,(76,'Insurance Address Line 2 1',55,1109,1163,0)
,(77,'Insurance City 1',30,1164,1193,0)
,(78,'Insurance State 1',2,1194,1195,0)
,(79,'Insurance Zip 1',10,1196,1205,0)
,(80,'Insurance Phone 1',10,1206,1215,0)
,(81,'Insurance Effective Date 1',8,1216,1223,0)
,(82,'Insurance Expiration Date 1',8,1224,1231,0)
,(83,'Insurance Carrier Code 2',3,1232,1234,1)
,(84,'Filler Field 6',50,1235,1284,0)
,(85,'Insurance Policy Member ID 2',30,1285,1314,1)
,(86,'Insurance Subscriber First Name 2',35,1315,1349,1)
,(87,'Insurance Subscriber Last Name 2',60,1350,1409,1)
,(88,'Insurance Primacy Indicator 2',1,1410,1410,1)
,(89,'Insurance Group Number 2',30,1411,1440,1)
,(90,'Insurance Address Line 1 2',55,1441,1495,0)
,(91,'Insurance Address Line 2 2',55,1496,1550,0)
,(92,'Insurance City 2',30,1551,1580,0)
,(93,'Insurance State 2',2,1581,1582,0)
,(94,'Insurance Zip 2',10,1583,1592,0)
,(95,'Insurance Phone 2',10,1593,1602,0)
,(96,'Insurance Effective Date 2',8,1603,1610,0)
,(97,'Insurance Expiration Date 2',8,1611,1618,0)
,(98,'Insurance Carrier Code 3',3,1619,1621,0)
,(99,'Filler Field 7',50,1622,1671,0)
,(100,'Insurance Policy Member ID 3',30,1672,1701,0)
,(101,'Insurance Subscriber First Name 3',35,1702,1736,0)
,(102,'Insurance Subscriber Last Name 3',60,1737,1796,0)
,(103,'Insurance Primacy Indicator 3',1,1797,1797,0)
,(104,'Insurance Group Number 3',30,1798,1827,0)
,(105,'Insurance Address Line 1 3',55,1828,1882,0)
,(106,'Insurance Address Line 2 3',55,1883,1937,0)
,(107,'Insurance City 3',30,1938,1967,0)
,(108,'Insurance State 3',2,1968,1969,0)
,(109,'Insurance Zip 3',10,1970,1979,0)
,(110,'Insurance Phone 3',10,1980,1989,0)
,(111,'Insurance Effective Date 3',8,1990,1997,0)
,(112,'Insurance Expiration Date 3',8,1998,2005,0)
,(113,'Insurance Carrier Code 4',3,2006,2008,0)
,(114,'Filler Field 8',50,2009,2058,0)
,(115,'Insurance Policy Member ID 4',30,2059,2088,0)
,(116,'Insurance Subscriber First Name 4',35,2089,2123,0)
,(117,'Insurance Subscriber Last Name 4',60,2124,2183,0)
,(118,'Insurance Primacy Indicator 4',1,2184,2184,0)
,(119,'Insurance Group Number 4',30,2185,2214,0)
,(120,'Insurance Address Line 1 4',55,2215,2269,0)
,(121,'Insurance Address Line 2 4',55,2270,2324,0)
,(122,'Insurance City 4',30,2325,2354,0)
,(123,'Insurance State 4',2,2355,2356,0)
,(124,'Insurance Zip 4',10,2357,2366,0)
,(125,'Insurance Phone 4',10,2367,2376,0)
,(126,'Insurance Effective Date 4',8,2377,2384,0)
,(127,'Insurance Expiration Date 4',8,2385,2392,0)
,(128,'Insurance Carrier Code 5',3,2393,2395,0)
,(129,'Filler Field 9',50,2396,2445,0)
,(130,'Insurance Policy Member ID 5',30,2446,2475,0)
,(131,'Insurance Subscriber First Name 5',35,2476,2510,0)
,(132,'Insurance Subscriber Last Name 5',60,2511,2570,0)
,(133,'Insurance Primacy Indicator 5',1,2571,2571,0)
,(134,'Insurance Group Number 5',30,2572,2601,0)
,(135,'Insurance Address Line 1 5',55,2602,2656,0)
,(136,'Insurance Address Line 2 5',55,2657,2711,0)
,(137,'Insurance City 5',30,2712,2741,0)
,(138,'Insurance State 5',2,2742,2743,0)
,(139,'Insurance Zip 5',10,2744,2753,0)
,(140,'Insurance Phone 5',10,2754,2763,0)
,(141,'Insurance Effective Date 5',8,2764,2771,0)
,(142,'Insurance Expiration Date 5',8,2772,2779,0)
,(143,'Parent or Guardian Relationship',4,2780,2783,0)
,(144,'Parent or Guardian Relationship Other',25,2784,2808,0)
,(145,'Parent or Guardian Spoken Language',4,2809,2812,0)
,(146,'Parent or Guardian Spoken Language Other',25,2813,2837,0)
,(147,'Parent or Guardian Last Name',60,2838,2897,0)
,(148,'Parent or Guardian First Name',35,2898,2932,0)
,(149,'Parent or Guardian Address Line 1',55,2933,2987,0)
,(150,'Parent or Guardian Address Line 2',55,2988,3042,0)
,(151,'Parent or Guardian City',30,3043,3072,0)
,(152,'Parent or Guardian State',2,3073,3074,0)
,(153,'Parent or Guardian Zip Code',5,3075,3079,0)
,(154,'Parent or Guardian Zip Code Extension',4,3080,3083,0)
,(155,'Parent or Guardian Home Phone Area Code',3,3084,3086,0)
,(156,'Parent or Guardian Home Phone Exchange',3,3087,3089,0)
,(157,'Parent or Guardian Home Phone Suffix',4,3090,3093,0)
,(158,'Parent or Guardian Cell Phone Area Code',3,3094,3096,0)
,(159,'Parent or Guardian Cell Phone Exchange',3,3097,3099,0)
,(160,'Parent or Guardian Cell Phone Suffix',4,3100,3103,0)
,(161,'Parent or Guardian Email address',100,3104,3203,0)
,(162,'Parent or Guardian Verbal Preference',1,3204,3204,0)
,(163,'CDS Code',14,3205,3218,0)
,(164,'Federal District ID',7,3219,3225,0)
,(165,'Federal School ID',5,3226,3230,0)
,(166,'District Type',4,3231,3234,0)
,(167,'Federal Charter District ID',7,3235,3241,0)
,(168,'School County',4,3242,3245,0)
,(169,'District or Administrative Authority name',50,3246,3295,0)

/* Base - Submission */

if (@fileClass = 0) return

/* CARELON-RA */

if (@fileClass = 1)
begin

 insert into @layout (
      fieldNum        
    , fieldName  
    , size       
    , startPos   
    , endPos     
    , visible    
  )
  
  values
   (170,'Upload Status',1,3296,3296,1)
  ,(171,'Batch Date',7,3297,3303,1)
  ,(172,'Batch Sequence',5,3304,3308,1)
  ,(173,'Sequence Number',5,3309,3313,1)
  ,(174,'MRA Sequence Number',5,3314,3318,1)
  ,(175,'Member Number or Temp ID',15,3319,3333,1)
  ,(176,'Funding Source',4,3334,3337,1)
  ,(177,'Registration Start Date',8,3338,3345,1)
  ,(178,'Registration End Date',8,3346,3353,1)
  ,(179,'Registration Code',3,3354,3356,1)
  ,(180,'Registration Comments',100,3357,3456,1)

end

else if (@fileClass = 2)
begin
 insert into @layout (
      fieldNum        
    , fieldName  
    , size       
    , startPos   
    , endPos     
    , visible    
  )  
  values
   (170,'Upload Status',1,3296,3296,1)
  ,(171,'Error Code',3,3297,3299,1)
  ,(172,'Error Description',100,3300,3399,1)
end

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT] TO [webuser]
GO

