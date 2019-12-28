#define INITGUID
#include "Registry.h"

HINSTANCE g_hinstDll = NULL;
LONG g_cRef = 0;

QApplication * app;

BOOL APIENTRY DllMain(HINSTANCE hinstDll,
                      DWORD dwReason,
                      LPVOID pvReserved)
{
    Q_UNUSED(pvReserved)
    switch (dwReason)
    {
    case DLL_PROCESS_ATTACH:
        g_hinstDll = hinstDll;
        int c = 0;
        app = new QApplication(c, (char **)0, 0);
        break;
    }
    return TRUE;
}

STDAPI_(HINSTANCE) DllInstance()
{
    return g_hinstDll;
}

STDAPI DllCanUnloadNow()
{
    return g_cRef ? S_FALSE : S_OK;
}

STDAPI_(ULONG) DllAddRef()
{
    LONG cRef = InterlockedIncrement(&g_cRef);
    return cRef;
}

STDAPI_(ULONG) DllRelease()
{
    LONG cRef = InterlockedDecrement(&g_cRef);
    if (0 > cRef)
        cRef = 0;
    return cRef;
}

STDAPI DllRegisterServer()
{
    WCHAR szModule[MAX_PATH];

    ZeroMemory(szModule, sizeof(szModule));
    GetModuleFileName(g_hinstDll, szModule, ARRAYSIZE(szModule));

    REGKEY_SUBKEY_AND_VALUE keys[] = {
        {HKEY_CLASSES_ROOT, L"CLSID\\" szCLSID_SampleThumbnailProvider, NULL, REG_SZ, (DWORD_PTR)L"Sample Thumbnail Provider"},
        {HKEY_CLASSES_ROOT, L"CLSID\\" szCLSID_SampleThumbnailProvider L"\\InprocServer32", NULL, REG_SZ, (DWORD_PTR)szModule},
        {HKEY_CLASSES_ROOT, L"CLSID\\" szCLSID_SampleThumbnailProvider L"\\InprocServer32", L"ThreadingModel", REG_SZ, (DWORD_PTR)L"Apartment"},
        {HKEY_CLASSES_ROOT, L".SVG\\shellex\\{E357FCCD-A995-4576-B01F-234630154E96}", NULL, REG_SZ, (DWORD_PTR)szCLSID_SampleThumbnailProvider},
        {HKEY_CLASSES_ROOT, L".SVGZ\\shellex\\{E357FCCD-A995-4576-B01F-234630154E96}", NULL, REG_SZ, (DWORD_PTR)szCLSID_SampleThumbnailProvider}
    };
    return CreateRegistryKeys(keys, ARRAYSIZE(keys));
}

STDAPI DllUnregisterServer()
{
    REGKEY_SUBKEY keys[] = {{HKEY_CLASSES_ROOT, L"CLSID\\" szCLSID_SampleThumbnailProvider}};
    return DeleteRegistryKeys(keys, ARRAYSIZE(keys));
}
