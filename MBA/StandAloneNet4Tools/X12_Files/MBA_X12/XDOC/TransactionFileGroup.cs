using System;

namespace MBA.X12.XDOC
{
  /// <summary>
  /// Transaction file group.
  /// </summary>

  public sealed class TransactionFileGroup
  {

	/// <summary>
    /// Initializes a new instance of the <see cref="T:MBA.X12.TransactionFileGroup"/> class.
    /// </summary>
    /// <remarks>
    /// User needs to call the Create method.
    /// <see cref=" "/>
    /// </remarks>
    
    public TransactionFileGroup() 
    {
    }
 
    /// <summary>
    /// Initializes a new instance of the <see cref="T:MBA.X12.TransactionFileGroup"/> class.
    /// </summary>    

    public TransactionFileGroup (int idx)
	{
			this.Create(idx);
    }
		
    private MBA.X12.TempFile _TempFileX12;
	private MBA.X12.TempFile _TempFileXML;
	private MBA.X12.TempFile _TempFileXMLTransOnlyTXT;

    /// <summary>
    /// Gets the transaction set number
    /// </summary>
    /// <value>Transaction set number</value>

	public int    Idx                       { get; private set; }		

    /// <summary>
    /// Gets the temp file path and name created for the 
    /// X12 formatted interchange envelope + transaction set
    /// </summary>
    /// <value>File path + name</value>

    public string FileNameX12               { get { return _TempFileX12.Path; } }

    /// <summary>
    /// Gets the temp file path and name created for the XML formatted
    /// interchange envelope + transaction set
    /// </summary>
    /// <value>File path + name</value>

	public string FileNameXML               { get { return _TempFileXML.Path; } }
    
    /// <summary>
    /// Gets the temp file path and name created for the XML formatted
    /// transaction set only
    /// </summary>
    /// <value>File path + name</value>

    public string FileNameXMLTransOnlyTXT   { get { return _TempFileXMLTransOnlyTXT.Path; } }

    /// <summary>
    /// Creates a new group of temp transaction group files
    /// </summary>
    /// <param name="idx">Transaction set number</param>

	public void Create (int idx)
	{
	  Idx                      = idx;
	  _TempFileX12             = new MBA.X12.TempFile();
      _TempFileXML             = new MBA.X12.TempFile();
      _TempFileXMLTransOnlyTXT = new MBA.X12.TempFile();
    }
		
    /// <summary>
    /// Delete this group of temp transaction files
    /// </summary>

    public void Delete ()
	{
	  _TempFileX12.Delete();
	  _TempFileXML.Delete();
	  _TempFileXMLTransOnlyTXT.Delete();		  
    }

  }
}
