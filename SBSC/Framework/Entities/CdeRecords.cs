using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;
using Geo;
using Geo.CDE;

namespace Spedmon
{    
  
  public class CdeRecordCounty
  {
    public string CdsCode;
    public string CountyCode;
    public string CountyName;
  }
  
  public class CdeRecordDistrict:CdeRecordCounty
  {
    public string DistrictCode;
    public string DistrictName;    
  }
  
  public class CdeRecordSchool:CdeRecordDistrict
  {
    public string SchoolCode;
    public string SchoolName;
  }
  
  public class CdeCurrentSite 
  {
    public string     County;
    public string     District;
    public string     School;
    public string     CDSCode;
    public string     CDSCodeCounty;
    public string     CDSCodeDistrict;
    public string     CDSCodeSite;
    public string     CDSCodeFirst7;
    public string     CDSCodeLast7;
    public string     Website;
    public string     Phone;
    public string     Street;
    public string     City;
    public string     State;
    public string     Zip;
    public string     Zip5;
    public string     Zip4;
    public string     DataSource;
    public DateTime?	LastUpdate;
    public bool?      HasAddressData;
    public bool?      HasCDSCode;
    public int        LastUpdateDaysAgo;
  }
  
  /***************************************************************************
   * ReturnCdeCurrentSite */
  /**
   * Returns a current site record
   ****************************************************************************/
 
  public class ReturnCdeCurrentSite:Return
  {
    public ReturnCdeCurrentSite ()                 : base(){}
    public ReturnCdeCurrentSite (string msg)       : base(msg){}
    public ReturnCdeCurrentSite (Exception e)      : base(e){}
    public ReturnCdeCurrentSite (Warning e)        : base(e){}
    public ReturnCdeCurrentSite (Critical e)       : base(e){}  
    public ReturnCdeCurrentSite (SessionExpired e) : base(e){}
    
    public CdeCurrentSite site;   
    public Geo.CDE.SchoolDirectoryEntry directoryEntry;
   
  }

  /***************************************************************************
   * CdeRecords */
  /**
   * Request for list of cde records
   ****************************************************************************/

  public class CdeRecords
  {
        
    /***************************************************************************
     * viewCurrentSites */
    /**
     * List of current sites
     ****************************************************************************/

