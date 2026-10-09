using System;

namespace Geo.Google
{
	
	/***************************************************************************
   * ValueText */
  /**
   *
   ***************************************************************************/
	
	public class ValueText
	{
	  public string value {get;set;}
	  public string text  {get;set;}
	}

	/***************************************************************************
   * DistanceMatrixElement */
  /**
   *
   ***************************************************************************/
	
	public class DistanceMatrixElement
	{
	  public string    status   { get; set; }
	  public ValueText duration { get; set; }
	  public ValueText distance { get; set; }
	}

	/***************************************************************************
   * DistanceMatrixRows */
  /**
   *
   ***************************************************************************/
	
	public class DistanceMatrixRows
	{
	  public DistanceMatrixElement[] elements { get; set; }
	}

	/***************************************************************************
   * DistanceMatrixReponse */
  /**
   *
   ***************************************************************************/
	
	public class DistanceMatrixResponse
	{
		public string               status                { get; set; }
		public string[]             origin_addresses      { get; set; }
		public string[]             destination_addresses { get; set; }
		public DistanceMatrixRows[] rows                  { get; set; }	
	}
	
}

