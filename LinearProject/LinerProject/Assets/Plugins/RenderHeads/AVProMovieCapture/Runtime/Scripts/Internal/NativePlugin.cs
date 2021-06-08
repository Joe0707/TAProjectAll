#if UNITY_5_4_OR_NEWER || (UNITY_5 && !UNITY_5_0 && !UNITY_5_1)
	#define AVPRO_MOVIECAPTURE_ISSUEPLUGINEVENT_52
#endif

using UnityEngine;
using System;
using System.Text;
using System.Runtime.InteropServices;
#if ENABLE_IL2CPP
using AOT;
#endif

//-----------------------------------------------------------------------------
// Copyright 2012-2019 RenderHeads Ltd.  All rights reserved.
//-----------------------------------------------------------------------------

namespace RenderHeads.Media.AVProMovieCapture
{
	public enum StereoPacking
	{
		None,
		TopBottom,
		LeftRight,
	}

	public enum StopMode
	{
		None,
		FramesEncoded,
		SecondsEncoded,
		SecondsElapsed,
	}

	public enum ImageSequenceFormat
	{
		PNG,
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX || UNITY_IOS
		JPEG,
		TIFF,
		HEIF,
#endif
	}

	/*public enum FileWriterType
	{
		AVI = 0,
		MediaFoundation = 1,
		PNG = 2,
	}*/

	public class NativePlugin
	{
#if UNITY_IOS && !UNITY_EDITOR_OSX
		const string PluginName = "__Internal";
#else
		const string PluginName = "AVProMovieCapture";
#endif

		public enum PixelFormat
		{
			RGBA32,
			BGRA32,             // Note: This is the native format for Unity textures with red and blue swapped.
			YCbCr422_YUY2,
			YCbCr422_UYVY,
			YCbCr422_HDYC,
		}

		// Used by GL.IssuePluginEvent
		public const int PluginID = 0xFA30000;
		public enum PluginEvent
		{
			CaptureFrameBuffer = 0,
			FreeResources = 1,
		}

		public const string ScriptVersion = "4.0.1";
		public const string ExpectedPluginVersion = "4.0.1";

		public const int MaxRenderWidth = 16384;
		public const int MaxRenderHeight = 16384;

#if AVPRO_MOVIECAPTURE_ISSUEPLUGINEVENT_52
		[DllImport(PluginName)]
		public static extern System.IntPtr GetRenderEventFunc();
		[DllImport(PluginName)]
		public static extern System.IntPtr GetFreeResourcesEventFunc();
#endif

#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX || UNITY_IOS
		private enum LogFlag : int {
			Error	= 1 << 0,
			Warning	= 1 << 1,
			Info	= 1 << 2,
			Debug	= 1 << 3,
			Verbose	= 1 << 4,
		};

		private enum LogLevel : int
		{
			Off		= 0,
			Error	= LogFlag.Error,
			Warning	= Error | LogFlag.Warning,
			Info	= Warning | LogFlag.Info,
			Debug	= Info | LogFlag.Debug,
			Verbose	= Debug | LogFlag.Verbose,
			All		= -1,
		};

#if DEBUG
		private static LogLevel _logLevel = LogLevel.Debug;
#else
		private static LogLevel _logLevel = LogLevel.Info;
#endif

		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		private delegate void LogCallbackDelegate(LogLevel level, [In, MarshalAs(UnmanagedType.LPWStr)] string str);

#if ENABLE_IL2CPP
		[MonoPInvokeCallback(typeof(LogCallbackDelegate))]
#endif
		private static void LogCallback(LogLevel level, string str)
		{
			if (_logLevel == LogLevel.Off)
				return;

			if (((int)level & (int)_logLevel) == (int)LogLevel.Error) {
				Debug.LogError(str);
			} else if (((int)level & (int)_logLevel) == (int)LogLevel.Warning) {
				Debug.LogWarning(str);
			} else if (((int)level & (int)_logLevel) == (int)LogLevel.Info) {
				Debug.Log(str);
			} else if (((int)level & (int)_logLevel) == (int)LogLevel.Debug) {
				Debug.Log(str);
			} else if (((int)level & (int)_logLevel) == (int)LogLevel.Verbose) {
				Debug.Log(str);
			}
		}

