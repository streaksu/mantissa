#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QWebEngineView>
#include "backend/webview.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    WebView *newTab(const QUrl &);

private slots:
    void titleChanged(const QString &title);
    void urlChanged(const QUrl &arg1);
    void iconChanged(const QIcon &);
    void tabCloseRequested(int);
    void currentChanged(int);

    void on_backButton_clicked();
    void on_forwardButton_clicked();
    void on_urlBar_returnPressed();
    void on_newTabButton_clicked();
    void on_settingsButton_clicked();

private:
    Ui::MainWindow *ui;
    void setWindowStuff();
    void setWindowStuff(QWebEngineView *);
};
#endif // MAINWINDOW_H
