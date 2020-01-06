#pragma once

#include <QtCore/QDebug>

#if QT_VERSION < 0x050200
#define debugLog qDebug()
#else
#include <QtCore/QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(svgExtension)
#define debugLog qCDebug(svgExtension)
#endif
