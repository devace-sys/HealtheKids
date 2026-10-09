using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.IO;
using System.Text;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Serialization;

namespace MBA
{
  
 /***************************************************************************
   * JsonLibary */
  /**
   * What serialization/deserializaton library to use
   ***************************************************************************/  
 
  public enum JsonLibrary
  { 

      MSFT_WEB_SCRIPT_SERIALIZATION = 1
    , NEWTONSOFT                    = 2
  }
    
  /***************************************************************************
    * NullDateTimeConverter */
   /**
    * Custom date time converter that returns the value null for DateTimes
    * that are null or are equal to DateTime.MinValue.
    * 
    * This is paired with DateTimeNullContractResolver
    ***************************************************************************/

   public class NullDateTimeConverter : IsoDateTimeConverter
   {
    public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
    {
      if (reader.Value == null)
        return DateTime.MinValue;

       return (DateTime)reader.Value;
     }

     public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
     {
       var dateTimeValue = value as DateTime?;
       if (dateTimeValue.HasValue)
       {
         if (dateTimeValue.Value.Equals(DateTime.MinValue))
         {
           writer.WriteNull();
           return;
         }
         base.WriteJson(writer, value, serializer);
         return;
       }
       else
       {
         writer.WriteNull();
         return;
       }
       return;
     }
    }

    /***************************************************************************
     * DateTimeNullContractResolver */
    /**
     * Custom contract resolver that is paired with NullDateTimeConverter
     * 
     ***************************************************************************/

    public class DateTimeNullContractResolver : DefaultContractResolver
    {
        // Use this static instance if possible to reduce overhead

        public static readonly DateTimeNullContractResolver DATE_TIME_CONTRACT_RESOLVER = new DateTimeNullContractResolver();

        protected override JsonContract CreateContract(Type objectType)
        {
            JsonContract contract = base.CreateContract(objectType);

            if (objectType == typeof(DateTime))
            {
                contract.Converter = new NullDateTimeConverter();
            }

            return contract;
        }
    }  
 
  /***************************************************************************
   * JSON */
  /**
   * Helper methods used to serialize/deserialize JSON
   * The to/from jSON string methods that use the Web.Script.Serialization
   * are courtesy of http://www.west-wind.com/Weblog/posts/442969.aspx
   ***************************************************************************/  

  public static class JSON
  {    
    
    /***************************************************************************
     * JSON_SERIALIZER_SETTINGS */
    /**
     * Static instance of serializer settings for JSON.NET 
     * This is for performance reasons.     
     ***************************************************************************/  
     
     public static JsonSerializerSettings JSON_SERIALIZER_SETTINGS = new JsonSerializerSettings
     {
         Formatting        = Formatting.None
       , ContractResolver  = DateTimeNullContractResolver.DATE_TIME_CONTRACT_RESOLVER
       , NullValueHandling = NullValueHandling.Include
       , DateFormatHandling = DateFormatHandling.IsoDateFormat
     };
  
    /***************************************************************************
     * toJSONString */
    /**
     * Serializes object into JSON string.  
     * 
     * Please note that if you are using MSFT_WEB_SCRIPT_SERIALIZATION the type 
     * must be marked Serializable or included in a DataContract attribute.
     * 
     * @param  obj             Object to serialize
     * @useWhatLibrary         What JSON serialize/deserialize libary to use
     * @return                 string containing JSON 
     ***************************************************************************/  
    
     public static String toJSONString (  Object obj
                                        , JsonLibrary useWhatLibrary = JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION)
     {
       if (useWhatLibrary == JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION)
       {
         var ser = new System.Web.Script.Serialization.JavaScriptSerializer(); 
         return ser.Serialize(obj);
       }
       else if (useWhatLibrary == JsonLibrary.NEWTONSOFT)
       {
         return JsonConvert.SerializeObject(obj, JSON_SERIALIZER_SETTINGS);           
       }
       return null;
     }

    /***************************************************************************
     * fromJSONString */
    /**
     * Deserializes JSON string into object of type.
     * 
     * @param  obj             String containing JSON to deserialize
     * @param  objType         Expected type of deserialized object [use typeof()]
     * @useWhatLibrary         What JSON serialize/deserialize libary to use
     * @return                 Object [cast to the type]
     ***************************************************************************/  
    
    public static Object fromJSONString (  string obj
                                         , Type objType
                                         , JsonLibrary useWhatLibrary = JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION)
    {
      if (useWhatLibrary == JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION)
      {   var ser = new System.Web.Script.Serialization.JavaScriptSerializer();
          return ser.Deserialize(obj, objType);
      }
      else if (useWhatLibrary == JsonLibrary.NEWTONSOFT)
      {
        return JsonConvert.DeserializeObject(obj,objType,JSON_SERIALIZER_SETTINGS);
      }
      return null; 
    }

    /***************************************************************************
     * dictFromJSONString */
    /**
     * Deserializes JSON string into a dictionary
     * 
     * http://procbits.com/2011/04/21/quick-json-serializationdeserialization-in-c
     * https://stackoverflow.com/a/11399104
     * 
     * {
     *   "some_number": 108.541, 
     *   "date_time": "2011-04-13T15:34:09Z", 
     *   "serial_number": "SN1234"
     * }
     * 
     * Console.WriteLine(dict["some_number"])
     *
     * @param  json            String containing JSON to deserialize
     * @return                 Dictionary
     ***************************************************************************/  

    public static Dictionary <String,String> dictFromJSONString (string json)
    {
       if (String.IsNullOrEmpty(json)) return new Dictionary<string,string>();
       var jss  = new JavaScriptSerializer();       
       Dictionary <String,String> dict = jss.Deserialize <Dictionary <String, String>> (json);
       return dict;
    }
    
  }
}
