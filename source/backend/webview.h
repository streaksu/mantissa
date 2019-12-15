#ifndef WEBVIEW_H
#define WEBVIEW_H

#include <QWebEngineView>

class MainWindow;

class WebView : public QWebEngineView
{
public:
    explicit WebView(MainWindow *);
protected:
    QWebEngineView *createWindow(QWebEnginePage::WebWindowType type) override;
private:
    MainWindow *mainW;
};

#endif // WEBVIEW_H
