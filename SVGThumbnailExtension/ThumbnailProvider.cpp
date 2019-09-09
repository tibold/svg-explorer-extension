#include "Common.h"
#include "ThumbnailProvider.h"
#include "gdiplus.h"
#include <QtGui/QImage>
#include <QtGui/QPixmap>
#include <QtGui/QPainter>
#include <QtWin>
#include <QtCore/QFile>
#include <QString>
#include <QDateTime>
#include "assert.h"

using namespace Gdiplus;
CThumbnailProvider::CThumbnailProvider()
{
    DllAddRef();
    m_cRef = 1;
    m_pSite = NULL;
}


CThumbnailProvider::~CThumbnailProvider()
{
    if (m_pSite)
    {
        m_pSite->Release();
        m_pSite = NULL;
    }
    DllRelease();
}


STDMETHODIMP CThumbnailProvider::QueryInterface(REFIID riid,
                                                void** ppvObject)
{
    static const QITAB qit[] = 
    {
        QITABENT(CThumbnailProvider, IInitializeWithStream),
        QITABENT(CThumbnailProvider, IThumbnailProvider),
        QITABENT(CThumbnailProvider, IObjectWithSite),
        {0},
    };
    return QISearch(this, qit, riid, ppvObject);
}


STDMETHODIMP_(ULONG) CThumbnailProvider::AddRef()
{
    LONG cRef = InterlockedIncrement(&m_cRef);
    return (ULONG)cRef;
}


STDMETHODIMP_(ULONG) CThumbnailProvider::Release()
{
    LONG cRef = InterlockedDecrement(&m_cRef);
    if (0 == cRef)
        delete this;
    return (ULONG)cRef;
}

STDMETHODIMP CThumbnailProvider::Initialize(IStream *pstm, 
                                            DWORD grfMode)
{
    ULONG len;
    STATSTG stat;
    if(pstm->Stat(&stat, STATFLAG_DEFAULT) != S_OK){
        return S_FALSE;
    }

    char * data = new char[stat.cbSize.QuadPart];

    if(pstm->Read(data, stat.cbSize.QuadPart, &len) != S_OK){
        return S_FALSE;
    }

    QByteArray bytes = QByteArray(data, stat.cbSize.QuadPart);

    loaded = renderer.load(bytes);

    return S_OK;
}


STDMETHODIMP CThumbnailProvider::GetThumbnail(UINT cx, 
                                              HBITMAP *phbmp, 
                                              WTS_ALPHATYPE *pdwAlpha)
{
	*phbmp = NULL; 
    *pdwAlpha = WTSAT_ARGB;

    int width, height;
    QSize size = renderer.defaultSize();

    if(size.width() == size.height()){
        width = cx;
        height = cx;
    } else if (size.width() > size.height()){
        width = cx;
        height = size.height() * ((double)cx / (double)size.width());
    } else {
        width = size.width() * ((double)cx / (double)size.height());
        height = cx;
    }

    QFile * f = new QFile("C:\\dev\\svg.log");
    f->open(QFile::Append);
//    f->write(QString("Size: %1 \n.").arg(cx).toAscii());
    f->write(QString("Size: %1 \n.").arg(cx).toUtf8());
    f->flush();
    f->close();

    QImage * device = new QImage(width, height, QImage::Format_ARGB32);
    device->fill(Qt::transparent);
    QPainter * painter = new QPainter();
    QFont font;
    QColor color_font = QColor(255, 0, 0);

    painter->begin(device);
    painter->setRenderHints(QPainter::Antialiasing |
                            QPainter::SmoothPixmapTransform |
                            QPainter::TextAntialiasing);
    assert(device->paintingActive() && painter->isActive());
    if(loaded){
        renderer.render(painter);
    } else {
        int font_size = cx / 10;

        font.setStyleHint(QFont::Monospace);
        font.setPixelSize(font_size);

        painter->setPen(color_font);
        painter->setFont(font);
        painter->drawText(font_size, (cx - font_size) / 2, "Invalid SVG file.");
    }
    painter->end();

    assert(!device->isNull());
#ifndef NDEBUG
    device->save(QString("C:\\dev\\%1.png").arg(QDateTime::currentMSecsSinceEpoch()), "PNG");
#endif
    // Issue #19, https://github.com/maphew/svg-explorer-extension/issues/19
    // Old syntax: HBITMAP QPixmap::toWinHBITMAP(HBitmapFormat format = NoAlpha) const
    // New syntax: HBITMAP QtWin::toHBITMAP(const QPixmap &p, QtWin::HBitmapFormat format = HBitmapNoAlpha)
    //
    // Old code:
    //*phbmp = QPixmap::fromImage(*device).toWinHBITMAP(QPixmap::Alpha);
    // new test code:
    *phbmp = QtWin::fromImage(*device).toHBITMAP(QPixmap::Alpha);
    assert(*phbmp != NULL);

    delete painter;
    delete device;

	if( *phbmp != NULL )
		return NOERROR;
	return E_NOTIMPL;

}


STDMETHODIMP CThumbnailProvider::GetSite(REFIID riid, 
                                         void** ppvSite)
{
    if (m_pSite)
    {
        return m_pSite->QueryInterface(riid, ppvSite);
    }
    return E_NOINTERFACE;
}


STDMETHODIMP CThumbnailProvider::SetSite(IUnknown* pUnkSite)
{
    if (m_pSite)
    {
        m_pSite->Release();
        m_pSite = NULL;
    }

    m_pSite = pUnkSite;
    if (m_pSite)
    {
        m_pSite->AddRef();
    }
    return S_OK;
}


STDAPI CThumbnailProvider_CreateInstance(REFIID riid, void** ppvObject)
{
    *ppvObject = NULL;

    CThumbnailProvider* ptp = new CThumbnailProvider();
    if (!ptp)
    {
        return E_OUTOFMEMORY;
    }

    HRESULT hr = ptp->QueryInterface(riid, ppvObject);
    ptp->Release();
    return hr;
}
