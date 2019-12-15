#include "frontend/settings.h"

#include "ui_settings.h"
#include "globals.h"
#include "frontend/about.h"
#include <QSettings>
#include <QUrl>

#define HOMEPAGE_KEY "homepage"
#define ADDBLOCK_KEY "addblock"

QString getHomepage()
{
     auto settings = new QSettings(PROJECTNAME);
     auto homepage = settings->value(HOMEPAGE_KEY).toString();
     delete settings;
     return homepage;
}

bool getAddblock() {
    auto settings = new QSettings(PROJECTNAME);
    auto addblocker = settings->value(ADDBLOCK_KEY).toBool();
    delete settings;
    return addblocker;
}

Settings::Settings(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Settings)
{
    settings = new QSettings(PROJECTNAME);
    ui->setupUi(this);
    setAttribute(Qt::WA_DeleteOnClose);
    setWindowTitle(QString(PROJECTNAME) + " - Settings");

    ui->homepageBar->setText(getHomepage());
    ui->addblockCheck->setCheckState(getAddblock() ? Qt::CheckState::Checked : Qt::CheckState::Unchecked);
}

Settings::~Settings()
{
    delete settings;
    delete ui;
}

void Settings::on_aboutButton_clicked()
{
    auto about = new About();
    about->show();
}

void Settings::on_closeButton_clicked()
{
    close();
}

void Settings::on_saveButton_clicked()
{
    settings->setValue(HOMEPAGE_KEY, QUrl::fromUserInput(ui->homepageBar->text()).toString());
    settings->setValue(ADDBLOCK_KEY, ui->addblockCheck->checkState() == Qt::CheckState::Checked);
    close();
}
