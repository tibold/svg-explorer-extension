#pragma once

class CClassFactory : public IClassFactory
{
private:
    LONG m_cRef;

    ~CClassFactory();

public:
    CClassFactory();

    //  IUnknown methods
    STDMETHOD(QueryInterface)(REFIID, void**);
    STDMETHOD_(ULONG, AddRef)();
    STDMETHOD_(ULONG, Release)();

    //  IClassFactory methods
    STDMETHOD(CreateInstance)(IUnknown*, REFIID, void**);
    STDMETHOD(LockServer)(BOOL);
};
