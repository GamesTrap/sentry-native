workspace "SentryNative"
	architecture "x86_64"
	startproject "SentryNative"

	configurations
	{
		"Debug",
		"Release"
	}

	flags "MultiProcessorCompile"

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

project "Example"
	location "."
	kind "ConsoleApp"
	language "C++"
	staticruntime "off"
	cppdialect "C++17"
	systemversion "latest"
	architecture "x86_64"
	pic "on"

	targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
	objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	files
	{
		"examples/example.c"
	}

	includedirs
	{
        "include"
	}

	links
	{
		"SentryNative"
	}

	filter "configurations:Debug"
		defines "TRAP_DEBUG"
		runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		defines "TRAP_RELEASE"
		runtime "Release"
		optimize "Full"
		entrypoint "mainCRTStartup"
		kind "WindowedApp"





project "SentryNative"
    kind "SharedLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"SENTRY_BACKEND_CRASHPAD",
		"SENTRY_BUILD_SHARED",
		"SENTRY_WITH_UNWINDER_LIBBACKTRACE",
		"SIZEOF_LONG=8",
		"ZLIB_CONST",
	}

    files
    {
		"vendor/mpack.c",
		"vendor/mpack.h",
		"vendor/stb_sprintf.c",
		"vendor/stb_sprintf.h",

		"src/**.h",
		"src/**.c",
		"src/**.cpp",
    }

	removefiles
	{
		"src/backends/sentry_backend_breakpad.cpp",
		"src/backends/sentry_backend_inproc.c",
		"src/backends/sentry_backend_none.c",
		"src/integrations/**",

		-- OS dependent configuration files
		"src/modulefinder/sentry_modulefinder_aix.c",
		"src/modulefinder/sentry_modulefinder_apple.c",
		"src/modulefinder/sentry_modulefinder_linux.c",
		"src/modulefinder/sentry_modulefinder_linux.h",
		"src/modulefinder/sentry_modulefinder_windows.c",
		"src/path/sentry_path_unix.c",
		"src/path/sentry_path_windows.c",
		"src/symbolizer/sentry_symbolizer_unix.c",
		"src/symbolizer/sentry_symbolizer_windows.c",
		"src/transports/sentry_transport_none.c",
		"src/transports/sentry_transport_winhttp.c",
		"src/unwinder/sentry_unwinder_dbghelp.c",
		"src/unwinder/sentry_unwinder_libunwindstack.cpp",
		"src/sentry_unix_pageallocator.c",
		"src/sentry_unix_pageallocator.h",
		"src/sentry_unix_spinlock.h",
		"src/sentry_windows_dbghelp.c",
		"src/sentry_windows_dbghelp.h",
	}

    includedirs
    {
		"include",
		"src",

		"external/crashpad",
		"external/crashpad/third_party/zlib/zlib",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
		"external/crashpad/snapshot",
		"external/crashpad/minidump",
    }

	links
	{
		"CrashpadClient",
		"CrashpadUtil",
		"CrashpadCompat",
		"CrashpadZLib",
		"MiniChromium",

		-- "CrashpadSnapshot",
		-- "CrashpadMinidump",
		-- "CrashpadHandler",
		-- "CrashpadTools",
	}

	filter "system:linux"
		files
		{
			"src/modulefinder/sentry_modulefinder_linux.c",
			"src/modulefinder/sentry_modulefinder_linux.h",
			"src/path/sentry_path_unix.c",
			"src/symbolizer/sentry_symbolizer_unix.c",
			"src/sentry_unix_pageallocator.c",
			"src/sentry_unix_pageallocator.h",
			"src/sentry_unix_spinlock.h",
		}

		includedirs
		{
			"external/crashpad/compat/linux",
			"external/crashpad/compat/non_win",
		}

		links
		{
			"curl",
			"ssl",
			"crypto",

			"pthread",
			"dl",
			"rt",
		}

	filter "system:windows"
		files
		{
			"src/modulefinder/sentry_modulefinder_windows.h",
			"src/path/sentry_path_windows.c",
			"src/symbolizer/sentry_symbolizer_windows.c",
		}

		includedirs
		{
			"external/crashpad/compat/win",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadHandlerExecutable"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

    files
    {
		"external/crashpad/handler/main.cc",
    }

    includedirs
    {
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
		"external/crashpad/snapshot",
		"external/crashpad/tools",
    }

	links
	{
		--NOTE Do not change or linking will fail
		"CrashpadClient",
		"CrashpadHandler",
		"CrashpadMinidump",
		"CrashpadSnapshot",
		"CrashpadTools",
		"CrashpadUtil",
		"MiniChromium",
		"CrashpadClient",
		"CrashpadUtil",
		"CrashpadZLib",
		"MiniChromium",
		"CrashpadCompat",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/client/pthread_create_linux.cc",
		}

		includedirs
		{
			"external/crashpad/compat/linux",
			"external/crashpad/compat/non_win",
		}

		links
		{
			"crypto",
			"ssl",
			"curl",

			"pthread",
			"dl",
		}

	filter "system:windows"
		includedirs
		{
			"external/crashpad/compat/win",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadZLib"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"
	vectorextensions "SSE4.2"
	isaextensions "PCLMUL"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"HAVE_STDARG_H",
		"ZLIB_CONST",
	}

    files
    {
		"external/crashpad/third_party/zlib/*.h",
		"external/crashpad/third_party/zlib/*.c",
		"external/crashpad/third_party/zlib/zlib/*.h",
		"external/crashpad/third_party/zlib/zlib/*.c",
    }

	removefiles
	{
		"external/crashpad/third_party/zlib/zlib/simd_stub.c",
	}

    includedirs
    {
		"external/crashpad/third_party/zlib/zlib",
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
    }

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadCompat"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/compat/linux/**.h",
			"external/crashpad/compat/linux/**.cc",
		}

		includedirs
		{
			"external/crashpad/compat/linux",
			"external/crashpad/compat/non_win",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/compat/win/**.h",
			"external/crashpad/compat/win/**.cc",
		}

		includedirs
		{
			"external/crashpad/compat/win",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "MiniChromium"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
	}

	includedirs
	{
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
		"external/crashpad",
	}

	files
	{
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/**.h",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/**.cc",
	}

	removefiles
	{
		-- OS dependent configuration files
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/files/file_util_posix.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/fuchsia/**",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/mac/**",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/memory/page_size_posix.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/memory/page_size_win.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/posix/**",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_posix.h",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_win.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_win.h",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/condition_variable_posix.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/lock_impl_posix.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/lock_impl_win.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/threading/thread_local_storage_posix.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/threading/thread_local_storage_win.cc",
		"external/crashpad/third_party/mini_chromium/mini_chromium/base/scoped_clear_last_error_win.cc",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/files/file_util_posix.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/memory/page_size_posix.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/posix/**.h",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/posix/**.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_posix.h",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/condition_variable_posix.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/lock_impl_posix.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/threading/thread_local_storage_posix.cc",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/memory/page_size_win.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_win.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/strings/string_util_win.h",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/synchronization/lock_impl_win.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/threading/thread_local_storage_win.cc",
			"external/crashpad/third_party/mini_chromium/mini_chromium/base/scoped_clear_last_error_win.cc",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadUtil"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_USE_BORINGSSL",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
	}

	files
	{
		"external/crashpad/util/**.h",
		"external/crashpad/util/**.cc",
	}

	removefiles
	{
		"external/crashpad/util/file/*test*.cc",
		"external/crashpad/util/fuchsia/**",
		"external/crashpad/util/ios/**",
		"external/crashpad/util/linux/**",
		"external/crashpad/util/mac/**",
		"external/crashpad/util/mach/**",
		"external/crashpad/util/misc/*_test*.cc",
		"external/crashpad/util/net/*test*.cc",
		"external/crashpad/util/numeric/*test*.cc",
		"external/crashpad/util/process/*test*.cc",
		"external/crashpad/util/stdlib/*test*.cc",
		"external/crashpad/util/stream/*test*.cc",
		"external/crashpad/util/string/*test*.cc",
		"external/crashpad/util/synchronization/*test*.cc",
		"external/crashpad/util/thread/*test*.cc",
		"external/crashpad/util/posix/**",
		"external/crashpad/util/win/**",

		-- OS dependent configuration files

		"external/crashpad/util/file/directory_reader_posix.cc",
		"external/crashpad/util/file/directory_reader_win.cc",
		"external/crashpad/util/file/file_io_posix.cc",
		"external/crashpad/util/file/file_io_win.cc",
		"external/crashpad/util/file/filesystem_posix.cc",
		"external/crashpad/util/file/filesystem_win.cc",

		"external/crashpad/util/misc/capture_context_test_util_fuchsia.cc",
		"external/crashpad/util/misc/capture_context_test_util_linux.cc",
		"external/crashpad/util/misc/capture_context_test_util_mac.cc",
		"external/crashpad/util/misc/capture_context_test_util_win.cc",
		"external/crashpad/util/misc/clock_mac.cc",
		"external/crashpad/util/misc/clock_posix.cc",
		"external/crashpad/util/misc/clock_win.cc",
		"external/crashpad/util/misc/paths_fuchsia.cc",
		"external/crashpad/util/misc/paths_linux.cc",
		"external/crashpad/util/misc/paths_mac.cc",
		"external/crashpad/util/misc/paths_win.cc",
		"external/crashpad/util/misc/time_linux.cc",
		"external/crashpad/util/misc/time_win.cc",

		"external/crashpad/util/net/http_transport_socket.cc",
		"external/crashpad/util/net/http_transport_win.cc",

		"external/crashpad/util/process/process_memory_fuchsia.cc",
		"external/crashpad/util/process/process_memory_fuchsia.h",
		"external/crashpad/util/process/process_memory_linux.cc",
		"external/crashpad/util/process/process_memory_linux.h",
		"external/crashpad/util/process/process_memory_mac.cc",
		"external/crashpad/util/process/process_memory_mac.h",
		"external/crashpad/util/process/process_memory_win.cc",
		"external/crashpad/util/process/process_memory_win.h",

		"external/crashpad/util/synchronization/semaphore_mac.cc",
		"external/crashpad/util/synchronization/semaphore_posix.cc",
		"external/crashpad/util/synchronization/semaphore_win.cc",

		"external/crashpad/util/thread/thread_posix.cc",
		"external/crashpad/util/thread/thread_win.cc",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/util/file/directory_reader_posix.cc",
			"external/crashpad/util/file/file_io_posix.cc",
			"external/crashpad/util/file/filesystem_posix.cc",
			"external/crashpad/util/linux/**.h",
			"external/crashpad/util/linux/**.cc",
			"external/crashpad/util/misc/clock_posix.cc",
			"external/crashpad/util/misc/paths_linux.cc",
			"external/crashpad/util/misc/time_linux.cc",
			"external/crashpad/util/posix/**.h",
			"external/crashpad/util/posix/**.cc",
			"external/crashpad/util/process/process_memory_linux.cc",
			"external/crashpad/util/process/process_memory_linux.h",
			"external/crashpad/util/synchronization/semaphore_posix.cc",
			"external/crashpad/util/thread/thread_posix.cc",
		}

		removefiles
		{
			"external/crashpad/util/linux/*test*.cc",
			"external/crashpad/util/posix/*test*.cc",

			"external/crashpad/util/posix/process_info_mac.cc",

			"external/crashpad/util/linux/initial_signal_dispositions.cc",
			"external/crashpad/util/linux/initial_signal_dispositions.h",
		}

		includedirs
		{
			"external/crashpad/compat/non_win",
			"external/crashpad/compat/linux",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/util/file/directory_reader_win.cc",
			"external/crashpad/util/file/file_io_win.cc",
			"external/crashpad/util/file/filesystem_win.cc",
			"external/crashpad/util/misc/capture_context_test_util_win.cc",
			"external/crashpad/util/misc/clock_win.cc",
			"external/crashpad/util/misc/paths_win.cc",
			"external/crashpad/util/misc/time_win.cc",
			"external/crashpad/util/process/process_memory_win.cc",
			"external/crashpad/util/process/process_memory_win.h",
			"external/crashpad/util/synchronization/semaphore_win.cc",
			"external/crashpad/util/thread/thread_win.cc",
			"external/crashpad/util/win/**.h",
			"external/crashpad/util/win/**.cc",
		}

		removefiles
		{
			"external/crashpad/util/win/*test*.cc",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadClient"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
	}

	files
	{
		"external/crashpad/client/*.h",
		"external/crashpad/client/*.cc",
		"external/crashpad/client/crashpad_info_note.S",
	}

	removefiles
	{
		"external/crashpad/client/*test*.cc",

		-- OS dependent configuration files

		"external/crashpad/client/crash_report_database_win.cc",
		"external/crashpad/client/crashpad_client_fuchsia.cc",
		"external/crashpad/client/crashpad_client_ios.cc",
		"external/crashpad/client/crashpad_client_linux.cc",
		"external/crashpad/client/crashpad_client_mac.cc",
		"external/crashpad/client/crashpad_client_win.cc",
		"external/crashpad/client/pthread_create_linux.cc",
		"external/crashpad/client/simulate_crash_ios.h",
		"external/crashpad/client/simulate_crash_linux.h",
		"external/crashpad/client/simulate_crash_mac.h",
		"external/crashpad/client/simulate_crash_mac.cc",
		"external/crashpad/client/simulate_crash_win.h",
		"external/crashpad/client/upload_behavior_ios.h",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/client/crashpad_client_linux.cc",
			"external/crashpad/client/pthread_create_linux.cc",
			"external/crashpad/client/simulate_crash_linux.h",
		}

		includedirs
		{
			"external/crashpad/compat/non_win",
			"external/crashpad/compat/linux",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/client/crash_report_database_win.cc",
			"external/crashpad/client/crashpad_client_win.cc",
			"external/crashpad/client/simulate_crash_win.h",
		}

		includedirs
		{
			"external/crashpad/compat/win",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadSnapshot"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
	}

	files
	{
		"external/crashpad/snapshot/**.h",
		"external/crashpad/snapshot/**.cc",
	}

	removefiles
	{
		"external/crashpad/snapshot/crashpad_types/*test*.cc",
		"external/crashpad/snapshot/elf/*test*.cc",
		"external/crashpad/snapshot/elf/*fuzzer*.cc",
		"external/crashpad/snapshot/minidump/*test*.cc",
		"external/crashpad/snapshot/sanitized/*test*.cc",
		"external/crashpad/snapshot/*test*.cc",

		"external/crashpad/snapshot/test/**",

		-- OS dependent configuration files

		"external/crashpad/snapshot/fuchsia/**",
		"external/crashpad/snapshot/ios/**",
		"external/crashpad/snapshot/linux/**",
		"external/crashpad/snapshot/mac/**",
		"external/crashpad/snapshot/posix/**",
		"external/crashpad/snapshot/win/**",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/snapshot/linux/**.h",
			"external/crashpad/snapshot/linux/**.cc",
			"external/crashpad/snapshot/posix/**.h",
			"external/crashpad/snapshot/posix/**.cc",
		}

		includedirs
		{
			"external/crashpad/compat/non_win",
			"external/crashpad/compat/linux",
		}

		removefiles
		{
			"external/crashpad/snapshot/linux/*test*.cc",
			"external/crashpad/snapshot/posix/*test*.cc",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/snapshot/win/**.h",
			"external/crashpad/snapshot/win/**.cc",
		}

		includedirs
		{
			"external/crashpad/compat/win",
		}

		removefiles
		{
			"external/crashpad/snapshot/win/*test*.cc",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadMinidump"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
		"external/crashpad/snapshot",
	}

	files
	{
		"external/crashpad/minidump/*.h",
		"external/crashpad/minidump/*.cc",
	}

	removefiles
	{
		"external/crashpad/minidump/*test*.cc",

		"external/crashpad/minidump/minidump_stacktrace_writer.cc",
		"external/crashpad/minidump/minidump_stacktrace_writer.h",

		-- OS dependent configuration files
	}

	filter "system:linux"
		includedirs
		{
			"external/crashpad/compat/non_win",
			"external/crashpad/compat/linux",
		}

	filter "system:windows"
		includedirs
		{
			"external/crashpad/compat/win",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadHandler"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
		"CRASHPAD_ZLIB_SOURCE_EMBEDDED",
		"ZLIB_CONST",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
		"external/crashpad/third_party/mini_chromium",
		"external/crashpad/snapshot",
		"external/crashpad/minidump",
	}

	files
	{
		"external/crashpad/handler/**.h",
		"external/crashpad/handler/**.cc",
	}

	removefiles
	{
		"external/crashpad/handler/*test*.cc",

		-- OS dependent configuration files

		"external/crashpad/handler/linux/**",
		"external/crashpad/handler/mac/**",
		"external/crashpad/handler/win/**",
	}

	filter "system:linux"
		files
		{
			"external/crashpad/handler/linux/**.h",
			"external/crashpad/handler/linux/**.cc",
		}

		includedirs
		{
			"external/crashpad/compat/non_win",
			"external/crashpad/compat/linux",
		}

		removefiles
		{
			"external/crashpad/handler/linux/*test*.cc",
			"external/crashpad/handler/linux/handler_trampoline.cc",
		}

	filter "system:windows"
		files
		{
			"external/crashpad/handler/win/*.h",
			"external/crashpad/handler/win/*.cc",
		}

		includedirs
		{
			"external/crashpad/compat/win",
		}

		removefiles
		{
			"external/crashpad/handler/win/*test*.cc",
		}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"

project "CrashpadTools"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    systemversion "latest"
    warnings "off"
	architecture "x86_64"
	pic "on"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.group}/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.group}/%{prj.name}")

	defines
	{
		"CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1",
		"CRASHPAD_LSS_SOURCE_EMBEDDED",
	}

	includedirs
	{
		"external/crashpad",
		"external/crashpad/third_party/mini_chromium/mini_chromium",
	}

	files
	{
		"external/crashpad/tools/tool_support.cc",
		"external/crashpad/tools/tool_support.h",
	}

    filter "configurations:Debug"
	    runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		runtime "Release"
        optimize "Full"
