#include "settings.h"
#include "ui_settings.h"
#include "globals.h"
#include <QSettings>

QString getHomepage() {
     auto settings = new QSettings(PROJECTNAME);
     auto homepage = settings->value("homepage").toString();
     delete settings;
     return homepage;
}

Settings::Settings(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Settings)
{
    ui->setupUi(this);
}

Settings::~Settings()
{
    delete ui;
}

void Settings::on_saveButton_clicked()
{
    auto settings = new QSettings(PROJECTNAME);
    settings->setValue("homepage", ui->homepageBar->text());
    delete settings;
    close();
}
