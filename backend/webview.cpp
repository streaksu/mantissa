#include "backend/webview.h"

#include "frontend/mainwindow.h"

WebView::WebView(MainWindow *parent) : QWebEngineView()
{
    this->mainW = parent;
}

QWebEngineView *WebView::createWindow(QWebEnginePage::WebWindowType type) {
    switch (type) {
        case QWebEnginePage::WebBrowserTab:
            return mainW->newTab(QUrl(""));
        default:
            return QWebEngineView::createWindow(type);
    }
}
