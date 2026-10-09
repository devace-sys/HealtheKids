using System;

namespace MBA
{
	public class WebUI3Common 
	{
    public enum ElementSemantic
		{
		    info     
      , success
      , warning
      , danger         
      , primary
      , secondary
      , light
      , dark
      , garish
		}

    public static ElementSemantic GetElementSemanticByName (string value) 
    {      
      if (String.IsNullOrEmpty(value)) return ElementSemantic.garish;
      return (ElementSemantic) Enum.Parse(typeof(ElementSemantic),value,false);
		}		
    
    public static string GetElementSemanticName (ElementSemantic es) 
    {
       return Enum.GetName(typeof(ElementSemantic),es);
		}		

    public static ElementSemantic ReturnStatusToElementSemantic (int returnStatus)
    {
      ElementSemantic es;

      if      (returnStatus == Return.RET_INFO)             es = ElementSemantic.info;
      else if (returnStatus == Return.RET_SUCCESS)          es = ElementSemantic.success;
      else if (returnStatus == Return.RET_WARNING)          es = ElementSemantic.warning;
      else if (returnStatus == Return.RET_CRITICAL)         es = ElementSemantic.danger;
      else if (returnStatus == Return.RET_ERROR)            es = ElementSemantic.danger;
      else if (returnStatus == Return.RET_ABORT_OR_CANCEL)  es = ElementSemantic.primary;
      else if (returnStatus == Return.RET_PASSWORD_LOCK)    es = ElementSemantic.warning;
      else if (returnStatus == Return.RET_REDIRECT)         es = ElementSemantic.secondary;   
      else if (returnStatus == Return.RET_FATAL)            es = ElementSemantic.danger;
      else                                                  es = ElementSemantic.info;
      return es;
    }

    public static string ReturnStatusToElementSemanticName (int returnStatus)
    {
      ElementSemantic es = ReturnStatusToElementSemantic(returnStatus);      
      return GetElementSemanticName(es);
    }

	}
}