    public static ReturnDB viewCurrentSites (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string   term
                                              , string   cdsCode )
    {

      ReturnDB rd = new ReturnDB();
      
      Object vTerm    = Validate.optString(term);
      Object vCDSCode = Validate.optString(cdsCode);
      
      string sql = @"select * from dbo.CDE_SCHOOLS_SITES_CURRENT_VIEW(@term,@cdsCode)";

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar, vTerm,         ParameterDirection.Input,255));
      parms.Add(Database.SqlParm("@cdsCode",   SqlDbType.VarChar, vCDSCode,      ParameterDirection.Input,14));
      
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }                                                             
                                            
    /***************************************************************************
     * loadCurrentSite */
    /**
     *
     ****************************************************************************/

    public static CdeCurrentSite loadCurrentSite (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo                                         
                                                   , string        cdsCode )
    {
      CdeCurrentSite site = new CdeCurrentSite();
      
      string    vCdsCode = Validate.reqString (cdsCode,@"CDS code is required");
      string    cds      = Geo.Common.CleanStringNumericCodeValueOut (vCdsCode);       
      ReturnDB  rd       = viewCurrentSites ( connSpedmon, log , uInfo , null, cds);            
      if (!rd.hasRecords) throw new Warning(Messages.RECORD_NOT_FOUND);      
      site = (CdeCurrentSite) Database.convertRecord(rd.records,typeof(CdeCurrentSite));
      return site;
    }                                                     
    
    /***************************************************************************
     * convertCdeCurrentSiteToSchoolDirectoryEntry */
    /**
     *
     ****************************************************************************/

    public static void convertCdeCurrentSiteToSchoolDirectoryEntry (  CdeCurrentSite           site
                                                                    , out SchoolDirectoryEntry directoryEntry )
    {                      
      directoryEntry = new SchoolDirectoryEntry();
      
      directoryEntry.CountyName      = site.County;
      directoryEntry.DistrictName    = site.District;
      directoryEntry.SchoolName      = site.School;
      directoryEntry.CdsCode         = site.CDSCode;
      directoryEntry.CdsCodeCounty   = site.CDSCodeCounty;
      directoryEntry.CdsCodeDistrict = site.CDSCodeDistrict;
      directoryEntry.CdsCodeSite     = site.CDSCodeSite;
      directoryEntry.CdsCodeFirst7   = site.CDSCodeFirst7;
      directoryEntry.CdsCodeLast7    = site.CDSCodeLast7;
      
      directoryEntry.StreetAddress = new Geo.USPS.Address(   site.Street
                                                           , ""
                                                           , site.City
                                                           , site.State
                                                           , site.Zip5
                                                           , site.Zip4);     
    }                                                     
    
    /***************************************************************************
     * retrieveCdeCurrentSite */
    /**
     * Retrieve current site
     ****************************************************************************/

    public static ReturnCdeCurrentSite retrieveCdeCurrentSite (  SqlConnection connSpedmon
                                                               , DetailsLog    log
                                                               , UserInfo      uInfo                                         
                                                               , string        cdsCode )
    {   
      ReturnCdeCurrentSite so = new ReturnCdeCurrentSite();
      CdeCurrentSite       site = loadCurrentSite(connSpedmon,log,uInfo,cdsCode);
      SchoolDirectoryEntry directoryEntry;
      convertCdeCurrentSiteToSchoolDirectoryEntry(site, out directoryEntry);
      so.directoryEntry = directoryEntry;      
      return so;                                    
    }
    
    /***************************************************************************
     * viewCounties */
    /**
     * List of counties
     ****************************************************************************/

    public static ReturnDB viewCounties (  SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string countyCode
                                         , string term)
    {
      ReturnDB rd = new ReturnDB();
      
      Object vCountyCode   = Validate.optString(countyCode);       
      Object vTerm         = Validate.optString(term);
      
      string sql = @"select * from dbo.CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW(@CountyCode,@term)";
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@CountyCode",   SqlDbType.VarChar, vCountyCode,   ParameterDirection.Input,2));
      parms.Add(Database.SqlParm("@term",         SqlDbType.VarChar, vTerm,         ParameterDirection.Input,255));
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }
    
    /***************************************************************************
     * viewCountiesNamesValues */
    /**
     * List of counties
     ****************************************************************************/
        
    public static ReturnNamesValues viewCountiesNamesValues (  SqlConnection connSpedmon
                                                             , DetailsLog log
                                                             , UserInfo uInfo
                                                             , string term
                                                             )
    {
      ReturnNamesValues r = new ReturnNamesValues();
      ReturnDB rd = viewCounties(connSpedmon, log, uInfo, null, term);
      r = Database.convertReturnDBToReturnNamesValues(ref rd);
      return r;
    }
    
    /***************************************************************************
     * viewCountiesList */
    /**
     * List of counties
     ****************************************************************************/
       
    public static List<CdeRecordCounty> viewCountiesList (  SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , string countyCode
                                     , string term
                                    )
    {
      List<CdeRecordCounty> rl = new List<CdeRecordCounty>();
      ReturnDB rd = viewCounties(connSpedmon, log, uInfo, countyCode, term);
      Object[] ol = Database.convertRecords(rd.records, typeof(CdeRecordCounty));
      foreach (Object o in ol)
      {
        CdeRecordCounty r = (CdeRecordCounty)o;
        rl.Add(r);
      }
      return rl;
    }
    
   /***************************************************************************
     * viewDistricts */
    /**
     * List of districts
     ****************************************************************************/

    public static ReturnDB viewDistricts (  SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string countyCode
                                          , string districtCode
                                          , string term )
      {
        ReturnDB rd = new ReturnDB();
        
        Object vCountyCode   = Validate.optString(countyCode);
        Object vDistrictCode = Validate.optString(districtCode);
        Object vTerm         = Validate.optString(term);
        
        string sql = @"select * from dbo.CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW(@CountyCode,@DistrictCode,@term)";
        
        List<SqlParameter> parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@CountyCode",   SqlDbType.VarChar, vCountyCode,   ParameterDirection.Input,2));
        parms.Add(Database.SqlParm("@DistrictCode", SqlDbType.VarChar, vDistrictCode, ParameterDirection.Input,5));
        parms.Add(Database.SqlParm("@term",         SqlDbType.VarChar, vTerm,         ParameterDirection.Input,255));

        rd = Database.execQuery(connSpedmon, log, sql, false, parms);
        return rd;
      }
                               
    /***************************************************************************
     * viewDistrictsNamesValues */
    /**
     * List of counties
     ****************************************************************************/
        
    public static ReturnNamesValues viewDistrictsNamesValues (  SqlConnection connSpedmon
                                                              , DetailsLog log
                                                              , UserInfo uInfo
                                                              , string countyCode
                                                              , string term
                                                             )
    {
      ReturnNamesValues r = new ReturnNamesValues();
      ReturnDB rd = viewDistricts (connSpedmon, log, uInfo, countyCode, null, term);
      r = Database.convertReturnDBToReturnNamesValues(ref rd);
      return r;
    }
    
   /***************************************************************************
     * viewDistrictsList */
    /**
     * List of districts
     ****************************************************************************/
       
    public static List<CdeRecordDistrict> viewDistrictsList (  SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , string countyCode
                                     , string districtCode
                                     , string term
                                    )
      {
        List<CdeRecordDistrict> rl = new List<CdeRecordDistrict>();

        ReturnDB rd = viewDistricts(connSpedmon, log, uInfo, countyCode, districtCode, term);
        Object[] ol = Database.convertRecords(rd.records, typeof(CdeRecordDistrict));

        foreach (Object o in ol)
        {
          CdeRecordDistrict r = (CdeRecordDistrict)o;
          rl.Add(r);
        }

        return rl;
      }
            
    
  }    
}
