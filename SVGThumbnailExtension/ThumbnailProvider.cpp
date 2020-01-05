#include "Common.h"
#include "ThumbnailProvider.h"

#include <gdiplus.h>
#include <assert.h>

#include <QtCore/QDateTime>
#ifndef NDEBUG
#include <QtCore/QString>
#include <QtCore/QDir>
#include <QtCore/QFile>
#endif
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtGui/QPixmap>
#if QT_VERSION >= 0x050200
#include <QtWin>
#endif

using namespace Gdiplus;

CThumbnailProvider::CThumbnailProvider()
{
    DllAddRef();
    m_cRef = 1;
    m_pSite = NULL;
    loaded = false;
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

/*
 * ===============
 * IUnkown methods
 * ===============
 */
HRESULT CThumbnailProvider::QueryInterfaceFactory(REFIID riid, void** ppvObject)
{
    *ppvObject = NULL;

    CThumbnailProvider * provider = new CThumbnailProvider();
    if (provider == nullptr)
    {
        return E_OUTOFMEMORY;
    }

    auto result = provider->QueryInterface(riid, ppvObject);

    provider->Release();

    return result;
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

/*
 * ===============
 * End IUnkown methods
 * ===============
 */

/*
 * ============================
 * IInitializeWithSteam methods
 * ============================
 */

STDMETHODIMP CThumbnailProvider::Initialize(IStream *pstm, 
                                            DWORD grfMode)
{
    ULONG len;
    STATSTG stat;
    Q_UNUSED(grfMode)

    if(loaded) {
        return HRESULT_FROM_WIN32(ERROR_ALREADY_INITIALIZED);
    }

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

/*
 * ============================
 * End IInitializeWithSteam methods
 * ============================
 */

/*
 * ============================
 * IThumbnailProvider methods
 * ============================
 */

STDMETHODIMP CThumbnailProvider::GetThumbnail(UINT cx, 
                                              HBITMAP *phbmp,
                                              WTS_ALPHATYPE *pdwAlpha)
{
    *phbmp = NULL;
    *pdwAlpha = WTSAT_ARGB;

#ifdef NDEBUG
    if(!loaded) {
        return S_FALSE;
    }
#endif

    // Fit the render into a (cx * cx) square while maintaining the aspect ratio.
    QSize size = renderer.defaultSize();
    size.scale(cx, cx, Qt::AspectRatioMode::KeepAspectRatio);

#ifndef NDEBUG
    QDir debugDir("C:\\dev");
    if(debugDir.exists()) {
        QFile f("C:\\dev\\svg.log");
        f.open(QFile::Append);
        //    f->write(QString("Size: %1 \n.").arg(cx).toAscii());
        f.write(QString("Size: %1 \n").arg(cx).toUtf8());
        f.flush();
        f.close();
    }
#endif

    QImage * device = new QImage(size, QImage::Format_ARGB32);
    device->fill(Qt::transparent);
    QPainter painter(device);

    painter.setRenderHints(QPainter::Antialiasing |
                           QPainter::SmoothPixmapTransform |
                           QPainter::TextAntialiasing);

    assert(device->paintingActive() && painter.isActive());
    if(loaded){
        renderer.render(&painter);
    } else {
        QFont font;
        QColor color_font = QColor(255, 0, 0);
        int font_size = cx / 10;

        font.setStyleHint(QFont::Monospace);
        font.setPixelSize(font_size);

        painter.setPen(color_font);
        painter.setFont(font);
        painter.drawText(font_size, (cx - font_size) / 2, "Invalid SVG file.");
    }
    painter.end();

    assert(!device->isNull());
#ifndef NDEBUG
    device->save(QString("C:\\dev\\%1.png").arg(QDateTime::currentMSecsSinceEpoch()), "PNG");
#endif

    // Issue #19, https://github.com/tibold/svg-explorer-extension/issues/19
    // Old syntax: HBITMAP QPixmap::toWinHBITMAP(HBitmapFormat format = NoAlpha) const
    // New syntax: HBITMAP QtWin::toHBITMAP(const QPixmap &p, QtWin::HBitmapFormat format = HBitmapNoAlpha)
#if QT_VERSION < 0x050200
    *phbmp = QPixmap::fromImage(*device).toWinHBITMAP(QPixmap::Alpha);
#else
    *phbmp = QtWin::toHBITMAP(QPixmap::fromImage(*device), QtWin::HBitmapAlpha);
#endif
    assert(*phbmp != NULL);

    delete device;

    if( *phbmp != NULL )
        return S_OK;
    return S_FALSE;
}

/*
 * ============================
 * End IThumbnailProvider methods
 * ============================
 */

/*
 * ============================
 * IObjectWithSite methods
 * ============================
 */

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

/*
 * ============================
 * End IObjectWithSite methods
 * ============================
 */
