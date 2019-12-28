#include "Registry.h"

STDAPI CreateRegistryKey(REGKEY_SUBKEY_AND_VALUE* pKey)
{
    size_t cbData;
    LPVOID pvData = NULL;
    HRESULT hr = S_OK;

    switch(pKey->dwType)
    {
    case REG_DWORD:
        pvData = (LPVOID)(LPDWORD)&pKey->dwData;
        cbData = sizeof(DWORD);
        break;

    case REG_SZ:
    case REG_EXPAND_SZ:
        hr = StringCbLength((LPCWSTR)pKey->dwData, STRSAFE_MAX_CCH, &cbData);
        if (SUCCEEDED(hr))
        {
            pvData = (LPVOID)(LPCWSTR)pKey->dwData;
            cbData += sizeof(WCHAR);
        }
        break;

    default:
        hr = E_INVALIDARG;
    }

    if (SUCCEEDED(hr))
    {
        LSTATUS status = SHSetValue(pKey->hKey, pKey->lpszSubKey, pKey->lpszValue, pKey->dwType, pvData, (DWORD)cbData);
        if (NOERROR != status)
        {
            hr = HRESULT_FROM_WIN32(status);
        }
    }

    return hr;
}

STDAPI CreateRegistryKeys(REGKEY_SUBKEY_AND_VALUE* aKeys, ULONG cKeys)
{
    HRESULT hr = S_OK;

    for (ULONG iKey = 0; iKey < cKeys; iKey++)
    {
        HRESULT hrTemp = CreateRegistryKey(&aKeys[iKey]);
        if (FAILED(hrTemp))
        {
            hr = hrTemp;
        }
    }
    return hr;
}

STDAPI DeleteRegistryKeys(REGKEY_SUBKEY* aKeys, ULONG cKeys)
{
    HRESULT hr = S_OK;
    LSTATUS status;

    for (ULONG iKey = 0; iKey < cKeys; iKey++)
    {
        status = RegDeleteTree(aKeys[iKey].hKey, aKeys[iKey].lpszSubKey);
        if (NOERROR != status)
        {
            hr = HRESULT_FROM_WIN32(status);
        }
    }
    return hr;
}