		private static void SetupDebugLogCallback()
		{
			LogCallbackDelegate callbackDelegate = new LogCallbackDelegate(LogCallback);
			System.IntPtr func = Marshal.GetFunctionPointerForDelegate(callbackDelegate);
			NativePlugin.SetLogFunction(func);
		}

		[DllImport(PluginName)]
		public static extern void RegisterPlugin();

		static NativePlugin()
		{
			SetupDebugLogCallback();
			NativePlugin.RegisterPlugin();
		}
#endif

		//////////////////////////////////////////////////////////////////////////
		// Global Init/Deinit

		[DllImport(PluginName)]
		public static extern bool Init();

		[DllImport(PluginName)]
		public static extern void Deinit();

		public static string GetPluginVersionString()
		{
			return System.Runtime.InteropServices.Marshal.PtrToStringAnsi(GetPluginVersion());
		}

		[DllImport(PluginName)]
		public static extern bool IsTrialVersion();

		//////////////////////////////////////////////////////////////////////////
		// Video Codecs

		[DllImport(PluginName)]
		public static extern int GetNumAVIVideoCodecs();

		[DllImport(PluginName)]
		public static extern bool IsConfigureVideoCodecSupported(int index);

		[DllImport(PluginName)]
		public static extern void ConfigureVideoCodec(int index);

		public static string GetAVIVideoCodecName(int index)
		{
			string result = "Invalid";
			StringBuilder nameBuffer = new StringBuilder(256);
			if (GetAVIVideoCodecName(index, nameBuffer, nameBuffer.Capacity))
			{
				result = nameBuffer.ToString();
			}
			return result;
		}


		//////////////////////////////////////////////////////////////////////////
		// Audio Codecs

		[DllImport(PluginName)]
		public static extern int GetNumAVIAudioCodecs();

		[DllImport(PluginName)]
		public static extern bool IsConfigureAudioCodecSupported(int index);

		[DllImport(PluginName)]
		public static extern void ConfigureAudioCodec(int index);

		public static string GetAVIAudioCodecName(int index)
		{
			string result = "Invalid";
			StringBuilder nameBuffer = new StringBuilder(256);
			if (GetAVIAudioCodecName(index, nameBuffer, nameBuffer.Capacity))
			{
				result = nameBuffer.ToString();
			}
			return result;
		}

		//////////////////////////////////////////////////////////////////////////
		// Audio Devices

		[DllImport(PluginName)]
		public static extern int GetNumAVIAudioInputDevices();

		public static string GetAVIAudioInputDeviceName(int index)
		{
			string result = "Invalid";
			StringBuilder nameBuffer = new StringBuilder(256);
			if (GetAVIAudioInputDeviceName(index, nameBuffer, nameBuffer.Capacity))
			{
				result = nameBuffer.ToString();
			}
			return result;
		}

		//////////////////////////////////////////////////////////////////////////
		// Container Files

		public static string[] GetContainerFileExtensions(int videoCodecIndex, int audioCodecIndex)
		{
			string[] result = new string[0];
			StringBuilder extensionsBuffer = new StringBuilder(256);
			if (GetContainerFileExtensions(videoCodecIndex, audioCodecIndex, extensionsBuffer, extensionsBuffer.Capacity))
			{
				result = extensionsBuffer.ToString().Split(new char[] {','});
			}
			return result;
		}		

		//////////////////////////////////////////////////////////////////////////
		// Create the recorder

		[DllImport(PluginName)]
		public static extern int CreateRecorderVideo([MarshalAs(UnmanagedType.LPWStr)] string filename, uint width, uint height, int frameRate, int format,
												bool isTopDown, int videoCodecIndex, bool hasAudio, int audioSampleRate, int audioChannelCount, int audioInputDeviceIndex, int audioCodecIndex, 
												bool isRealTime, bool useMediaFoundation, bool supportAlpha, bool forceGpuFlush);

