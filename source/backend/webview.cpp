#include "backend/webview.h"

#include <QWebEngineProfile>
#include "frontend/mainwindow.h"
#include "frontend/settings.h"

WebView::WebView(MainWindow *parent) : QWebEngineView()
{
    // Set parent for further settings.
    this->mainW = parent;

    // Set cookie policy.
    switch (getCookiePolicy()) {
        case 0:
            this->page()->profile()->setPersistentCookiesPolicy(QWebEngineProfile::NoPersistentCookies);
            break;
        case 1:
            this->page()->profile()->setPersistentCookiesPolicy(QWebEngineProfile::AllowPersistentCookies);
            break;
        default:
            this->page()->profile()->setPersistentCookiesPolicy(QWebEngineProfile::ForcePersistentCookies);
    }
}

QWebEngineView *WebView::createWindow(QWebEnginePage::WebWindowType type) {
    switch (type) {
        case QWebEnginePage::WebBrowserTab:
            return mainW->newTab(QUrl(""));
        default:
            return QWebEngineView::createWindow(type);
    }
}
