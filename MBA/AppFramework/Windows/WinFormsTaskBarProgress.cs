using System;
using System.Runtime.InteropServices;

namespace MBA
{

/// <summary>
/// Task Bar Progress Methods
/// Courtesey of WhoIsRich
/// Retrieved from https://stackoverflow.com/a/24187171 on 7/28/2023 at 10:51 AM PST
/// Class was renamed from TaskbarProgress to WinFormsTaskbarProgress and placed in MBA namespace
/// </summary>
/// <example>
/// WinFormsTaskbarProgress.TaskbarProgress.SetState(this.Handle, TaskbarProgress.TaskbarStates.Indeterminate);
/// or
/// WinFormsTaskbarProgress.TaskbarProgress.SetValue(this.Handle, 50, 100);
/// or
/// WinFormsTaskbarProgress.TaskbarProgress.SetState(this.Handle, TaskbarProgress.TaskbarStates.Error);
/// </example>

  public static class WinFormsTaskbarProgress
  {
    public enum TaskbarStates
    {
        NoProgress    = 0,
        Indeterminate = 0x1,
        Normal        = 0x2,
        Error         = 0x4,
        Paused        = 0x8
    }

    [ComImport()]
    [Guid("ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface ITaskbarList3
    {
        // ITaskbarList
        [PreserveSig]
        void HrInit();
        [PreserveSig]
        void AddTab(IntPtr hwnd);
        [PreserveSig]
        void DeleteTab(IntPtr hwnd);
        [PreserveSig]
        void ActivateTab(IntPtr hwnd);
        [PreserveSig]
        void SetActiveAlt(IntPtr hwnd);

        // ITaskbarList2
        [PreserveSig]
        void MarkFullscreenWindow(IntPtr hwnd, [MarshalAs(UnmanagedType.Bool)] bool fFullscreen);

        // ITaskbarList3
        [PreserveSig]
        void SetProgressValue(IntPtr hwnd, UInt64 ullCompleted, UInt64 ullTotal);
        [PreserveSig]
        void SetProgressState(IntPtr hwnd, TaskbarStates state);
    }

    [ComImport()]    
    [Guid("56fdf344-fd6d-11d0-958a-006097c9a090")]
    [ClassInterface(ClassInterfaceType.None)]
    private class TaskbarInstance
    {
    }

    private static ITaskbarList3 taskbarInstance = (ITaskbarList3)new TaskbarInstance();
   
    private static bool taskbarSupported = Environment.OSVersion.Version >= new Version(6, 1);

    public static void SetState(IntPtr windowHandle, TaskbarStates taskbarState)
    {
        if (taskbarSupported) taskbarInstance.SetProgressState(windowHandle, taskbarState);
    }

    public static void SetValue(IntPtr windowHandle, double progressValue, double progressMax)
    {
        if (taskbarSupported) taskbarInstance.SetProgressValue(windowHandle, (ulong)progressValue, (ulong)progressMax);
    }
  }
}


