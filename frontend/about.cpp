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
    ui->nameLabel->setText(PROJECTNAME);
    ui->versionLabel->setText(PROJECTVERSION);
    ui->licenseLabel->setText(PROJECTLICENSE);
}

About::~About()
{
    delete ui;
}

void About::on_pushButton_clicked()
{
    close();
}
