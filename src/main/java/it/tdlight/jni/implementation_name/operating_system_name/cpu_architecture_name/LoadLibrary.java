package it.tdlight.jni.implementation_name.operating_system_name.cpu_architecture_name;

import java.lang.ClassLoader;
import java.io.InputStream;
import java.io.File;

public class LoadLibrary {
	public static InputStream getLibraryAsStream() {
		return LoadLibrary.class.getResourceAsStream("libs" + File.separatorChar + getOsName() + File.separatorChar + getArchName() + File.separatorChar + getFileName() + getExtension());
	}

	private static String getOsName() {
		return LoadLibrary.class.getPackageName().split("\\.")[4];
	}

	private static String getArchName() {
		return LoadLibrary.class.getPackageName().split("\\.")[5];
	}

	private static String getFileName() {
		return "tdjni";
	}

	private static String getExtension() {
		switch (getOsName()) {
			case "win":
				return ".dll";
			case "osx":
				return ".dylib";
			case "linux":
			default:
				return ".so";
		}
	}
}
