#ifndef SVGTHUMBNAILEXTENSION_GLOBAL_H
#define SVGTHUMBNAILEXTENSION_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(SVGTHUMBNAILEXTENSION_LIBRARY)
#  define SVGTHUMBNAILEXTENSIONSHARED_EXPORT Q_DECL_EXPORT
#else
#  define SVGTHUMBNAILEXTENSIONSHARED_EXPORT Q_DECL_IMPORT
#endif

#include <windows.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <thumbcache.h>
#include <strsafe.h>

STDAPI_(ULONG) DllAddRef();
STDAPI_(ULONG) DllRelease();
STDAPI_(HINSTANCE) DllInstance();

// {68BF0019-79AB-4e7f-9500-AA3B5227DFE6}
//#define szCLSID_SampleThumbnailProvider L"{68BF0019-79AB-4e7f-9500-AA3B5227DFE6}"
//DEFINE_GUID(CLSID_SampleThumbnailProvider, 0x68bf0019, 0x79ab, 0x4e7f, 0x95, 0x0, 0xaa, 0x3b, 0x52, 0x27, 0xdf, 0xe6);

// {4CA20D9A-98AC-4DD6-9C16-7449F29AC08A}
#define szCLSID_SampleThumbnailProvider L"{4CA20D9A-98AC-4DD6-9C16-7449F29AC08A}"
DEFINE_GUID(CLSID_SampleThumbnailProvider,
0x4ca20d9a, 0x98ac, 0x4dd6, 0x9c, 0x16, 0x74, 0x49, 0xf2, 0x9a, 0xc0, 0x8a);

#include <QtWidgets/QApplication>
#include <QtSvg/QSvgRenderer>

#endif // SVGTHUMBNAILEXTENSION_GLOBAL_H
