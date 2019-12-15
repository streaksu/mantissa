#include "frontend/about.h"

#include "ui_about.h"
#include "globals.h"
#include <QPicture>

About::About(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::About)
{
    ui->setupUi(this);
    setWindowTitle(QString(PROJECTNAME) + " - About");

    ui->nameLabel->setText(QString("<b>") + PROJECTNAME + "</b> version <b>" + PROJECTVERSION + "</b>");
    ui->licenseLabel->setText(QString("Distributed under the <b>") + PROJECTLICENSE "</b> license");
}

About::~About()
{
    delete ui;
}

void About::on_closeButton_clicked()
{
    close();
}
