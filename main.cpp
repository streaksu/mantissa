#include "frontend/mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setWindowIcon(QIcon(":/images/logo.png"));

    auto w = new MainWindow;
    w->show();

    return a.exec();
}