		[DllImport(PluginName)]
		public static extern int CreateRecorderImages([MarshalAs(UnmanagedType.LPWStr)] string filename, uint width, uint height, int frameRate, int format,
												bool isTopDown, bool isRealTime, int imageFormatType, bool supportAlpha, bool forceGpuFlush, int startFrame);

		[DllImport(PluginName)]
		public static extern int CreateRecorderPipe([MarshalAs(UnmanagedType.LPWStr)] string filename, uint width, uint height, int frameRate, int format, 
												bool isTopDown, bool supportAlpha, bool forceGpuFlush);

		//////////////////////////////////////////////////////////////////////////
		// Update recorder

		[DllImport(PluginName)]
		public static extern bool Start(int handle);

		[DllImport(PluginName)]
		public static extern bool IsNewFrameDue(int handle);

		[DllImport(PluginName)]
		public static extern void EncodeFrame(int handle, System.IntPtr data);

		[DllImport(PluginName)]
		public static extern void EncodeAudio(int handle, System.IntPtr data, uint length);

		[DllImport(PluginName)]
		public static extern void EncodeFrameWithAudio(int handle, System.IntPtr videoData, System.IntPtr audioData, uint audioLength);

		[DllImport(PluginName)]
		public static extern void Pause(int handle);

		[DllImport(PluginName)]
		public static extern void Stop(int handle, bool skipPendingFrames);

		[DllImport(PluginName)]
		public static extern void SetTexturePointer(int handle, System.IntPtr texture);

		//////////////////////////////////////////////////////////////////////////
		// Destroy recorder

		[DllImport(PluginName)]
		public static extern void FreeRecorder(int handle);

		//////////////////////////////////////////////////////////////////////////
		// Debugging

		[DllImport(PluginName)]
		public static extern uint GetNumDroppedFrames(int handle);

		[DllImport(PluginName)]
		public static extern uint GetNumDroppedEncoderFrames(int handle);

		[DllImport(PluginName)]
		public static extern uint GetNumEncodedFrames(int handle);

		[DllImport(PluginName)]
		public static extern uint GetEncodedSeconds(int handle);

		[DllImport(PluginName)]
		public static extern uint GetFileSize(int handle);

		//////////////////////////////////////////////////////////////////////////
		// Private internal functions

		[DllImport(PluginName)]
		private static extern System.IntPtr GetPluginVersion();

		[DllImport(PluginName)]
		private static extern bool GetAVIVideoCodecName(int index, [MarshalAs(UnmanagedType.LPWStr)] StringBuilder name, int nameBufferLength);

		[DllImport(PluginName)]
		private static extern bool GetAVIAudioCodecName(int index, [MarshalAs(UnmanagedType.LPWStr)] StringBuilder name, int nameBufferLength);

		[DllImport(PluginName)]
		private static extern bool GetAVIAudioInputDeviceName(int index, [MarshalAs(UnmanagedType.LPWStr)] StringBuilder name, int nameBufferLength);

		[DllImport(PluginName)]
		private static extern bool GetContainerFileExtensions(int videoCodecIndex, int audioCodecIndex, [MarshalAs(UnmanagedType.LPWStr)] StringBuilder extensions, int extensionsBufferLength);

		//////////////////////////////////////////////////////////////////////////
		// Logging

		[DllImport(PluginName)]
		public static extern void SetLogFunction(System.IntPtr fn);

		//////////////////////////////////////////////////////////////////////////
		// Error reporting

		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		public delegate void ErrorHandlerDelegate(int handle, int domain, int code, [In, MarshalAs(UnmanagedType.LPWStr)] string message);

		[DllImport(PluginName)]
		public static extern void SetErrorHandler(int handle, System.IntPtr handler);

	}
}