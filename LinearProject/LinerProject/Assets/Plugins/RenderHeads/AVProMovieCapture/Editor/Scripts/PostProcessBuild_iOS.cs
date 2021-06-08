#if UNITY_EDITOR_OSX

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

public class PostProcessBuild_iOS
{
	[PostProcessBuild]
	public static void ModfifyPlist(BuildTarget buildTarget, string path)
	{
		if (buildTarget != BuildTarget.iOS)
			return;

		string plistPath = path + "/Info.plist";
		PlistDocument plist = new PlistDocument();
		plist.ReadFromFile(plistPath);

		PlistElementDict rootDict = plist.root;

		// example of changing a value:
		// rootDict.SetString("CFBundleVersion", "6.6.6");

		// example of adding a boolean key...
		// < key > ITSAppUsesNonExemptEncryption </ key > < false />
		// rootDict.SetBoolean("ITSAppUsesNonExemptEncryption", false);

		// Enable file sharing so that files can be pulled off of the device with iTunes
		rootDict.SetBoolean("UIFileSharingEnabled", true);
		// Enable this so that the files app can access the captured movies
		rootDict.SetBoolean("LSSupportsOpeningDocumentsInPlace", true);

		File.WriteAllText(plistPath, plist.WriteToString());
	}
}

#endif
