namespace EAW.Logger
{
  /*****************************************************************************
  * Interface for objects that are logged.
  *****************************************************************************/
  public interface ILoggedObject
  {
   LogLevel logLevel { get; }
  }
}

