/*******************************************************************************
* $Id: DisposableBase.cs 1053 2009-04-07 17:16:45Z sthames $
*******************************************************************************/
using System;

namespace MBA
  {
  
  /*****************************************************************************
   * DisposableBase Class
   *
   * This is a base for classes that will manage other resources that need to be
   * disposed as part of garbage collection. Classes that access other resources
   * such as EventLogger should use this class as a base to implement a good
   * cleanup. This class implements the IDisposable interface and can not be
   * instantiated. It must be inherited.
   *****************************************************************************/

  public abstract class DisposableBase : IDisposable
    {
    /***************************************************************************
     * Properties
     ***************************************************************************/

    protected bool m_Disposed = false;

    /***************************************************************************
     * Destructor */
    /**
     * This method will run only if the Dispose method does not get called. 
     * Do not re-create Dispose clean-up code here.  Calling dispose(false) is 
     * optimal in terms of readability and maintainability.
     ***************************************************************************/

    ~ DisposableBase()
      {
      dispose(false);
      }

    /***************************************************************************
     * Dispose */
    /**
     * Implements IDisposable.Dispose. Calls dispose(true) to clean up the 
     * object. Suppresses Finalize so Dispose() is not called twice.
     ***************************************************************************/

    public void Dispose()
      {
      dispose(true);
      GC.SuppressFinalize(this);
      }

    /***************************************************************************
     * dispose */
    /**
     * Performs the actual object cleanup. If disposing is true, the call is from
     * Dispose() and both managed and unmanaged resources can be cleaned up. If
     * disposing is false, the call is from Finalize and objects may not be
     * available. Only unmanaged resources can be released. Resources are
     * released by calls to DisposeManaged() and DisposeUnmanaged().
     *
     * @param  disposing  True=Called by Dispose(), False=Finalize()
     ***************************************************************************/

    protected void dispose(bool disposing)
      {
      if (!m_Disposed)
        {
        try
          {
          /*---------------------------------------------*/
          /* If called from Dispose(), we have access to */
          /* all our objects so drop the managed ones.   */
          /*---------------------------------------------*/
          if (disposing)
            {
            disposeManaged();
            }

          /*-----------------------------*/
          /* Drop the unmanaged objects. */
          /*-----------------------------*/
          disposeUnmanaged();
          }

        finally
          {
          m_Disposed = true;
          }
        }
      }

    /***************************************************************************
     * disposeManaged */
    /**
     * This method should be overridden if there is are any managed objects that
     * need to be disposed. It does not do anything here.
     ***************************************************************************/

    protected virtual void disposeManaged()
      {
      }

    /***************************************************************************
     * disposeUnmanaged */
    /**
     * This method should be overridden if there is are any unmanaged objects
     * that need to be disposed. It does not do anything here.
     ***************************************************************************/

    protected virtual void disposeUnmanaged()
      {
      }
    }
  }






