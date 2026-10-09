using System;
using System.IO;

namespace MBA.X12
{
  
  /// <summary>
  /// Self deleting temp file
  /// Based on TempFile class courtesy of Marc Gravell.
  /// <see cref="https://stackoverflow.com/a/400391"/>
  /// For a good tutorial on temp files see DaveOnC# article How to Use Temporary Files in C#
  /// <see cref="http://www.daveoncsharp.com/2009/09/how-to-use-temporary-files-in-csharp/"/>
  /// </summary>

  public sealed class TempFile : IDisposable
  {
    private string _path = null;
    
    /// <summary>
    /// Initializes a new instance of the <see cref="T:MBA.X12.TempFile"/> class.
    /// Uses the operating system provided application temp file folder and the
    /// built in temp file creation and naming routine.
    /// </summary>
    
    public TempFile () : this ( System.IO.Path.GetTempFileName() ) 
    {
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="T:MBA.X12.TempFile"/> class.
    /// User provides a path to a temp folder and a temp file name
    /// </summary>
    /// <param name="path">Path.</param>
    
    public TempFile (string path)
    {
      if (string.IsNullOrEmpty(path)) throw new ArgumentNullException(@"path");
      this._path = path;			    
    }
    
    /// <summary>
    /// Gets the path and file name of the temp file
    /// </summary>
    /// <value>The path.</value>

    public string Path
    {
      get
      {
        if (_path == null) throw new ObjectDisposedException(GetType().Name);
        return _path;
      }
    }

		/// <summary>
    /// Delete the temp file
    /// </summary>

    private void _Delete()
		{
      try
			{
				if (_path != null)
				{
					if (File.Exists(_path))
					{
						File.Delete(_path);
						_path = null;
					}
				}
			}
			catch // Tried
      {        
      }
    }
    
    /// <summary>
    /// Delete the temp file
    /// </summary>

    public void Delete()
		{
			_Delete(); 
    }

    /// <summary>
    /// Releases unmanaged resources and performs other cleanup operations before the <see cref="T:MBA.X12.TempFile"/>
    /// is reclaimed by garbage collection.
    /// </summary>

    ~TempFile() { Dispose(false); }

    /// <summary>
    /// Releases all resource used by the <see cref="T:MBA.X12.TempFile"/> object.
    /// </summary>
    /// <remarks>Call <see cref="Dispose"/> when you are finished using the <see cref="T:MBA.X12.TempFile"/>. The
    /// <see cref="Dispose"/> method leaves the <see cref="T:MBA.X12.TempFile"/> in an unusable state. After calling
    /// <see cref="Dispose"/>, you must release all references to the <see cref="T:MBA.X12.TempFile"/> so the garbage
    /// collector can reclaim the memory that the <see cref="T:MBA.X12.TempFile"/> was occupying.</remarks>

    public void Dispose() { Dispose(true); }
    private void Dispose(bool disposing)
    {
      if (disposing)
      {
        GC.SuppressFinalize(this);                
      }
      _Delete();  
    }
  }
}
