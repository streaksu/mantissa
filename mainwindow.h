#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QWebEngineView>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void titleChanged(const QString &title);

    void on_backButton_clicked();

    void on_forwardButton_clicked();

    void urlChanged(const QUrl &arg1);

    void iconChanged(const QIcon &);

    void tabCloseRequested(int);

    void currentChanged(int);

    void on_urlBar_returnPressed();

    void on_newTabButton_clicked();

    void on_settingsButton_clicked();

private:
    Ui::MainWindow *ui;
    void setWindowStuff();
    void setWindowStuff(QWebEngineView *);
    void newTab(const QUrl &);
};
#endif // MAINWINDOW_H
