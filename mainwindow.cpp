#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "globals.h"
#include "settings.h"

#include <QWebEngineView>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    setAttribute(Qt::WA_DeleteOnClose);
    ui->navigationTabs->clear();
    on_newTabButton_clicked();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::titleChanged(const QString &title)
{
    setWindowTitle(title + " - " + PROJECTNAME);
    ui->navigationTabs->setTabText(ui->navigationTabs->indexOf(static_cast<QWidget *>(sender())), title);
}

void MainWindow::on_backButton_clicked()
{
    auto index   = ui->navigationTabs->currentIndex();
    auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));

    webview->back();
}

void MainWindow::on_forwardButton_clicked()
{
    auto index   = ui->navigationTabs->currentIndex();
    auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));

    webview->forward();
}

void MainWindow::urlChanged(const QUrl &)
{
    auto index   = ui->navigationTabs->currentIndex();
    auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));

    if (webview == sender()) {
        setWindowStuff(webview);
    }
}

void MainWindow::iconChanged(const QIcon &icon)
{
    ui->navigationTabs->setTabIcon(ui->navigationTabs->indexOf(static_cast<QWidget *>(sender())), icon);
}

void MainWindow::tabCloseRequested(int index)
{
    auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));
    webview->deleteLater();
}

void MainWindow::currentChanged(int index) {
    if (index == -1) {
        ui->backButton->setEnabled(false);
        ui->forwardButton->setEnabled(false);
        setWindowStuff();
    } else {
        ui->backButton->setEnabled(true);
        ui->forwardButton->setEnabled(true);
        auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));
        setWindowStuff(webview);
    }
}

void MainWindow::on_urlBar_returnPressed()
{
    auto index   = ui->navigationTabs->currentIndex();
    auto userUrl = QUrl::fromUserInput(ui->urlBar->text());

    if (index == -1) {
        newTab(userUrl);
    } else {
        auto webview = static_cast<QWebEngineView *>(ui->navigationTabs->widget(index));
        webview->setUrl(userUrl);
    }
}

void MainWindow::on_newTabButton_clicked()
{
    newTab(QUrl(getHomepage()));
}

void MainWindow::newTab(const QUrl &page)
{
    auto webview = new QWebEngineView;
    webview->setUrl(page);

    connect(
        webview,
        SIGNAL(titleChanged(const QString &)),
        this,
        SLOT(titleChanged(const QString &))
    );
    connect(
        webview,
        SIGNAL(urlChanged(const QUrl &)),
        this,
        SLOT(urlChanged(const QUrl &))
    );
    connect(
        webview,
        SIGNAL(iconChanged(const QIcon &)),
        this,
        SLOT(iconChanged(const QIcon &))
    );
    connect(
        ui->navigationTabs,
        SIGNAL(tabCloseRequested(int)),
        this,
        SLOT(tabCloseRequested(int))
    );
    connect(
        ui->navigationTabs,
        SIGNAL(currentChanged(int)),
        this,
        SLOT(currentChanged(int))
    );

    ui->navigationTabs->addTab(webview, "New tab");
}

void MainWindow::setWindowStuff()
{
    ui->urlBar->setText("");
    setWindowTitle(PROJECTNAME);
}

void MainWindow::setWindowStuff(QWebEngineView *webview) {
    ui->urlBar->setText(webview->url().toString());
    ui->urlBar->setCursorPosition(0);
    setWindowTitle(webview->url().toString() + " - " + PROJECTNAME);
}

void MainWindow::on_settingsButton_clicked()
{
    auto set = new Settings;
    set->show();
}
